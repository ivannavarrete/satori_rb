
class MemoryTxtWindow
	def initialize(memory)
		@memory = memory
	end

	def info
		@memory.range.to_s
	end

	def read(range)
		@memory.read(range)
	end
end
