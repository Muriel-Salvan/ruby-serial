module RubySerial

  # Deserialize data previously serialized using Serializer
  class Deserializer

    # Constructor
    #
    # Parameters::
    # * *data* (_String_): Serialized data
    def initialize(data)
      @data = data
    end

    # Load the serialized object
    #
    # Result::
    # * _Object_: The deserialized object
    def load
      data = MessagePack::unpack(@data)
      unpack_method_name = "unpack_data_version_#{data['version']}".to_sym
      raise "Unknown version #{data['version']}. Please use a most recent version of RubySerial to decode your data." if (!self.respond_to?(unpack_method_name))
      return self.send(unpack_method_name, data)
    end

    protected

    # Unpack data for version 1
    #
    # Parameters::
    # * *data* (<em>map<Symbol,Object></em>): Data to deserialize
    # Result::
    # * _Object_: The unpacked data
    def unpack_data_version_1(data)
      if (data['shared_objs'].empty?)
        return deserialize_rec(data['obj'])
      else
        # We need to replace some data before
        @serialized_shared_objs = data['shared_objs']
        @decoded_shared_objs = {}
        return deserialize_rec(data['obj'])
      end
    end

    private

    # Deserialize recursively a serialized object
    #
    # Parameters::
    # * *obj* (_String_): The serialized object
    # * *container_to_fill* (_Object_): The container to fill with the decoded data. If nil, a new object will be created. [default = nil]
    # Result::
    # * _Object_: The deserialized object
    def deserialize_rec(obj, container_to_fill = nil)
      decoded_obj = MessagePack::unpack(obj)
      #puts "Decoded: #{decoded_obj.inspect}"
      if (decoded_obj.is_a?(Array))
        if (container_to_fill == nil)
          return decoded_obj.map { |item| deserialize_rec(item) }
        else
          decoded_obj.each do |item|
            container_to_fill << deserialize_rec(item)
          end
          return container_to_fill
        end
      elsif (decoded_obj.is_a?(Hash))
        # Check for special hashes
        if (decoded_obj[OBJECT_ID_REFERENCE] == nil)
          if (decoded_obj[OBJECT_CLASSNAME_REFERENCE] == SYMBOL_ID)
            return decoded_obj[OBJECT_CONTENT_REFERENCE].to_sym
          elsif (decoded_obj[OBJECT_CLASSNAME_REFERENCE] == nil)
            # Normal hash
            hash_obj = ((container_to_fill == nil) ? {} : container_to_fill)
            decoded_obj.each do |serialized_key, serialized_value|
              hash_obj[deserialize_rec(serialized_key)] = deserialize_rec(serialized_value)
            end
            return hash_obj
          else
            # TODO: Handle instantiating
            raise 'TODO'
          end
        else
          # We have a reference to a shared object
          obj_id = decoded_obj[OBJECT_ID_REFERENCE]
          if (@decoded_shared_objs[obj_id] == nil)
            # Instantiate it already for cyclic decoding (avoids infinite loops)
            @decoded_shared_objs[obj_id] = eval(@serialized_shared_objs[obj_id][0]).new
            deserialize_rec(@serialized_shared_objs[obj_id][1], @decoded_shared_objs[obj_id])
          end
          return @decoded_shared_objs[obj_id]
        end
      elsif (container_to_fill == nil)
        # Should be only String
        return decoded_obj
      else
        # Should be only String
        container_to_fill.replace(decoded_obj)
        return container_to_fill
      end
    end

  end

end
