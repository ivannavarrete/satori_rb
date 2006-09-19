
require 'readline'
include Readline

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

		# load AVR module and a device (for easier testing, remove later)
		exec("module avr")
		@arch_ui.exec("device at90s8535") if @arch_ui

		loop do
			# get user input
			command_line = readline("#{Color.prompt}: #{Color.default}", true)
			command_quit(nil) if command_line.nil?
			redo if command_line.strip == ""

			# execute commands
			executed = false
			executed = exec(command_line)
			executed |= @arch_ui.exec(command_line) if @arch_ui
			executed |= @comm_ui.exec(command_line) if @comm_ui
			
			# display error if no subsystem executed the command
			error("command not found [#{command_line}]") if not executed
		end
	end

private
	## Terminate program.
	def command_quit(command)
		puts if not command
		message("shutting down")
		exit 0
	end

	## Show available modules.
	def command_show_module(command)
		message("--[ Architecture modules ]--")
		Dir.glob(File.join(@arch_dir,"*")) {|n| message("  #{n.slice(/\w+$/)}")}
		
		message("--[ Communication modules ]--")
		Dir.glob(File.join(@comm_dir,"*")) {|n| message("  #{n.slice(/\w+$/)}")}
	end

	## Load a communication or architecture module.
	def command_load_module(command)
		module_name = command.arguments[0].strip
		arch_dir = File.join(@arch_dir, module_name)

		begin
			$: << arch_dir
			load "#{arch_dir}/#{module_name}.rb"
			@arch_ui = Object.const_get("#{module_name.capitalize}TxtUi").new
			message("architecture module loaded: #{module_name}")
		rescue LoadError, NameError
			error("module not found [#{module_name}]")
		end
	end

	## Clear screen.
	## @Todo: Find out the screen geometry at runtime for more precise clearing.
	def command_clear_screen(command)
		80.times { message("") }
	end

	## Display help.
	def command_help(command)
		message("--[ General commands ]--") if command.arguments[0] == nil
		super
	end
end
