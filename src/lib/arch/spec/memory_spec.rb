
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "..")
require File.dirname(__FILE__) + "/../memory"


context "A memory (in general)" do
	setup do
		@start_addr = 100
		@end_addr = 499
		@size = @end_addr - @start_addr + 1
		@memory = Memory.new("name", @start_addr..@end_addr)
	end

	specify "should have a name" do
		@memory.name.should_equal "name"
	end

	specify "should have an address range" do
		@memory.range.should_equal @start_addr..@end_addr
	end

	specify "should read memory within it's range" do
		data, addr = @memory.read(@start_addr..@end_addr)
		addr.should_equal @start_addr
		data.size.should_equal @size

		data, addr = @memory.read(@start_addr..@start_addr)
		addr.should_equal @start_addr
		data.size.should_equal 1

		data, addr = @memory.read(200..399)
		addr.should_equal 200
		data.size.should_equal 200
	end

	specify "should not read memory outside it's range" do
		data, addr = @memory.read(0..600)	# to low and to high
		addr.should_equal @start_addr
		data.size.should_equal @size

		data, addr = @memory.read(0..99)	# to low and to low
		addr.should_equal 0
		data.size.should_equal 0

		data, addr = @memory.read(501..600)	# to high and to high
		addr.should_equal 0
		data.size.should_equal 0

		data, addr = @memory.read(0..199)	# to low and ok
		addr.should_equal @start_addr
		data.size.should_equal 100

		data, addr = @memory.read(400..600)	# ok and to high
		addr.should_equal 400
		data.size.should_equal @end_addr - 400 + 1
	end

	specify "should not write memory starting outside it's range" do
		data = Array.new(@size+200)
		lambda { @memory.write(data, @start_addr-100) }.should_raise RangeError

		lambda { @memory.write(data, @end_addr+100) }.should_raise RangeError
	end

	specify "should write memory starting inside it's range" do
		data = Array.new(@size)
		lambda { @memory.write(data, @start_addr) }.should_not_raise RangeError

		lambda {@memory.write(data,@start_addr+100)}.should_not_raise RangeError
	end

	specify "should handle inclusive and exclusive ranges" do
		data, addr = @memory.read(@start_addr...@end_addr+1)
		data.size.should_equal @size

		data, addr = @memory.read(200..299)
		data.size.should_equal 100

		data, addr = @memory.read(200...300)
		data.size.should_equal 100

		data, addr = @memory.read(200...200)
		data.size.should_equal 0
	end
end


context "A memory with known content" do
	setup do
		@start_addr = 100
		@end_addr = 499
		@size = @end_addr - @start_addr + 1
		@memory = Memory.new("name", @start_addr..@end_addr)

		@data = Array.new(@size) {|i| i % 256 }
		@memory.write(@data, @start_addr)
	end

	specify "should return that content when read" do
		data, addr = @memory.read(@start_addr..@end_addr)
		addr.should_equal @start_addr
		data.should_equal @data
	end
end


context "A memory with random content" do
	setup do
		@start_addr = 100
		@end_addr = 499
		@size = @end_addr - @start_addr + 1
		@memory = Memory.new("name", @start_addr..@end_addr)

		@old_data, _ = @memory.read(@start_addr..@end_addr)
	end

	specify "should overwrite that content when written" do
		new_data = Array.new(@size) { rand(255) }
		@memory.write(new_data, @start_addr)

		read_data, addr = @memory.read(@start_addr..@end_addr)
		addr.should_equal @start_addr
		read_data.should_equal new_data
	end
end
