
### Output functions for use in the text ui classes.

def message(*messages)
	messages.each {|msg| puts "#{Color.prompt}] #{Color.headline}#{msg}" }
end

def warning(*message)
	puts "#{Color.prompt}] #{Color.error}#{message}"
end

def error(message)
	puts "#{Color.prompt}] #{Color.error}#{message}"
end
