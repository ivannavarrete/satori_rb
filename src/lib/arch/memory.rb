
class Memory
	attr_reader :name, :range

	def initialize(name, range)
		@name = name
		@range = range

		# simulated memory, until we get working hardware or simulator
		@data = Array.new(range.max - range.min + 1) { rand(255) }
		@data[0..3] = [0x66, 0x6f, 0x6f, 0x20]
		@data[-4..-1] = [0x62, 0x61, 0x72, 0x20]
	end

	## Read memory specified by +range+. If range is out of bounds it is
	## automatically truncated. Returns a data array and start address.
	def read(range)
		start_addr = [@range.begin, range.begin].max
		end_addr = [@range.end, range.end].min

		return [], 0 if start_addr > end_addr
		return @data[start_addr-@range.min..end_addr-@range.min], start_addr
	end
end
