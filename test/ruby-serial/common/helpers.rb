module RubySerialTest

  module Common

    # Location of the reference file
    REFERENCE_FILE = File.expand_path("#{File.dirname(__FILE__)}/../reference_file")

    # Serialized data containing the strings used for each test case (each call to ruby_serial helper)
    # map< Version, map< TestClassName, map< TestName, map< Index, SerializedData > > >
    @serialized_data = {}
    @nbr_missing_serialized_data = 0
    @generate_mode = false

    class << self
      attr_accessor :serialized_data
      attr_accessor :nbr_missing_serialized_data
      attr_accessor :generate_mode
    end

    # Set generate mode
    # When set, serialized data is written in files
    def self.set_generate_mode
      Common.generate_mode = true
    end

    # Read serialized data from disk
    def self.read_serialized_data
      if (File.exists?(REFERENCE_FILE))
        File.open(REFERENCE_FILE, 'rb') do |file|
          Common.serialized_data = MessagePack.unpack(file.read)
        end
      else
        puts "!!! Missing reference file: #{REFERENCE_FILE}"
      end
    end

    # Write serialized data to disk
    def self.write_serialized_data
      File.open(REFERENCE_FILE, 'wb') do |file|
        file.write(Common.serialized_data.to_msgpack)
      end
      # Puts some statistics
      puts ''
      Common.serialized_data.each do |version, serialized_data_for_version|
        size = 0
        serialized_data_for_version.each do |_, serialized_data_for_testclass|
          serialized_data_for_testclass.each do |_, serialized_data_for_test|
            serialized_data_for_test.each do |_, serialized_data|
              size += serialized_data.size
            end
          end
        end
        puts "Total bytes of serialized data for version #{version}: #{size}"
      end
      puts ''
      puts "Reference file #{REFERENCE_FILE} written"
    end

    module Helpers

      # Include everything necessary for helpers
      #
      # Parameters::
      # * *base* (_Class_): Base class
      def self.extended(base)
        base.class_eval('include InstanceHelpers')
      end

      # Method used to declare test cases
      # This will ensure that each test case is run for all versions
      #
      # Parameters::
      # * *name* (_String_): Test case name
      # * *&proc* (_Proc_): Code called for the test case
      def def_test(name, &proc)
        VERSIONS.each do |version|
          class_eval do
            define_method("test_#{name}_version_#{version}") do
              @version = version
              # The index of serialized data
              @serial_idx = 0
              # Get the map of serialized data
              Common.serialized_data[@version] = {} if (Common.serialized_data[@version] == nil)
              Common.serialized_data[@version][self.class.name] = {} if (Common.serialized_data[@version][self.class.name] == nil)
              Common.serialized_data[@version][self.class.name][@__name__] = {} if (Common.serialized_data[@version][self.class.name][@__name__] == nil)
              # map< Index, SerializedData >
              @testcase_serialized_data = Common.serialized_data[@version][self.class.name][@__name__]
              instance_eval(&proc)
            end
          end
        end
      end

    end

    module InstanceHelpers

      # Serialize and deserialize a variable.
      # Calls a code that tests the deserialized variable.
      # Also calls the test code with a variable deserialized from the disk if there is one.
      #
      # Parameters::
      # * *var* (_Object_): The variable to serialize and deserialize
      # * _Block_: The code called to test the resulting variable:
      #   * Parameters::
      #   * *deserialized_var* (_Object_): The deserialized variable
      # Result::
      # * _Object_: The resulting variable
      def ruby_serial(var)
        # Serialize/Deserialize variable
        serialized_data_from_now = RubySerial.dump(var, :version => @version)
        yield RubySerial.load(serialized_data_from_now)
        # Get the serialized variable from disk if it exists
        serialized_data_from_disk = @testcase_serialized_data[@serial_idx]
        if (serialized_data_from_disk == nil)
          Common.nbr_missing_serialized_data += 1
        else
          serialized_data_from_disk.force_encoding(Encoding::BINARY)
          # Serialized data can be different for the same object (depends in which order Hashes' keys are parsed)
          # Therefore we can't compare serialized data directly between reference file and a call to RubySerial::dump
          yield RubySerial.load(serialized_data_from_disk)
        end
        serialized_data = (Common.generate_mode || (serialized_data_from_disk == nil)) ? serialized_data_from_now : serialized_data_from_disk
        @testcase_serialized_data[@serial_idx] = serialized_data if Common.generate_mode
        @serial_idx += 1
      end

      # Assert that a variable is untouched by a serialize/deserialize chain
      #
      # Parameters::
      # * *var* (_Object_): The variable to serialize and deserialize
      def assert_bijection(var)
        ruby_serial(var) do |deserialized_var|
          assert_equal var, deserialized_var
        end
      end

    end

  end

end

module MiniTest

  class Unit

    # Run the test suite normally but execute some code before and after
    def run_with_rubyserial(args = [])
      # Read all serialized data from disk
      RubySerialTest::Common.read_serialized_data
      result = run_without_rubyserial(args)
      if RubySerialTest::Common.generate_mode
        RubySerialTest::Common.write_serialized_data
      elsif (RubySerialTest::Common.nbr_missing_serialized_data > 0)
        puts ''
        puts "!!! Number of serialized data missing from reference file: #{RubySerialTest::Common.nbr_missing_serialized_data}."
        puts 'Please use --generate-reference-file when invoking the complete test suite to write the reference file.'
        puts '!!! Do it ONLY if test suite is 100% success !!!'
        puts ''
      end
      result
    end
    alias_method :run_without_rubyserial, :run
    alias_method :run, :run_with_rubyserial

  end

end
