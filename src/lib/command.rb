
# The Command class represents a text UI command.
class Command
	attr_reader		:type, :arguments, :short_description, :long_description

	def initialize(regexp_array, short_description=[], long_description=[])
		@regexp_array = regexp_array
		@short_description = short_description
		@long_description = long_description

		@type = 0
		@arguments = Array.new
	end

	# Parse the command line and fill in the +type+ and +arguments+ attributes.
	# Return the command type on success or nil on failure (with +type+ and
	# +arguments+ undefined).
	def parse(line)
		if regexp = @regexp_array.find {|exp| exp[0] =~ line }
			@arguments = $LAST_MATCH_INFO.to_a[1..-1]
			@type = regexp[1]
		end
	end
end
