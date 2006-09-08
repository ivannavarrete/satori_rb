
require 'ui/txt/skeletoncommandtable'
require 'lib/txtui'


class SkeletonTxtUi < TxtUi

	def initialize
		@command_table = SkeletonCommandTable.new
	end

	def exec(command_line)
		return false unless command = parse_command(command_line)

		# write a clause for each command type in the command table
		case (command.type)
		when SkeletonCommandTable::Test:		commant_test(command)
		when SkeletonCommandTable::Help:		command_help(command)

		# raise an exception if there is a command in the command table that
		# isn't handled by one of the above clauses; this should be a fatal
		# error
		else raise NotImplementedError, "Command found but not implemented"
		end

		true
	end

private
	def test(command)
		message("test command")
	end

	def command_help(command)
		if command.arguments[0] == nil
			message("--[ Skeleton Architecture commands ]--")
		end
		super
	end
end
