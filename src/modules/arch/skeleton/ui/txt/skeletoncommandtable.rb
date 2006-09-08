
require 'lib/orderedhash.rb'
require 'lib/command.rb'


class SkeletonCommandTable < OrderedHash
	Test = 100
	Help = 199

	## Initialize command table. Insert the commands in the order they should
	## be displayed.
	def initialize
		super

		# test command with no parameters
		self['test'] = Command.new(
			[[/^\s*test\s*$/, Test]],
			[["",				"test command"]],
			[["",				"test command with no parameters"]])

		# the help command has no descriptions and will not show up on help
		# output
		self['help'] = Command.new(
			[[/^\s*help\s*$|(?:\s+)(\w+)?/, Help]])
	end
end
