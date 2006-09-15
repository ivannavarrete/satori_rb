
### Extension of the Range class. Only works for integer ranges.
class Range
	## Return a range that is the intersection of +self+ and +range+ or nil
	## if the ranges don't intersect.
	def intersection(range)
		end1 = exclude_end? ? 1 : 0
		end2 = range.exclude_end? ? 1 : 0

		start_addr = [first, range.first].max
		end_addr = [last - end1, range.last - end2].min

		return nil if start_addr > end_addr

		Range.new(start_addr, end_addr)
	end

	## Return the size of the range.
	def size
		last - first + (exclude_end? ? 0 : 1)
	end
end
