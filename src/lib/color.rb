
class Color
	class << self
	attr_reader		:default,
					:prompt,
					:punctuation,
					:headline,
					:address,
					:machine_code,
					:mnemonic,
					:register,
					:number,
					:hex_data,
					:ascii_data,
					:changed,
					:error
	end

	def Color.init_none
		@default = ""
		@prompt = ""
		@punctuation = ""
		@headline = ""

		@address = ""
		@machine_code = ""
		@mnemonic = ""
		@register = ""
		@number = ""

		@hex_data = ""
		@ascii_data = ""

		@changed = ""
		@error = ""
	end

	def Color.init_16
		@default = "\x1B[37m"			# white
		@prompt = @default
		@punctuation = ""
		@headline = ""

		@address = "\x1B[31m"
		@machine_code = ""
		@mnemonic = "\x1B[34m"			# blue
		@register = ""
		@number = ""

		@hex_data = "\x1B[32m"			# green
		@ascii_data = "\x1B[32m"		# green

		@changed = "\x1B[31m"			# red
		@error = "\x1B[31m"				# red
	end

	def Color.init_256							# approximate color descriptions
		@default		= "\x1B[38;5;250m"		# white
		@prompt			= "\x1B[38;5;111m"		# blue
		@punctuation	= "\x1B[38;5;111m"		# blue
		@headline		= "\x1B[38;5;111m"		# blue

		@address		= "\x1B[38;5;208m"		# orange
		@machine_code	= "\x1B[38;5;244m" 		# grey
		@mnemonic		= "\x1B[38;5;111m"		# blue
		@register		= "\x1B[38;5;64m"		# green
		@number			= "\x1B[38;5;204m"		# light red

		@hex_data		= "\x1B[38;5;28m"		# green
		@ascii_data		= "\x1B[38;5;28m"		# green

		@changed		= "\x1B[38;5;196m"		# red
		@error			= "\x1B[38;5;196m"		# red
	end
end
