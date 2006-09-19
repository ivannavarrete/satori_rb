
require 'lib/ui/txt/txtui'
require 'ui/txt/avrcommandtable'


### Bug: Many commands raise exceptions since they don't check if a device is
###      loaded.
class AvrTxtUi < TxtUi
	def initialize
		@module_dir = File.join("modules", "arch", "avr")

		@device = nil
		@command_table = AvrCommandTable.new
		@windows = Hash.new
	end

private
	## Display the name of the currently loaded device.
	def command_get_device(command)
		if @device then message("device: #{@device.name}")
		else error("no device loaded")
		end
	end

	## Load new device.
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

	## Get info on loaded device.
	def command_get_device_info(command)
		command_get_device(command)
		if @device
			message("    #{@device.description}")
			@windows.each {|name,window| message("    #{name}: #{window.info}")}
		end
	end

	## List all available devices.
	def command_get_device_list(command)
		dir = File.join(@module_dir, "device", "*.rb")
		Dir.glob(dir) {|file| message("  #{File.basename(file, ".rb")}") }
	end
	
	def command_get_code(command)
		start_addr = command.arguments[0]
		end_addr = command.arguments[1] || start_addr + 63

		message("get_code #{start_addr} #{end_addr}")
	end
	
	## Read device memory.
	def command_get_memory(command, name)
		start_addr = command.arguments[0]
		end_addr = command.arguments[1] || start_addr

		@windows[name].read(start_addr..end_addr)
	end
	
	## Write device memory.
	def command_set_memory(command, name)
		start_addr = command.arguments[0]
		data = command.arguments[1]

		# convert data argument into an array
		data = if (data.class == Fixnum) then [data]
			   elsif (data.class == String) then data.unpack("c*")
			   elsif (data.class == Array) then data
			   end

		@windows[name].write(data, start_addr)
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
