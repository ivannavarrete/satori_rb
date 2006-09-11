
# Find and run all unit tests. Unit tests are scattered in subdirectories of
# src/ and are files matching test_*.rb.
require 'English'

Dir.chdir(File.join(File.dirname(__FILE__), ".."))
Dir.glob("**/test_*.rb") { |test_file| require test_file }
