
require 'lib/arch/memory'


# This class implements the DSL in which devices are specified as well as
# serving as a container for the device-specific subsystems (memory, io,
# state, etc).
class Device
	# Get a metaclass for this class
	def self.metaclass
		class << self
			self
		end
	end

	# Create a new Memory object for this device. If a memory with the same
	# name already existed then it is replaced by a new memory.
	def self.memory(name, range)
		@memory ||= {}
		@memory[name] = Memory.new(name, range)
	end

	# Return the hash containing all memories.
	def memory
		return self.class.instance_variable_get(:@memory)
	end

	# Advanced metaprogramming code for nice, clean traits (from poignantguide)
	def self.traits(*arr)
		return @traits if arr.empty?

		# 1. Set up accessors for each variable
		attr_reader :name
		attr_accessor *arr

		# 2. Add a new class method to for each trait
		arr.each do |a|
			metaclass.instance_eval do
				define_method(a) do |val|
					@traits ||= {}
					@traits[a] = val
				end
			end
		end

		# 3. For each monster, the 'initialize' method should use the default
		#    number for each trait
		class_eval do
			define_method(:initialize) do
				@name = self.class.to_s.downcase

				self.class.traits.each do |k, v|
					instance_variable_set("@#{k}", v)
				end
			end
		end
	end
end

