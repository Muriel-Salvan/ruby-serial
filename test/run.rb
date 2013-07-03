require 'test/unit'

root_path = File.expand_path("#{File.dirname(__FILE__)}/..")

# Add the test directory to the current load path
$: << "#{root_path}/test"
# And the lib one too
$: << "#{root_path}/lib"

# Require the main library
require 'ruby-serial'

# Load test files to execute
require 'ruby-serial/common/helpers'
require 'ruby-serial/common/data_samples'
require 'ruby-serial/testcases/data_types'
require 'ruby-serial/testcases/objects_sharing'
