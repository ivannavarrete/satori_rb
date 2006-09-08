
###
### This class represents one AVR instruction.
###
class AvrInstruction
	attr_reader		:mnemonic, :size, :opcode, :mask,
					:operand1_type, :operand2_type

	attr_writer		:operand1, :operand2, :addr

	def initialize(mnemonic, size, opcode, mask, op1_type, op2_type)
		@mnemonic = mnemonic
		@size = size
		@opcode = opcode
		@mask = mask
		@operand1_type = op1_type
		@operand2_type = op2_type

		@operand1 = 0
		@operand2 = 0
		@addr = 0
	end
end

