
require 'lib/range'


class Memory
	attr_reader :name, :range

	def initialize(name, range)
		raise StandardError if range.size <= 0

		@name = name
		@range = range

		# simulated memory, until we get working hardware or simulator
		@data = Array.new(range.size) { rand(255) }
		@data[0..3] = [0x66, 0x6f, 0x6f, 0x20]
		@data[-4..-1] = [0x62, 0x61, 0x72, 0x20]
	end

	## Read memory specified by +range+. If range is out of bounds it is
	## automatically truncated. Returns a data array and start address.
	def read(range)
		return [], 0 unless range = range.intersection(@range)
		return @data[range.begin-@range.begin, range.size], range.begin
	end

	## Write +data+ to memory starting at +start_addr+. If +start_addr+ is out
	## of bounds RangeError is raised. If there is to much data to fit in the
	## memory the write is truncated.
	def write(data, start_addr)
		raise RangeError if not @range === start_addr

		start_index = start_addr-@range.begin
		size = [@range.size-start_index, data.size].min
		@data[start_index, size] = data[0, size]
	end
end
