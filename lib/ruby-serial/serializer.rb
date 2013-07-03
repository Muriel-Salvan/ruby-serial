module RubySerial

  class Serializer

    # Find a method name that is unlikely to conflict with other modules that might also override to_msgpack
    ALIASED_TO_MSGPACK_METHOD = :__to_msgpack_without_MessagePackOverride__

    # Constructor
    #
    # Parameters::
    # * *obj* (_Object_): Ruby object to serialize
    # * *options* (<em>map<Symbol,Object></em>): Options [default = {}]
    #   * *:version* (_Fixnum_): The version to be used to encode
    def initialize(obj, options = {})
      @obj = obj
      # Map of objects ID, with their corresponding number of shared objects among their descendants (those having 0 share nothing)
      # map< ObjectID, NbrSharedObjects >
      @objs = {}
      # Map of shared objects' associated to a boolean indicating whether they have already been serialized or not
      @shared_objs = {}
    end

    # Serialize the object
    #
    # Result::
    # * _String_: The object serialized
    def dump
      # First look for shared objects
      # Set of objects parsed, per object_id
      @objs = {}
      # Set of shared object_id, with a boolean indicating whether they have been serialized already or not
      @shared_objs = {}
      gather_ids_rec(@obj)
      @shared_objs_to_store = {}
      @shared_objs.each do |object_id, false_value|
        @shared_objs_to_store[object_id] = [
          @objs[object_id].class.name,
          serialize_rec(@objs[object_id], false)
        ]
      end
      #puts "Found #{@shared_objs_to_store.size} shared objects to be stored"
      return {
        'version' => 1,
        'obj' => serialize_rec(@obj),
        'shared_objs' => @shared_objs_to_store
      }.to_msgpack
    end

    private

    # Gather all shared objects in @shared_objs, tracking which ones have already been parsed in @objs.
    # Called recursively on all objects contained in obj.
    #
    # Parameters::
    # * *obj* (_Object_): The object to inspect
    def gather_ids_rec(obj)
      if ((!obj.is_a?(Fixnum)) and
          (!obj.is_a?(Bignum)) and
          (!obj.is_a?(Float)) and
          (!obj.is_a?(Symbol)) and
          (obj != nil) and
          (obj != true) and
          (obj != false))
        # Check if obj id is shared
        if (@objs[obj.object_id] == nil)
          # First time we encounter this object
          @objs[obj.object_id] = obj
          # See other references
          if (obj.is_a?(Array))
            obj.each_with_index do |item, idx|
              gather_ids_rec(item)
            end
          elsif (obj.is_a?(Hash))
            obj.each do |key, value|
              gather_ids_rec(value)
              gather_ids_rec(key)
            end
          else
            # TODO: Handle objects that will be serialized by to_msgpack
          end
        else
          # This object is shared.
          @shared_objs[obj.object_id] = false
        end
      end
    end

    # Serialize the object recursively (itself and all its descendants)
    #
    # Parameters::
    # * *obj* (_Object_): Object to serialize
    # * *check_shared* (_Boolean_): Do we check whether this object is shared? [default = true]
    # Result::
    # * _String_: The serialized object
    def serialize_rec(obj, check_shared = true)
      if ((obj.is_a?(Fixnum)) or
          (obj.is_a?(Bignum)) or
          (obj.is_a?(Float)) or
          (obj == nil) or
          (obj == true) or
          (obj == false))
        return obj.to_msgpack
      elsif (obj.is_a?(Symbol))
        # TODO (MessagePack): Remove this if MessagePack handles Symbols one day
        return {
          OBJECT_CLASSNAME_REFERENCE => SYMBOL_ID,
          OBJECT_CONTENT_REFERENCE => obj.to_s
        }.to_msgpack
      elsif (check_shared and
             (@shared_objs[obj.object_id] != nil))
        # This object is shared: store its object_id only
        return {
          OBJECT_ID_REFERENCE => obj.object_id
        }.to_msgpack
      elsif (obj.is_a?(Array))
        # First serialize its items
        return obj.map { |item| serialize_rec(item) }.to_msgpack
      elsif (obj.is_a?(Hash))
        # First serialize its items
        hash_to_store = {}
        obj.each do |key, value|
          hash_to_store[serialize_rec(key)] = serialize_rec(value)
        end
        return hash_to_store.to_msgpack
      else
        # Handle other objects
        return obj.to_msgpack
      end
    end

  end

end
