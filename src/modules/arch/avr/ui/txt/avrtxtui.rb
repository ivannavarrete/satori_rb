
require 'ui/txt/avrcommandtable'
require 'lib/txtui'


class AvrTxtUi < TxtUi

	def initialize
		@command_table = AvrCommandTable.new
	end

	## Execute command specified by the Command object and its arguments
	## Return false if command wasn't found and true if it was found and
	## tried to execute.
	def exec(command_line)
		return false unless command = parse_command(command_line)

		case (command.type)
		when AvrCommandTable::GetDevice:	command_get_device
		when AvrCommandTable::SetDevice:	command_set_device(command)
		when AvrCommandTable::GetCode:		command_get_code(command)
		when AvrCommandTable::GetSRAM:		command_get_memory(command)
		when AvrCommandTable::GetEEPROM:	command_get_memory(command)
		when AvrCommandTable::GetFLASH:		command_get_memory(command)
		when AvrCommandTable::SetSRAM:		command_set_memory(command)
		when AvrCommandTable::SetEEPROM:	command_set_memory(command)
		when AvrCommandTable::GetState:		command_get_state(command)
		when AvrCommandTable::SetState:		command_set_state(command)
		when AvrCommandTable::Help:			command_help(command)
		else raise NotImplementedError, "Command found but not implemented"
		end

		true
	end

private
	def command_get_device
		message("get_device")
	end

	def command_set_device(command)
		message("set_device #{command.arguments[0]}")
	end
	
	def command_get_code(command)
		start_addr = command.arguments[0].to_i
		end_addr = if command.arguments[1] then command.arguments[1].to_i
				   else start_addr + 64
				   end

		message("get_code #{start_addr} #{end_addr}")
	end
	
	##
	def command_get_memory(command)
		start_addr = command.arguments[0].to_i
		end_addr = if command.arguments[1] then command.arguments[1].to_i
				   else start_addr + 64
				   end

		message("get_memory #{start_addr} #{end_addr}")
	end
	
	##
	def command_set_memory(command)
		message("set_memory")
	end
	
	##
	def command_get_state(command)
		message("get_state")
	end
	
	##
	def command_set_state(command)
		message("set_state")
	end

	##
	def command_help(command)
		message("--[ AVR Architecture commands ]--") unless command.arguments[0]
		super
	end
end
