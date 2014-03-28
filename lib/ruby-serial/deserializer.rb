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

      deserializer = nil
      begin
        require "ruby-serial/versions/#{version}/deserializer"
        deserializer = eval("RubySerial::Deserializer::Versions::Version_#{version}")::Deserializer.new
      rescue
        raise "Unknown deserializer version #{version}. Please use a most recent version of RubySerial to decode your data. #{$!}"
      end

      deserializer.unpack_data(data)
    end

  end

end
