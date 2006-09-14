
# The Command class represents a text UI command.
class Command
	attr_reader	:method, :method_args, :arguments,
				:short_description, :long_description

	def initialize(regexp_array, short_description=[], long_description=[])
		@regexp_array = regexp_array
		@short_description = short_description
		@long_description = long_description

		@method = nil
		@method_args = []
		@arguments = []
	end

	# Parse the command line and fill in the +type+ and +arguments+ attributes.
	# Return the command method on success or nil on failure (with +method+,
	# +method_args+ and +arguments+ undefined).
	def parse(line)
		if regexp = @regexp_array.find {|exp| exp[0] =~ line }
			@arguments = $LAST_MATCH_INFO.to_a[1..-1]
			@method_args = regexp[2..-1]
			@method = regexp[1]
		end
	end
end
