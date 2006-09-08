
# This class represents a high level model of an AVR device. It does not have
# much functionality itself but instead serves as a container for the device
# subsystems (memory, io, state, etc).
class AvrDevice
	attr_reader :name, :sram, :eeprom, :flash, :state, :code

	def initialize(name)
		@name = name
		@command_engine = "CommandEngine.new"

		device_info = AvrDeviceInfo.new(name)

		@sram = Memory.new(@command_engine, *device_info.memory("sram"))
		@eeprom = Memory.new(@command_engine, *device_info.memory("eeprom"))
		@flash = Memory.new(@command_engine, *device_info.memory("flash"))
		#@code = Code.new(@flash, AvrDisasmEngine.new)
	end
end


class AvrDeviceInfo
	def initialize(name)
		@name = name
		# parse XML device file ...
	end

	def memory(type)
		return type, 0x00, 0x1FF
	end
end


class Memory
	def initialize(command_engine, type, start_addr, end_addr)
		puts "Memory.initialize"

		#throw something if start_addr >= end_addr

		@command_engine = command_engine
		@type = type
		@start_addr = start_addr
		@end_addr = end_addr
	end

	def read(start_addr, end_addr, data)
		puts "Memory.read"

		start_addr = max(@start_addr, start_addr)
		end_addr = min(@end_addr, end_addr)
	end

	def write(start_addr, end_addr, data)
		puts "Memory.write"
	end
end


avr_device = AvrDevice.new("at90s8535")
