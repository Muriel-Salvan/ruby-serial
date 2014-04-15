require 'English'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'coveralls'
Coveralls.wear!
require 'test/unit'

generate_reference_file = ARGV.delete('--generate-reference-file')

root_path = File.expand_path("#{File.dirname(__FILE__)}/..")

# Add the test directory to the current load path
$LOAD_PATH << "#{root_path}/test"
# And the lib one too
$LOAD_PATH << "#{root_path}/lib"

# Require the main library
require 'ruby-serial'

# Load test files to execute
require 'ruby-serial/common/helpers'
require 'ruby-serial/common/data_samples'
require 'ruby-serial/testcases/data_types'
require 'ruby-serial/testcases/objects_sharing'
require 'ruby-serial/testcases/user_objects'

# If the script is invoked with --generate-reference-file, we generate files storing serialized data
RubySerialTest::Common.set_generate_mode if generate_reference_file
