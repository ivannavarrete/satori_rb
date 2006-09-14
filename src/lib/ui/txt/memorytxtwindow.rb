
require 'lib/color'


class MemoryTxtWindow
	def initialize(memory)
		@memory = memory
	end

	def info
		@memory.range.to_s
	end

	## Read and display memory contents specified by +range+.
	def read(range)
		data, addr = @memory.read(range)
		show(data, addr)
	end

private
	## Display memory in +data+ with start address +addr+.
	## Todo: Kinda slow, perhaps mostly due to 'line.each'? Speed it up.
	def show(data, addr)
		if not data.empty?
			puts "#{Color.prompt}]  #{Color.headline}--[ #{@memory.name} ]--"
		end

		prefix = "#{Color.prompt}]  #{Color.address}"
		while not data.empty?
			line = data.slice!(0, 16)
			
			hex = Color.hex_data + format("%02x "*[8, line.length].min + " " +
								"%02x "*[8, [line.length-8, 0].max].min, *line)

			ascii = Color.ascii_data
			line.each {|c| ascii += format(((0x20..0x7F)===c ? "%c" : "."), c)}

			print prefix, format("%04x   %-59s  %s\n", addr, hex, ascii)

			addr += 16
		end
	end
end
