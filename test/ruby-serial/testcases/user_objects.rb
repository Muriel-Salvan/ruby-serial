module RubySerialTest

  module TestCases

    # Test user objects API
    class UserObjects < ::Test::Unit::TestCase

      extend Common::Helpers

      # By default all attributes are serialized
      class SerializedAll

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
        obj1 = SerializedAll.new
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
      class SerializedExcept1 < SerializedAll
        dont_rubyserial :attr2
      end
      def_test 'except_1' do
        obj1 = SerializedExcept1.new
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
      class SerializedExcept2 < SerializedAll
        dont_rubyserial :attr2
        dont_rubyserial :attr1
      end
      def_test 'except_2' do
        obj1 = SerializedExcept2.new
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
      class SerializedExceptList < SerializedAll
        dont_rubyserial :attr1, :attr2
      end
      def_test 'except_list' do
        obj1 = SerializedExceptList.new
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
      class SerializedOnly1 < SerializedAll
        rubyserial_only :attr2
      end
      def_test 'only_1' do
        obj1 = SerializedOnly1.new
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
      class SerializedOnly2 < SerializedAll
        rubyserial_only :attr2
        rubyserial_only :attr1
      end
      def_test 'only_2' do
        obj1 = SerializedOnly2.new
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
      class SerializedOnlyList < SerializedAll
        rubyserial_only :attr1, :attr2
      end
      def_test 'only_list' do
        obj1 = SerializedOnlyList.new
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
      class SerializedOnlyExceptList < SerializedAll
        rubyserial_only :attr1, :attr2
        dont_rubyserial :attr1
      end
      def_test 'only_except_list' do
        obj1 = SerializedOnlyExceptList.new
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
      class SerializedInheritance < Common::DataContainer

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
        obj1 = SerializedInheritance.new
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
