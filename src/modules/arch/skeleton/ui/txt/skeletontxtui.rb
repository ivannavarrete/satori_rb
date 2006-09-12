
require 'lib/ui/txt/txtui'
require 'ui/txt/skeletoncommandtable'


class SkeletonTxtUi < TxtUi
	def initialize
		@command_table = SkeletonCommandTable.new
	end

private
	def command_test(command)
		message("test command")
	end

	def command_help(command)
		if command.arguments[0] == nil
			message("--[ Skeleton Architecture commands ]--")
		end
		super
	end
end
