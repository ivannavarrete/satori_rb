
require 'lib/orderedhash'
require 'lib/command'


class BaseCommandTable < OrderedHash
	Quit = 1
	ShowModule = 2
	LoadModule = 3
	ClearScreen = 4
	Help = 5

	## Initialize the command table with the standard commands.
	def initialize
		super

		self['cls'] = Command.new(
			[[/^\s*cls\s*$/,	ClearScreen]],
			[["",				"clear screen"]],
			[["",				"clear screen"]])

		self['module'] = Command.new(
			[[/^\s*module\s*$/,	ShowModule],
			 [/^\s*module\s+(\w+)\s*$/, LoadModule]],
			[["[module_name]",	"show/load modules"]],
			[["",				"show available modules"],
			 ["<module_name>",	"load module <module_name>"]])
		
		self['help'] = Command.new(
			[[/^\s*help(?:\s*$|(\s+\w+\s*)?$)/, Help]],
			[["[command]",		"display help"]],
			[["",				"display brief help on all commands"],
			 ["<command>",		"display detailed help on <command>"]])

		self['quit'] = Command.new(
			[[/^\s*quit\s*$/,	Quit]],
			[["",				"terminate program"]],
			[["",				"terminate program"]])
	end
end
