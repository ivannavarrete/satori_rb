
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
			 [/^\s*device\s+(\w*)\s*$/,		"set_device"]],
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

		# ds <start_addr> [end_addr] ## | = [number | string | array]]
		self['ds'] = Command.new(
			[[/^\s*ds\s+(\d+)(?:\s*$|(\s+\d+)?$)/, "get_memory", "sram"]],
			[["<start_addr> [end_addr]",	"display SRAM memory"]],
			[["<start_addr>",				"display one byte of SRAM memory "\
											"starting at <start_addr>"],
			 ["<start_addr> <end_addr>",	"display SRAM memory starting at "\
			 								"<start_addr> and ending at "\
											"<end_addr>"]])

		# de <start_addr> [end_addr] ## | = [number | string | array]]
		self['de'] = Command.new(
			[[/^\s*de\s+(\d+)(?:\s*$|(\s+\d+)?$)/, "get_memory", "eeprom"]],
			[["<start_addr> [end_addr]",	"display FLASH memory"]],
			[["<start_addr>",				"display 64 bytes of EEPROM memory"\
											" starting at <start_addr>"],
			 ["<start_addr> <end_addr>",	"display EEPROM memory starting at"\
			 								" <start_addr> and ending at "\
											"<end_addr>"]])

		# df <start_addr> [end_addr]
		self['df'] = Command.new(
			[[/^\s*df\s+(\d+)(?:\s*$|(\s+\d+)?$)/, "get_memory", "flash"]],
			[["<start_addr> [end_addr]",	"display FLASH memory"]],
			[["<start_addr>",				"display 64 bytes of FLASH memory "\
											"starting at <start_addr>"],
			 ["<start_addr> <end_addr>",	"display FLASH memory starting at "\
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
