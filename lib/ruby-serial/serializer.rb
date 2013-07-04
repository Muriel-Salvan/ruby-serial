module RubySerial

  class Serializer

    # Default encoding version (should be the last one)
    DEFAULT_VERSION = '1'

    # Constructor
    #
    # Parameters::
    # * *obj* (_Object_): Ruby object to serialize
    # * *options* (<em>map<Symbol,Object></em>): Options [default = {}]
    #   * *:version* (_String_): The version to be used to encode
    def initialize(obj, options = {})
      @version = (options[:version] || DEFAULT_VERSION)
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
      pack_method_name = "pack_data_version_#{@version}".to_sym
      raise "Unknown version #{@version}." if (!self.respond_to?(pack_method_name))

      return "#{@version}\x00#{self.send(pack_method_name)}"
    end

    protected

    # Get data for version 1
    #
    # Result::
    # * <em>map<Symbol,Object></em>: The data to serialize
    def pack_data_version_1
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
          get_msgpack_compatible_rec(@objs[object_id], false)
        ]
      end
      #puts "Found #{@shared_objs_to_store.size} shared objects to be stored"
      return {
        'obj' => get_msgpack_compatible_rec(@obj),
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
            # Handle other objects
            obj.get_instance_vars_to_rubyserial.each do |var_name, var|
              gather_ids_rec(var)
            end
          end
        else
          # This object is shared.
          @shared_objs[obj.object_id] = false
        end
      end
    end

    # Convert the object (and all its descendants) to be serializable using to_msgpack without loosing information.
    #
    # Parameters::
    # * *obj* (_Object_): Object to convert
    # * *check_shared* (_Boolean_): Do we check whether this object is shared? [default = true]
    # Result::
    # * _Object_: The object ready to be serialized
    def get_msgpack_compatible_rec(obj, check_shared = true)
      if ((obj.is_a?(Fixnum)) or
          (obj.is_a?(Bignum)) or
          (obj.is_a?(Float)) or
          (obj == nil) or
          (obj == true) or
          (obj == false))
        return obj
      elsif (obj.is_a?(Symbol))
        # TODO (MessagePack): Remove this if MessagePack handles Symbols one day
        return {
          OBJECT_CLASSNAME_REFERENCE => SYMBOL_ID,
          OBJECT_CONTENT_REFERENCE => obj.to_s
        }
      elsif (check_shared and
             (@shared_objs[obj.object_id] != nil))
        # This object is shared: store its object_id only
        return {
          OBJECT_ID_REFERENCE => obj.object_id
        }
      elsif (obj.is_a?(Array))
        # First serialize its items
        return obj.map { |item| get_msgpack_compatible_rec(item) }
      elsif (obj.is_a?(Hash))
        # First serialize its items
        hash_to_store = {}
        obj.each do |key, value|
          hash_to_store[get_msgpack_compatible_rec(key)] = get_msgpack_compatible_rec(value)
        end
        return hash_to_store
      elsif (obj.is_a?(String))
        return obj
      else
        # Handle other objects
        serialized_instance_vars = {}
        obj.get_instance_vars_to_rubyserial.each do |var_name, value|
          serialized_instance_vars[var_name] = get_msgpack_compatible_rec(value)
        end
        return {
          OBJECT_CLASSNAME_REFERENCE => obj.class.name,
          OBJECT_CONTENT_REFERENCE => serialized_instance_vars
        }
      end
    end

  end

end
