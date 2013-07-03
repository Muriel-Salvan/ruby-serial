module RubySerialTest

  module TestCases

    # Test simple data types are serialized correctly
    class DataTypes < ::Test::Unit::TestCase

      Common::DATA_SAMPLES.each do |data_type_name, var|

        # A single data
        define_method("test_single_#{data_type_name}") do
          assert_equal var, RubySerial::load(RubySerial::dump(var))
        end

        # A single data in an Array
        define_method("test_array_#{data_type_name}") do
          array = [ var ]
          assert_equal array, RubySerial::load(RubySerial::dump(array))
        end

        # A single data in a Hash as a key
        define_method("test_hash_key_#{data_type_name}") do
          hash = { var => 42 }
          assert_equal hash, RubySerial::load(RubySerial::dump(hash))
        end

        # A single data in a Hash as a value
        define_method("test_hash_value_#{data_type_name}") do
          hash = { 42 => var }
          assert_equal hash, RubySerial::load(RubySerial::dump(hash))
        end

      end

      def test_all_in_array
        array = Common::DATA_SAMPLES.values
        assert_equal array, RubySerial::load(RubySerial::dump(array))
      end

      def test_all_in_hash_key
        hash = {}
        Common::DATA_SAMPLES.values.each do |var|
          hash[var] = rand
        end
        assert_equal hash, RubySerial::load(RubySerial::dump(hash))
      end

      def test_all_in_hash_value
        hash = {}
        Common::DATA_SAMPLES.values.each do |var|
          hash[var.object_id] = var
        end
        assert_equal hash, RubySerial::load(RubySerial::dump(hash))
      end

    end

  end

end
