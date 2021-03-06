
# === SYNOPSIS
# Development system for 8-bit microconrollers. Currently only supports the
# AVR architecture.
#
# === USAGE
#	ruby satori.rb [-h | --help]
#
# === AUTHOR
# Ivan Navarrete
#
# === COPYRIGHT
# Copyright (c) 2006 Ivan Navarrete.


# parse options
require 'English'
require 'optparse'
require 'rdoc/usage'

opts = OptionParser.new
opts.on("-h", "--help") { RDoc::usage }
opts.parse(ARGV) rescue RDoc::usage('usage')


# start the program
Dir.chdir(File.join(File.dirname(__FILE__), ".."))

require 'satori/ui/txt/basetxtui'

ui = BaseTxtUi.new
ui.idle
