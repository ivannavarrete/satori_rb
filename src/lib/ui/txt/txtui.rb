
require 'lib/ui/txt/memorytxtwindow'
require 'lib/command'
require 'lib/color'


class TxtUi
	## Execute command specified by +command_line+. Return +nil+ if command
	## wasn't found and true if it was found and tried to execute. Throw
	## +NoMethodError+ if command was found in the command table but not
	## implemented.
	def exec(command_line)
		if command = parse_command(command_line)
			send("command_#{command.type}", command)
			true
		end
	end

	## Given a command line, find a command in the command table that can
	## successfully parse that line. Returns a copied and initialized Command
	## object or nil if no matching command was found.
	def parse_command(command_line)
		command_name = command_line.strip.slice(/^\w+/)

		if command = @command_table[command_name] then
			command.dup if command.parse(command_line)
		end
	end

	## Display help.
	def command_help(command)
		command_name = command.arguments[0]

		# display help on specific command
		if command_name
			command_name.strip!
			if command = @command_table[command_name]
				display_help(command_name, command.long_description)
			else
				error("no such command [#{command_name}]")
			end

		# display help on all commands in command table that have a description
		else
			@command_table.each do |command_name, command|
				display_help(command_name, command.short_description)
			end
		end
	end

	## Helper method for command_help that displays formatted info
	## @Todo: remove dependency on hardcoded screen width
	def display_help(command_name, description_list)
		description_list.each do |arguments, description|
			# break down description in multiple lines if necessary
			if description.length > 40
				descr = ''
				line_length = 0
				description.each(' ') do |word|
					if (line_length += word.length) <= 40
						descr += word
					else
						descr += format("\n]  %37s%s", " ", word)
						line_length = word.length
					end
				end
				description = descr
			end

			message(format("  %-8s%-28s%s", command_name,arguments,description))
		end
	end

	##
    def message(*messages)
		messages.each {|msg| puts "#{Color.prompt}] #{Color.headline}#{msg}" }
	end

	##
	def error(cause)
		puts "#{Color.prompt}] #{Color.error}#{cause}"
	end
end
