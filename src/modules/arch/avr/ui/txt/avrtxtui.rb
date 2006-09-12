
require 'lib/ui/txt/txtui'
require 'ui/txt/avrcommandtable'


class AvrTxtUi < TxtUi

	def initialize
		@module_dir = File.join("modules", "arch", "avr")

		@device = nil
		@command_table = AvrCommandTable.new
		@windows = Hash.new
	end

	## Execute command specified by the Command object and its arguments
	## Return false if command wasn't found and true if it was found and
	## tried to execute.
	def exec(command_line)
		return false unless command = parse_command(command_line)

		case command.type
		when AvrCommandTable::GetCode:		command_get_code(command)
		when AvrCommandTable::GetSRAM:		command_get_memory(command)
		when AvrCommandTable::GetEEPROM:	command_get_memory(command)
		when AvrCommandTable::GetFLASH:		command_get_memory(command)
		when AvrCommandTable::SetSRAM:		command_set_memory(command)
		when AvrCommandTable::SetEEPROM:	command_set_memory(command)
		when AvrCommandTable::GetState:		command_get_state(command)
		when AvrCommandTable::SetState:		command_set_state(command)
		when AvrCommandTable::GetDevice:	command_get_device
		when AvrCommandTable::SetDevice:	command_set_device(command)
		when AvrCommandTable::GetDeviceInfo: command_get_device_info
		when AvrCommandTable::GetDeviceList: command_get_device_list
		when AvrCommandTable::Help:			command_help(command)
		else raise NotImplementedError, "Command found but not implemented"
		end

		true
	end

private
	# Display the name of the currently loaded device.
	def command_get_device
		if @device then message("device: #{@device.name}")
		else error("no device loaded")
		end
	end

	# Load new device.
	def command_set_device(command)
		device_name = command.arguments[0].downcase

		begin
			load "device/#{device_name}.rb"
			@device = Object.const_get("#{device_name.upcase}").new

			@device.memory.each do |name, memory|
				@windows[name] = MemoryTxtWindow.new(memory)
			end

			message("device loaded: #{device_name}")
		rescue LoadError, NameError
			error("device not found [#{device_name}]")
		end
	end

	# Get info on loaded device.
	def command_get_device_info
		command_get_device
		if @device
			message("    #{@device.description}")
			@windows.each {|name,window| message("    #{name}: #{window.info}")}
		end
	end

	# List all available devices.
	def command_get_device_list
		dir = File.join(@module_dir, "device", "*.rb")
		Dir.glob(dir) {|file| message("  #{File.basename(file, ".rb")}") }
	end
	
	def command_get_code(command)
		start_addr = command.arguments[0].to_i
		end_addr = start_addr + 64
		end_addr = command.arguments[1].to_i if command.arguments[1]

		message("get_code #{start_addr} #{end_addr}")
	end
	
	##
	def command_get_memory(command)
		start_addr = command.arguments[0].to_i
		end_addr = start_addr + 64
		end_addr = command.arguments[1].to_i if command.arguments[1]

		name = case command.type
			   when AvrCommandTable::GetSRAM: "sram"
			   when AvrCommandTable::GetEEPROM: "eeprom"
			   when AvrCommandTable::GetFLASH: "flash"
			   end

		@windows[name].read(start_addr..end_addr)
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
