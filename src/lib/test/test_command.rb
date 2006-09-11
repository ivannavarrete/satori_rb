
$:.unshift File.join(File.dirname(__FILE__), "..")

require 'English'
require 'test/unit'
require 'command'


class TestCommand < Test::Unit::TestCase
	CommandType = 1
	CommandType2 = 2

	def test_parse_no_arg
		command = Command.new([[/^\s*test\s*$/, CommandType]])
		
		assert_equal(CommandType, command.parse("test"))
		assert_equal(CommandType, command.parse(" \t \n  test\t\n  "))
		
		assert_nil(command.parse(""))
		assert_nil(command.parse("t"))
		assert_nil(command.parse("test foo"))
		assert_nil(command.parse("foo test"))
	end

	def test_parse_one_arg
		command = Command.new([[/^\s*test\s+(\w+)\s*$/, CommandType]])
		
		assert_equal(CommandType, command.parse("test foo"))
		assert_equal(CommandType, command.type)
		assert_equal(["foo"], command.arguments)
		
		assert_equal(CommandType, command.parse(" \t\ntest \t\nfoo"))
		assert_equal(CommandType, command.type)
		assert_equal(["foo"], command.arguments)
		
		assert_nil(command.parse("test foo bar"))
	end

	def test_parse_different_types
		# order of regular exp is important since second also catches numbers
		command = Command.new(
			[[/^\s*test\s+(\d+)\s*$/, CommandType],
			 [/^\s*test\s+(\w+)\s*$/, CommandType2]])

		assert_equal(CommandType, command.parse("test 123"))
		assert_equal(CommandType, command.type)
		assert_equal(["123"], command.arguments)

		assert_equal(CommandType2, command.parse("test foo"))
		assert_equal(CommandType2, command.type)
		assert_equal(["foo"], command.arguments)
	end
end
