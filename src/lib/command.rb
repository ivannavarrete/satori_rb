
### The Command class represents a text UI command.
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

	## Parse the command line and fill in the +type+ and +arguments+ attributes.
	## Return the command method on success or nil on failure (with +method+,
	## +method_args+ and +arguments+ undefined).
	##
	## Note: The eval calls indirectly get their argument from user input.
	##		 This can have security implications.
	##
	## Bug: Crashes when parsing a string with an odd number of double-quotes.
	##      More than two quotes should probably be made to always work by
	##      auto-escaping them.
	def parse(line)
		if regexp = @regexp_array.find {|exp| exp[0] =~ line }
			@arguments = $LAST_MATCH_INFO[1..-1]

			# convert arguments from Strings to proper types
			@arguments.map! do |argument|
				next if argument == nil
				
				case argument.strip
				when /^(\d+)$/:							$LAST_MATCH_INFO[1].to_i
				when /^(\"[[:print:]]*\")$/:			eval($~[0])
				when /^\[(\s*\d+\s*,)*(\s*\d+\s*)?\]$/: eval($~[0])
				when /^(\w+)$/:							$LAST_MATCH_INFO[1]
				else raise ArgumentError, "bad argument type"
				end
			end

			@method_args = regexp[2..-1]
			@method = regexp[1]
		end
	end
end
