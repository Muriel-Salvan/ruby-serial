module RubySerialTest

  module Common

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
          self.class_eval do
            define_method("test_#{name}_version_#{version}") do
              @version = version
              self.instance_eval(&proc)
            end
          end
        end
      end

    end

    module InstanceHelpers

      # Serialize and deserialize a variable
      #
      # Parameters::
      # * *var* (_Object_): The variable to serialize and deserialize
      # Result::
      # * _Object_: The resulting variable
      def ruby_serial(var)
        return RubySerial::load(RubySerial::dump(var, :version => @version))
      end

    end

  end

end
