

class Memory
	attr_reader :name, :range

	def initialize(name, range)
		@name = name
		@range = range
	end

	def read(range)
		puts "Memory.read: #{range}"

#		start_addr = max(@start_addr, start_addr)
#		end_addr = min(@end_addr, end_addr)
	end
end
