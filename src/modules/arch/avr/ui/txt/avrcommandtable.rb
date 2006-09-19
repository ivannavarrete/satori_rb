
require 'lib/orderedhash'
require 'lib/command'


class AvrCommandTable < OrderedHash
	def initialize
		super

		# device [device_name | list | info]
		self['device'] = Command.new(
			[[/^\s*device\s*$/,				"get_device"],
			 [/^\s*device\s+info\s*$/,		"get_device_info"],
			 [/^\s*device\s+list\s*$/,		"get_device_list"],
			 [/^\s*device\s+(\w+)\s*$/,		"set_device"]],
			[["[device_name | list | info]","load device / get device info"]],
			[["",							"display selected AVR device"],
			 ["list",						"list all available devices"],
			 ["info",						"get info on loaded device"],
			 ["<device_name>",				"load device"]])

		# c <start_addr> [end_addr]
		self['c'] = Command.new(
			[[/^\s*c\s+(\d+)(?:\s*$|(\s+\d+)?$)/, "get_code"]],
			[["<start_addr> [end_addr]",	"show disassembled code"]],
			[["<start_addr>",				"display 64 words of code"],
			 ["<start_addr> <end_addr>",	"disassemble memory starting at "\
			 								"<start_addr> and ending at "\
											"<end_addr>"]])

		# ds <start_addr> [end_addr] | [= number | = string | = array]
		self['ds'] = Command.new(
			[[/^\s*ds\s+(\d+)(\s+\d+)?\s*$/,			  "get_memory","sram"],
			 [/^\s*ds\s+(\d+)\s*=\s*(\d+)\s*$/,			  "set_memory","sram"],
			 [/^\s*ds\s+(\d+)\s*=\s*("[[:print:]]*")\s*$/,"set_memory","sram"],
			 [/^\s*ds\s+(\d+)\s*=\s*(\[(?:\s*\d+\s*,)*(?:\s*\d+\s*)?\])\s*$/,
			 											  "set_memory","sram"]],
			[["<start_addr> [end_addr]","read / write SRAM memory"]],
			[["<start_addr>",			"read byte at <start_addr>"],
			 ["<start_addr> <end_addr>","read SRAM memory starting at "\
			 							"<start_addr> and ending at "\
										"<end_addr>"],
			 ["<start_addr> = <number>","write <number> to <start_addr>"],
			 ["<start_addr> = <string>","write <string> starting at "\
			 							"<start_addr>"],
			 ["<start_addr> = <array>",	"write <array> starting at "\
			 							"<start_addr>"]])

		# de <start_addr> [end_addr | = number | = string | = array]
		self['de'] = Command.new(
			[[/^\s*de\s+(\d+)(\s+\d+)?\s*$/,"get_memory","eeprom"],
			 [/^\s*de\s+(\d+)\s*=\s*(\d+)\s*$/,			 "set_memory","eeprom"],
			 [/^\s*de\s+(\d+)\s*=\s*("[[:print:]]*")\s*$/,"set_memory","eeprom"],
			 [/^\s*de\s+(\d+)\s*=\s*(\[(?:\s*\d+\s*,)*(?:\s*\d+\s*)?\])\s*$/,
		 											  "set_memory","eeprom"]],
			[["<start_addr> [end_addr]","read / write FLASH memory"]],
			[["<start_addr>",			"read byte at <start_addr>"],
			 ["<start_addr> <end_addr>","read EEPROM memory starting at "\
		 								"<start_addr> and ending at "\
										"<end_addr>"],
			 ["<start_addr> = <number>","write <number> to <start_addr>"],
			 ["<start_addr> = <string>","write <string> starting at "\
			 							"<start_addr>"],
			 ["<start_addr> = <array>",	"write <array> starting at "\
			 							"<start_addr>"]])

		# df <start_addr> [end_addr]
		self['df'] = Command.new(
			[[/^\s*df\s+(\d+)(?:\s*$|(\s+\d+)?$)/, "get_memory", "flash"]],
			[["<start_addr> [end_addr]",	"read FLASH memory"]],
			[["<start_addr>",				"read byte at <start_addr>"],
			 ["<start_addr> <end_addr>",	"read FLASH memory starting at "\
			 								"<start_addr> and ending at "\
											"<end_addr>"]])

		# reg [reg_name [= value]]
		self['reg'] = Command.new(
			[[/^\s*reg\s*$/,				"get_state"],
			 [/^\s*reg(?:\s*$|(\s+\w+)?$)/,	"get_state"]],
			[["[regname [= value]]",	"display/set CPU state"]],
			[["",						"display CPU state"],
			 ["<regname>",				"display CPU register <regname>"],
			 ["<regname> = <value>",	"set register <regname> to <value>"]])

		# help [command_name]
		self['help'] = Command.new(
			[[/^s*help\s*$|(?:\s+)(\w+)?/, "help"]])
	end
end
