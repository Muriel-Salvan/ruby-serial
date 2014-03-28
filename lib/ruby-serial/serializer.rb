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
      serializer = nil
      begin
        require "ruby-serial/versions/#{@version}/serializer"
        serializer = RubySerial::Serializer::Versions.const_get("Version#{@version}")::Serializer.new
      rescue
        raise "Unknown serializer version #{@version}: #{$ERROR_INFO}"
      end

      "#{@version}\x00#{serializer.pack_data(@obj)}".force_encoding(Encoding::BINARY)
    end

  end

end
