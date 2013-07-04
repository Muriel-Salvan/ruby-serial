module RubySerialTest

  module TestCases

    # Test simple data types are serialized correctly
    class DataTypes < ::Test::Unit::TestCase

      extend Common::Helpers

      Common::DATA_SAMPLES.each do |data_type_name, var|

        # A single data
        def_test "single_#{data_type_name}" do
          assert_equal var, ruby_serial(var)
        end

        # A single data in an Array
        def_test "array_#{data_type_name}" do
          array = [ var ]
          assert_equal array, ruby_serial(array)
        end

        # A single data in a Hash as a key
        def_test "hash_key_#{data_type_name}" do
          hash = { var => 42 }
          assert_equal hash, ruby_serial(hash)
        end

        # A single data in a Hash as a value
        def_test "hash_value_#{data_type_name}" do
          hash = { 42 => var }
          assert_equal hash, ruby_serial(hash)
        end

      end

      def_test 'all_in_array' do
        array = Common::DATA_SAMPLES.values
        assert_equal array, ruby_serial(array)
      end

      def_test 'all_in_hash_key' do
        hash = {}
        Common::DATA_SAMPLES.values.each do |var|
          hash[var] = rand
        end
        assert_equal hash, ruby_serial(hash)
      end

      def_test 'all_in_hash_value' do
        hash = {}
        Common::DATA_SAMPLES.values.each do |var|
          hash[var.object_id] = var
        end
        assert_equal hash, ruby_serial(hash)
      end

      def_test 'all_in_object' do
        obj = Common::GenericContainer.new
        obj.fill(Common::DATA_SAMPLES)
        assert_equal obj, ruby_serial(obj)
      end

    end

  end

end
