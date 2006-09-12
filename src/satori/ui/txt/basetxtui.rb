
require 'satori/ui/txt/basecommandtable'
require 'lib/ui/txt/txtui'


class BaseTxtUi < TxtUi
public
	def initialize
		# Todo: Move the dirs into a 'config' module/class/namespace.
		@arch_dir = File.join("modules", "arch")
		@comm_dir = File.join("modules", "comm")

		@command_table = BaseCommandTable.new
		@arch_ui = nil
		@comm_ui = nil

		Color.init_256
	end

	## Command loop that reads and executes user commands.
	def idle
		message("Satori version r0.1", "Welcome", "")

		loop do
			# get user input
			print("#{Color.prompt}: #{Color.default}")
			redo if (command_line = gets.strip) == ""

			# execute commands
			executed = false
			executed = exec(command_line)
			executed |= @arch_ui.exec(command_line) if @arch_ui
			executed |= @comm_ui.exec(command_line) if @comm_ui
			
			# display error if no subsystem executed the command
			if not executed then error("command not found [#{command_line}]")end
		end
	end

private
	## Execute the command specified in the command line
	## Return false if command wasn't found and true if it was found and
	## tried to execute.
	def exec(command_line)
		return false unless command = parse_command(command_line)
	
		case (command.type)
		when BaseCommandTable::Quit:		command_quit
		when BaseCommandTable::ShowModule:	command_show_module
		when BaseCommandTable::LoadModule:	command_load_module(command)
		when BaseCommandTable::ClearScreen:	command_clear_screen
		when BaseCommandTable::Help:		command_help(command)
		else raise NotImplementedError, "Command found but not implemented"
		end

		true
	end

	## Terminate program.
	def command_quit
		exit 0
	end

	## Show available communication and architecture modules.
	def command_show_module
		message("--[ Architecture modules ]--")
		Dir.glob(File.join(@arch_dir,"*")) {|n| message("  #{n.slice(/\w+$/)}")}
		
		message("--[ Communication modules ]--")
		Dir.glob(File.join(@comm_dir,"*")) {|n| message("  #{n.slice(/\w+$/)}")}
	end

	## Load a communication or architecture module.
	def command_load_module(command)
		module_name = command.arguments[0].strip
		arch_dir = File.join(@arch_dir, module_name)

		Dir.chdir(arch_dir) do
			$: << arch_dir
			load "#{module_name}.rb"
			@arch_ui = Object.const_get("#{module_name.capitalize}TxtUi").new
			message("architecture module loaded: #{module_name}")
		end rescue error("module not found [#{module_name}]")
	end

	## Clear screen.
	## @Todo: Find out the screen geometry at runtime for more precise clearing.
	def command_clear_screen
		80.times { message("") }
	end

	## Display help.
	def command_help(command)
		message("--[ General commands ]--") if command.arguments[0] == nil
		super
	end
end
