module RubySerialTest

  module TestCases

    # Test simple data types are serialized correctly
    class DataTypes < ::Test::Unit::TestCase

      extend Common::Helpers

      Common::DATA_SAMPLES.each do |data_type_name, var|

        # A single data
        def_test "single_#{data_type_name}" do
          assert_bijection var
        end

        # A single data in an Array
        def_test "array_#{data_type_name}" do
          array = [ var ]
          assert_bijection array
        end

        # A single data in a Hash as a key
        def_test "hash_key_#{data_type_name}" do
          hash = { var => 42 }
          assert_bijection hash
        end

        # A single data in a Hash as a value
        def_test "hash_value_#{data_type_name}" do
          hash = { 42 => var }
          assert_bijection hash
        end

      end

      def_test 'all_in_array' do
        array = Common::DATA_SAMPLES.values
        assert_bijection array
      end

      def_test 'all_in_hash_key' do
        hash = {}
        Common::DATA_SAMPLES.each do |var_name, var|
          hash[var] = var_name
        end
        assert_bijection hash
      end

      def_test 'all_in_hash_value' do
        hash = {}
        Common::DATA_SAMPLES.each do |var_name, var|
          hash[var_name] = var
        end
        assert_bijection hash
      end

      def_test 'all_in_object' do
        obj = Common::GenericContainer.new
        obj.fill(Common::DATA_SAMPLES)
        assert_bijection obj
      end

    end

  end

end
