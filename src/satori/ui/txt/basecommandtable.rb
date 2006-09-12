
require 'lib/orderedhash'
require 'lib/command'


class BaseCommandTable < OrderedHash
	## Initialize the command table with the standard commands.
	def initialize
		super

		self['cls'] = Command.new(
			[[/^\s*cls\s*$/,	"clear_screen"]],
			[["",				"clear screen"]],
			[["",				"clear screen"]])

		self['module'] = Command.new(
			[[/^\s*module\s*$/,	"show_module"],
			 [/^\s*module\s+(\w+)\s*$/, "load_module"]],
			[["[module_name]",	"show/load modules"]],
			[["",				"show available modules"],
			 ["<module_name>",	"load module <module_name>"]])
		
		self['help'] = Command.new(
			[[/^\s*help(?:\s*$|(\s+\w+\s*)?$)/, "help"]],
			[["[command]",		"display help"]],
			[["",				"display brief help on all commands"],
			 ["<command>",		"display detailed help on <command>"]])

		self['quit'] = Command.new(
			[[/^\s*quit\s*$/,	"quit"]],
			[["",				"terminate program"]],
			[["",				"terminate program"]])
	end
end
