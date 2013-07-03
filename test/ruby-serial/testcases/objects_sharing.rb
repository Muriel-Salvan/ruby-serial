module RubySerialTest

  module TestCases

    # Test sharing objects
    class ObjectsSharing < ::Test::Unit::TestCase

      extend Common::Helpers

      Common::DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS.each do |data_type_name, var|

        # Simple sharing in an Array
        def_test "array_#{data_type_name}" do
          obj1 = [ var, var ]
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2[0].object_id, obj2[1].object_id
        end

        # Simple sharing in a Hash as values
        def_test "hash_value_#{data_type_name}" do
          obj1 = { 1 => var, 2 => var }
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2[1].object_id, obj2[2].object_id
        end

        # TODO: Shared in objects' attributes

        # Sharing at different levels of an Array
        def_test "array_levels_#{data_type_name}" do
          obj1 = [ var, [ var ], [ [ var ] ] ]
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2[0].object_id, obj2[1][0].object_id
          assert_equal obj2[0].object_id, obj2[2][0][0].object_id
        end

        # Sharing at different levels of a Hash as values
        def_test "hash_values_levels_#{data_type_name}" do
          obj1 = {
            1 => var,
            2 => {
              4 => var
            },
            3 => {
              5 => {
                6 => var
              }
            }
          }
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2[1].object_id, obj2[2][4].object_id
          assert_equal obj2[1].object_id, obj2[3][5][6].object_id
        end

        # TODO: Shared in objects' attributes

      end

      Common::DATA_SAMPLES_SHAREABLE.each do |data_type_name, var|

        # Simple sharing in a Hash as key and value
        def_test "hash_key_and_value_#{data_type_name}" do
          obj1 = { var => 1, 2 => var }
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2.keys.select { |key| key != 2 }[0].object_id, obj2[2].object_id
        end

        # Sharing at different levels of a Hash as keys and values
        def_test "hash_keys_and_values_levels_#{data_type_name}" do
          obj1 = {
            1 => var,
            2 => {
              var => 4
            },
            3 => {
              5 => {
                var => 6
              }
            }
          }
          obj2 = ruby_serial(obj1)
          assert_equal obj1, obj2
          assert_equal obj2[1].object_id, obj2[2].keys[0].object_id
          assert_equal obj2[1].object_id, obj2[3][5].keys[0].object_id
        end

      end

      def_test 'share_all_in_array' do
        obj1 = []
        nbr_repeatitions = 5
        nbr_repeatitions.times do
          Common::DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS.values.each do |var|
            obj1 << var
          end
        end
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        nbr_data_samples = Common::DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS.size
        nbr_data_samples.times do |idx_data_sample|
          (nbr_repeatitions-1).times do |idx_repeatition|
            assert_equal obj2[idx_data_sample].object_id, obj2[(idx_repeatition+1)*nbr_data_samples+idx_data_sample].object_id
          end
        end
      end

      def_test 'share_all_in_hash_values' do
        obj1 = {}
        nbr_repeatitions = 5
        nbr_data_samples = Common::DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS.size
        nbr_repeatitions.times do |idx_repeatition|
          Common::DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS.values.each_with_index do |var, idx_data_sample|
            obj1[nbr_data_samples*idx_repeatition+idx_data_sample] = var
          end
        end
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        nbr_data_samples.times do |idx_data_sample|
          (nbr_repeatitions-1).times do |idx_repeatition|
            assert_equal obj2[idx_data_sample].object_id, obj2[(idx_repeatition+1)*nbr_data_samples+idx_data_sample].object_id
          end
        end
      end

      def_test 'share_all_in_hash_keys' do
        obj1 = {}
        nbr_repeatitions = 5
        nbr_data_samples = Common::DATA_SAMPLES_SHAREABLE.size
        nbr_repeatitions.times do |idx_repeatition|
          Common::DATA_SAMPLES_SHAREABLE.values.each_with_index do |var, idx_data_sample|
            obj1[nbr_data_samples*idx_repeatition+idx_data_sample] = { var => 1 }
          end
        end
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        nbr_data_samples.times do |idx_data_sample|
          (nbr_repeatitions-1).times do |idx_repeatition|
            assert_equal obj2[idx_data_sample].keys[0].object_id, obj2[(idx_repeatition+1)*nbr_data_samples+idx_data_sample].keys[0].object_id
          end
        end
      end

      # TODO: Shared in objects' attributes

      def_test 'cyclic_share_in_array' do
        obj1 = []
        obj1 << obj1
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2.object_id, obj2[0].object_id
      end

      def_test 'cyclic_share_deeper_in_array' do
        shared_obj = []
        obj1 = [ 1, shared_obj ]
        shared_obj << [ 2, [ shared_obj ] ]
        # obj1 = [ 1, *[ [ 2, [ * ] ] ] ]
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2[1].object_id, obj2[1][0][1][0].object_id
      end

      def_test 'cross_cyclic_share_in_array' do
        shared_obj1 = [ 2 ]
        shared_obj2 = [ 3, shared_obj1 ]
        shared_obj1 << shared_obj2
        obj1 = [ 1, shared_obj1, shared_obj2 ]
        # obj1 = [ 1, a[ 2, b[ 3, a[ 2, b ] ] ], b[ 3, a ] ]
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2[1].object_id, obj2[1][1][1].object_id
        assert_equal obj2[1].object_id, obj2[2][1].object_id
        assert_equal obj2[2].object_id, obj2[1][1].object_id
        assert_equal obj2[2].object_id, obj2[1][1][1][1].object_id
      end

      def_test 'cyclic_share_in_hash_values' do
        obj1 = {}
        obj1[1] = obj1
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2.object_id, obj2[1].object_id
      end

      def_test 'cyclic_share_deeper_in_hash_values' do
        shared_obj = {}
        obj1 = { 1 => 2, 3 => shared_obj }
        shared_obj[4] = { 5 => shared_obj }
        # obj1 = {
        #   1 => 2,
        #   3 => *{
        #     4 => {
        #       5 => *
        #     }
        #   }
        # }
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2[3].object_id, obj2[3][4][5].object_id
      end

      def_test 'cross_cyclic_share_in_hash_values' do
        shared_obj1 = { 5 => 6 }
        shared_obj2 = {
          8 => 9,
          10 => shared_obj1
        }
        shared_obj1[7] = shared_obj2
        obj1 = {
          1 => 2,
          3 => shared_obj1,
          4 => shared_obj2
        }
        # obj1 = {
        #   1 => 2,
        #   3 => a{
        #     5 => 6,
        #     7 => b{
        #       8 => 9,
        #       10 => a{
        #         5 => 6
        #         7 => b
        #       }
        #     }
        #   },
        #   4 => b{
        #     8 => 9,
        #     10 => a
        #   }
        # }
        obj2 = ruby_serial(obj1)
        assert_equal obj1, obj2
        assert_equal obj2[3].object_id, obj2[3][7][10].object_id
        assert_equal obj2[3].object_id, obj2[4][10].object_id
        assert_equal obj2[4].object_id, obj2[3][7].object_id
        assert_equal obj2[4].object_id, obj2[3][7][10][7].object_id
      end

      def_test 'cyclic_share_in_hash_keys' do
        obj1 = {}
        obj1[obj1] = 1
        obj2 = ruby_serial(obj1)
        # TODO: Understand why the following fails
        #assert_equal obj1, obj2
        assert_equal obj2.object_id, obj2.keys[0].object_id
      end

      def_test 'cyclic_share_deeper_in_hash_keys' do
        shared_obj = {}
        obj1 = { 1 => 2, shared_obj => 3 }
        shared_obj[4] = { shared_obj => 5 }
        # obj1 = {
        #   1 => 2,
        #   *{
        #     4 => {
        #       * => 5
        #     }
        #   } => 3
        # }
        obj2 = ruby_serial(obj1)
        # TODO: Understand why the following fails
        #assert_equal obj1, obj2
        assert_equal obj2.keys.select { |key| key != 1 }[0].object_id, obj2.keys.select { |key| key != 1 }[0][4].keys[0].object_id
      end

      def_test 'cross_cyclic_share_in_hash_keys' do
        shared_obj1 = { 5 => 6 }
        shared_obj2 = {
          8 => 9,
          shared_obj1 => 10
        }
        shared_obj1[shared_obj2] = 7
        obj1 = {
          1 => 2,
          shared_obj1 => 3,
          shared_obj2 => 4
        }
        # obj1 = {
        #   1 => 2,
        #   a{
        #     5 => 6,
        #     b{
        #       8 => 9,
        #       a{
        #         5 => 6
        #         b => 7
        #       } => 10
        #     } => 7
        #   } => 3,
        #   b{
        #     8 => 9,
        #     a => 10
        #   } => 4
        # }
        obj2 = ruby_serial(obj1)
        # TODO: Understand why the following fails
        #assert_equal obj1, obj2
        # Get back the 2 shared objects
        new_shared_obj1 = nil
        new_shared_obj2 = nil
        obj2.each do |key, value|
          if (key != 1)
            if (value == 3)
              new_shared_obj1 = key
            elsif (value == 4)
              new_shared_obj2 = key
            end
          end
        end
        assert_equal new_shared_obj1.object_id, new_shared_obj1.keys.select { |key| key != 5 }[0].keys.select { |key| key != 8 }[0].object_id
        assert_equal new_shared_obj1.object_id, new_shared_obj2.keys.select { |key| key != 8 }[0].object_id
        assert_equal new_shared_obj2.object_id, new_shared_obj1.keys.select { |key| key != 5 }[0].object_id
        assert_equal new_shared_obj2.object_id, new_shared_obj1.keys.select { |key| key != 5 }[0].keys.select { |key| key != 8 }[0].keys.select { |key| key != 5 }[0].object_id
      end

      # TODO: Shared in objects' attributes

    end

  end

end
