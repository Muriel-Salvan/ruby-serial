module RubySerial

  # Deserialize data previously serialized using Serializer
  class Deserializer

    # Constructor
    #
    # Parameters::
    # * *data* (_String_): Serialized data (should be BINARY encoding only)
    def initialize(data)
      @data = data
    end

    # Load the serialized object
    #
    # Result::
    # * _Object_: The deserialized object
    def load
      # Find the version
      idx_data_separator = @data.index("\x00")
      raise 'Unknown format of data. It appears this data has not been serialized using RubySerial.' if (idx_data_separator == nil)
      version = @data[0..idx_data_separator-1]
      data = @data[idx_data_separator+1..-1]
      unpack_method_name = "unpack_data_version_#{version}".to_sym
      raise "Unknown version \"#{version}\". Please use a most recent version of RubySerial to decode your data." if (!self.respond_to?(unpack_method_name))
      return self.send(unpack_method_name, data)
    end

    protected

    # Unpack data for version 1
    #
    # Parameters::
    # * *data* (_String_): Data to deserialize
    # Result::
    # * _Object_: The unpacked data
    def unpack_data_version_1(data)
      decoded_data = MessagePack::unpack(data)
      if (decoded_data['shared_objs'].empty?)
        return get_original_rec(decoded_data['obj'])
      else
        # We need to replace some data before
        @serialized_shared_objs = decoded_data['shared_objs']
        @decoded_shared_objs = {}
        return get_original_rec(decoded_data['obj'])
      end
    end

    private

    # Convert back a deserialized object using MessagePack to the original object
    #
    # Parameters::
    # * *obj* (_Object_): The decoded object
    # * *container_to_fill* (_Object_): The container to fill with the decoded data. If nil, a new object will be created. [default = nil]
    # Result::
    # * _Object_: The original object
    def get_original_rec(decoded_obj, container_to_fill = nil)
      if (decoded_obj.is_a?(Array))
        if (container_to_fill == nil)
          return decoded_obj.map { |serialized_item| get_original_rec(serialized_item) }
        else
          decoded_obj.each do |item|
            container_to_fill << get_original_rec(item)
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
              hash_obj[get_original_rec(serialized_key)] = get_original_rec(serialized_value)
            end
            return hash_obj
          else
            # We deserialize a home-made object
            # Instantiate the needed class
            new_obj = ((container_to_fill == nil) ? eval(decoded_obj[OBJECT_CLASSNAME_REFERENCE]).new : container_to_fill)
            instance_vars = {}
            decoded_obj[OBJECT_CONTENT_REFERENCE].each do |var_name, serialized_value|
              instance_vars[var_name] = get_original_rec(serialized_value)
            end
            new_obj.set_instance_vars_from_rubyserial(instance_vars)
            return new_obj
          end
        else
          # We have a reference to a shared object
          obj_id = decoded_obj[OBJECT_ID_REFERENCE]
          if (@decoded_shared_objs[obj_id] == nil)
            # Instantiate it already for cyclic decoding (avoids infinite loops)
            @decoded_shared_objs[obj_id] = eval(@serialized_shared_objs[obj_id][0]).new
            get_original_rec(@serialized_shared_objs[obj_id][1], @decoded_shared_objs[obj_id])
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
