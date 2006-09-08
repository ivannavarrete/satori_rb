
require 'lib/orderedhash'
require 'lib/command'


class AvrCommandTable < OrderedHash
	GetDevice = 100
	SetDevice = 101
	GetSRAM = 102
	GetEEPROM = 103
	GetFLASH = 104
	SetSRAM = 105
	SetEEPROM = 106
	GetState = 107
	SetState = 108
	GetCode = 109
	Help = 199


	def initialize
		super

		# device [device_name]
		self['device'] = Command.new(
			[[/^\s*device\s*$/,			GetDevice],
			 [/^\s*device\s+(\w*)\s*$/,	SetDevice]],
			[["[device_name]",			"display/select AVR device"]],
			[["",						"display selected AVR device"],
			 ["<device_name>",			"select AVR device"]])

		# c <start_addr> [end_addr]
		self['c'] = Command.new(
			[[/^\s*c\s+(\d+)(?:\s*$|(\s+\d+)?$)/, GetCode]],
			[["<start_addr> [end_addr]","show disassembled code"]],
			[["<start_addr>",			"display 64 words of code"],
			 ["<start_addr> <end_addr>","disassemble memory starting at "\
			 							"<start_addr> and ending at "\
										"<end_addr>"]])

		# ds <start_addr> [end_addr | = [number | string | array]]
		#self['ds'] = Command.new(
		#	[[/^s*ds\s+(\d+)\s+(\d*)|(\w*)|\[

		# de <start_addr> [end_addr | = [number | string | array]]

		# df <start_addr> [end_addr]
		self['df'] = Command.new(
			[[/^\s*df\s+(\d+)(?:\s*$|(\s+\d+)?$)/, GetFLASH]],
			[["<start_addr> [end_addr]","display FLASH memory"]],
			[["<start_addr>",			"display 40 bytes of FLASH memory "\
										"starting at <start_addr>"],
			 ["<start_addr> <end_addr>","display FLASH memory starting at "\
			 							"<start_addr> and ending at "\
										"<end_addr>"]])

		# reg [reg_name [= value]]
		self['reg'] = Command.new(
			[[/^\sreg(?:\s*$|(\s+\w+)?$)/, GetState],
			 [/^\sreg/, SetState]],
			[["[regname [= value]]",	"display/set CPU state"]],
			[["",						"display CPU state"],
			 ["<regname>",				"display CPU register <regname>"],
			 ["<regname> = <value>",	"set register <regname> to <value>"]])

		# help [command_name]
		self['help'] = Command.new(
			[[/^s*help\s*$|(?:\s+)(\w+)?/, Help]])
	end
end
