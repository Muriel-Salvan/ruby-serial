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
        ruby_serial(obj1) do |obj2|
          assert_equal 1, obj2.attr1
          assert_equal 2, obj2.attr2
          assert_equal 3, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal 1, obj2.attr1
          assert_equal nil, obj2.attr2
          assert_equal 3, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal nil, obj2.attr1
          assert_equal nil, obj2.attr2
          assert_equal 3, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal nil, obj2.attr1
          assert_equal nil, obj2.attr2
          assert_equal 3, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal nil, obj2.attr1
          assert_equal 2, obj2.attr2
          assert_equal nil, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal 1, obj2.attr1
          assert_equal 2, obj2.attr2
          assert_equal nil, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal 1, obj2.attr1
          assert_equal 2, obj2.attr2
          assert_equal nil, obj2.attr3
        end
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
        ruby_serial(obj1) do |obj2|
          assert_equal nil, obj2.attr1
          assert_equal 2, obj2.attr2
          assert_equal nil, obj2.attr3
        end
      end

      # Serialize objects with a constructor having mandatory parameters
      def_test 'with_constructor' do
        obj1 = Common::DataContainerWithConstructor.new(256)
        ruby_serial(obj1) do |obj2|
          assert_equal 256, obj2.attr1
        end
      end

      # Serialize inherited attributes
      class Serialized_Inheritance < Common::DataContainer
        attr_accessor :attr4
        attr_accessor :attr5
        attr_accessor :attr6
        def initialize
          super
          @attr4 = 42
          @attr5 = 'A new string again'
          @attr6 = nil
        end
        def to_a
          super + [@attr4, @attr5, @attr6]
        end
      end
      def_test 'with_inheritance' do
        obj1 = Serialized_Inheritance.new
        ruby_serial(obj1) do |obj2|
          assert_equal obj1, obj2
        end
      end

      # Serialize objects with an ondump method
      def_test 'with_ondump' do
        obj1 = Common::DataContainerWithOnDump.new
        ruby_serial(obj1) do |obj2|
          assert_equal obj1, obj2
          assert_equal true, obj1.ondump_called?
        end
      end

      # Serialize objects with an onload method
      def_test 'with_onload' do
        obj1 = Common::DataContainerWithOnLoad.new
        ruby_serial(obj1) do |obj2|
          assert_equal obj1, obj2
          assert_equal false, obj1.onload_called?
          assert_equal true, obj2.onload_called?
          assert_equal obj1.instance_variables, obj2.loaded_vars
        end
      end

    end

  end

end
