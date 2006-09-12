
require 'lib/orderedhash.rb'
require 'lib/command.rb'


class SkeletonCommandTable < OrderedHash
	## Initialize command table. Insert the commands in the order they should
	## be displayed by the 'help' command.
	def initialize
		super

		# test command with no parameters
		self['test'] = Command.new(
			[[/^\s*test\s*$/,	"test"]],
			[["",				"test command"]],
			[["",				"test command with no parameters"]])

		# the help command has no descriptions and will not show up on help
		# display
		self['help'] = Command.new([[/^\s*help\s*$|(?:\s+)(\w+)?/, "help"]])
	end
end
