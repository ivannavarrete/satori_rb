
class OrderedHash < Hash
	#alias_method :store, :[]=
	#alias_method :each_pair, :each

	def initialize
		@keys = []
	end

	def []=(key, val)
		@keys << key
		super
	end

	def store(key, val)
		@keys << key
		super
	end

	def delete(key)
		@keys.delete(key)
		super
	end

	def each
		@keys.each { |k| yield k, self[k] }
	end

	def each_key
		@keys.each { |k| yield k }
	end

	def each_value
		@keys.each { |k| yield self[k] }
	end
end


### Base class for all *CommandTable classes, that holds the set of all
### commands. It is implemented as an ordered hash.
###
### @Note: Maybe this class should be a subclass of Hash or OrderedHash
#class CommandTable < OrderedHash
#	alias_method :store, :[]=
#end
