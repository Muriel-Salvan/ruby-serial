module RubySerialTest

  module TestCases

    # Test user objects API
    class UserObjects < ::Test::Unit::TestCase

      extend Common::Helpers

      # By default all attributes are serialized
      class Serialized_All
        attr_accessor :attr1
        attr_accessor :attr2
        attr_accessor :attr3
        def initialize
          @attr1 = nil
          @attr2 = nil
          @attr3 = nil
        end
      end
      def_test 'all_attributes' do
        obj1 = Serialized_All.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal 1, obj2.attr1
        assert_equal 2, obj2.attr2
        assert_equal 3, obj2.attr3
      end

      # Don't serialize 1 attribute
      class Serialized_Except_1 < Serialized_All
        dont_rubyserial :attr2
      end
      def_test 'except_1' do
        obj1 = Serialized_Except_1.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal 1, obj2.attr1
        assert_equal nil, obj2.attr2
        assert_equal 3, obj2.attr3
      end

      # Don't serialize 2 attributes
      class Serialized_Except_2 < Serialized_All
        dont_rubyserial :attr2
        dont_rubyserial :attr1
      end
      def_test 'except_2' do
        obj1 = Serialized_Except_2.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal nil, obj2.attr1
        assert_equal nil, obj2.attr2
        assert_equal 3, obj2.attr3
      end

      # Don't serialize a list of attributes
      class Serialized_Except_List < Serialized_All
        dont_rubyserial :attr1, :attr2
      end
      def_test 'except_list' do
        obj1 = Serialized_Except_List.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal nil, obj2.attr1
        assert_equal nil, obj2.attr2
        assert_equal 3, obj2.attr3
      end

      # Serialize only 1 attribute
      class Serialized_Only_1 < Serialized_All
        rubyserial_only :attr2
      end
      def_test 'only_1' do
        obj1 = Serialized_Only_1.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal nil, obj2.attr1
        assert_equal 2, obj2.attr2
        assert_equal nil, obj2.attr3
      end

      # Serialize only 2 attributes
      class Serialized_Only_2 < Serialized_All
        rubyserial_only :attr2
        rubyserial_only :attr1
      end
      def_test 'only_2' do
        obj1 = Serialized_Only_2.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal 1, obj2.attr1
        assert_equal 2, obj2.attr2
        assert_equal nil, obj2.attr3
      end

      # Serialize only a list of attributes
      class Serialized_Only_List < Serialized_All
        rubyserial_only :attr1, :attr2
      end
      def_test 'only_list' do
        obj1 = Serialized_Only_List.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal 1, obj2.attr1
        assert_equal 2, obj2.attr2
        assert_equal nil, obj2.attr3
      end

      # Serialize only a list except some of attributes
      class Serialized_Only_Except_List < Serialized_All
        rubyserial_only :attr1, :attr2
        dont_rubyserial :attr1
      end
      def_test 'only_except_list' do
        obj1 = Serialized_Only_Except_List.new
        obj1.attr1 = 1
        obj1.attr2 = 2
        obj1.attr3 = 3
        obj2 = ruby_serial(obj1)
        assert_equal nil, obj2.attr1
        assert_equal 2, obj2.attr2
        assert_equal nil, obj2.attr3
      end

      # Serialize objects with a constructor having mandatory parameters
      def_test 'with_constructor' do
        obj1 = Common::DataContainerWithConstructor.new(256)
        obj2 = ruby_serial(obj1)
        assert_equal 256, obj2.attr1
      end

    end

  end

end
