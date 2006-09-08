
class Command
	attr_reader		:type, :arguments, :short_description, :long_description

	def initialize(regexp_array, short_description=[], long_description=[])
		@regexp_array = regexp_array
		@short_description = short_description
		@long_description = long_description

		@type = 0
		@arguments = Array.new
	end

	# Parse the command line and fill in the @type and @arguments variables.
	# Return true on success, false on failure.
	def parse(line)
		regexp = @regexp_array.find {|regexp| regexp[0] =~ line}

		if regexp then
			@arguments = $LAST_MATCH_INFO.to_a[1..-1]
			@type = regexp[1]
			true
		else
			false
		end
	end
end
