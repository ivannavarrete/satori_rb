
require 'avrinstruction'

class AvrDisasmEngine

	def initialize
	end

	##
	## data and addr gets destroyd
	##
	def disassemble(data, addr)
		instruction_list = Array.new

		while (instruction = disassemble_instruction(data, addr))
			instruction_list.push(instruction)
		end

		instruction_list
	end


	##
	##
	def disassemble_instruction(data, addr)
		# get opcode (get first two chars from string and convert to number)
		opcode = data.slice!(0..1).unpack('n')[0]

		# find matching entry in opcode table
		entry = @@opcode_table.find {|e| opcode & e.mask == e.opcode }
		if (!entry): return nil end
		instruction = entry.dup

		# fill in address
		instruction.addr = addr
		addr += instruction.size

		# extract first operand
		instruction.operand1 =
			case entry.operand1_type
			when None:		0
			when OP_R2:		((opcode >> 3) & 0x06) | 0x18
			when OP_R3:		((opcode >> 4) & 0x07) + 16
			when OP_R4:		((opcode >> 4) & 0x0F) + 16
			when OP_R4_l:	(opcode >> 3) & 0x1E
			when OP_R5:		(opcode >> 4) & 0x1F
			when OP_A5:		(opcode >> 3) & 0x1F
			when OP_A6:		((opcode>>5) & 0x30) | (opcode & 0x0F)
			when OP_k7:		((opcode >> 3) & 0x7F) + 1
			when OP_k12:	(opcode & 0xFFF) + 1
			when OP_k16:	data.slice!(0..1).unpack('n')
			when OP_k22:
				((opcode & 0x01) << 16) | ((opcode & 0x01F0) << 13) |
				data.slice!(0..1).unpack('n')[0]
			when OP_q6:
				((opcode & 0x2000) >> 8) | ((opcode & 0xC00) >> 7) |
				(opcode & 0x07);
			else raise StandardError, "corrupt opcode table"
			end

		#extract second operand
		instruction.operand2 =
			case entry.operand2_type
			when None:		0
			when OP_R3:		(opcode & 0x07) + 16
			when OP_R4:		(opcode & 0x0F) + 16
			when OP_R4_l:	(opcode << 1) & 0x1E
			when OP_R5:		((opcode>>5) & 0x10) | (opcode & 0x0F)
			when OP_R5_r:	(opcode >> 4) & 0x1F;
			when OP_K6:		((opcode & 0xC0)>>2) | (opcode & 0x0F)
			when OP_K8:		((opcode & 0xF00)>>4) | (opcode & 0x0F)
			when OP_A6:		((opcode & 0x600)>>5) | (opcode & 0x0F)
			when OP_b3:		opcode & 0x07
			when OP_k16:	data.slice(0..1).unpack('n')[0]
			when OP_q6:
				((opcode & 0x2000) >> 8) | ((opcode & 0xC00) >> 7) |
				(opcode & 0x07)
			else raise StandardError, "corrupt opcode table"
			end

		instruction
	end

	private	:disassemble_instruction


# These constants are placed outside of AvrInstruction for now, since it makes
# the definition of opcode tables easier.

	# operand types
	None	= 0
	OP_R2	= 1			# [5..4]
	OP_R3	= 2			# [6..4], [2..0]
	OP_R4	= 3			# [7..4], [3..0]
	OP_R4_l	= 4			# [7..4], [3..0]
	OP_R5	= 5			# [8..4], [9,3..0]
	OP_R5_r	= 6			# [8..4]
	OP_K6	= 7			# [7..6,3..0]
	OP_K8	= 8			# [11..8,3..0]
	OP_A5	= 9			# [7..3]
	OP_A6	= 10		# [10..9,0..3]
	OP_k7	= 11		# [9..3]
	OP_k12	= 12		# [11..0]
	OP_k16	= 13		# [31..16]
	OP_k22	= 14		# [24..20,16,15..0]
	OP_b3	= 15		# [0..2]
	OP_SB	= 16		# [6..4]
	OP_q6	= 17		# [13,11..10,2..0]

	# opcodes and masks
	Nop    = 0x0000; NopM    = 0xFFFF  # no operation:  0000 0000 0000 0000

	Movw   = 0x0100; MovwM   = 0xFF00  # copy reg word: 0000 0001 dddd rrrr
	# multiply signed						: 0000 0010 dddd rrrr
	Muls   = 0x0200; MulsM   = 0xFF00
	# multiply signed with unsigned		: 0000 0011 0 ddd 0 rrr 
	Mulsu  = 0x0300; MulsuM  = 0xFF88
	# fractional multiply unsigned			: 0000 0011 0 ddd 1 rrr 
	Fmul   = 0x0308; FmulM   = 0xFF88
	# fractional multiply signed			: 0000 0011 1 ddd 0 rrr 
	Fmuls  = 0x0380; FmulsM  = 0xFF88
	# fract mul signed with unsigned		: 0000 0011 1 ddd 1 rrr 
	Fmulsu = 0x0388; FmulsuM = 0xFF88
	# compare with carry *					: 0000 01 r ddddd rrrr 
	Cpc    = 0x0400; CpcM    = 0xFC00
	# subtract with carry					: 0000 10 r ddddd rrrr 
	Sbc    = 0x0800; SbcM    = 0xFC00

	# add without carry					: 0000 11 r ddddd rrrr 
	Add    = 0x0C00; AddM    = 0xFC00
	# logical shift left					: 0000 11 dddddddddd 
	#{0x0C00, 0xFC00, "lsl"},

	# compare skip if equal				: 0001 00 r ddddd rrrr 
	Cpse   = 0x1000; CpseM   = 0xFC00
	# compare								: 0001 01 r ddddd rrrr 
	Cp     = 0x1400; CpM     = 0xFC00
	# subtract without carry				: 0001 10 r ddddd rrrr 
	Sub = 0x1800; SubM = 0xFC00

	# add with carry						: 0001 11 r ddddd rrrr 
	Adc = 0x1C00; AdcM = 0xFC00
	# rotate left through carry (adc)		: 0001 11 dddddddddd 
	#{0x1C00, 0xFC00, "rol"},

	# logical and							: 0010 00 r ddddd rrrr 
	And = 0x2000; AndM = 0xFC00
	# test for zero or minus (and)			: 0010 00 dddddddddd 
	#{0x2000,0xFC00, "tst", },

	# exclusive or							: 0010 01 r ddddd rrrr 
	Eor = 0x2400; EorM = 0xFC00
	# clear register (eor)					: 0010 01 dddddddddd 
	#{0x2400, 0xFC00, "clr"},

	# logical or							: 0010 10 r ddddd rrrr 
	Or = 0x2800; OrM = 0xFC00
	# copy register						: 0010 11 r ddddd rrrr 
	Mov = 0x2C00; MovM = 0xFC00

	# compare with immediate				: 0011 KKKK dddd KKKK 
	Cpi = 0x3000; CpiM = 0xF000

	# subtract immediate with carry		: 0100 KKKK dddd KKKK 
	Sbci = 0x4000; SbciM = 0xF000
	# subtract immediate					: 0101 KKKK dddd KKKK 
	Subi = 0x5000; SubiM = 0xF000
	# logical or with immediate			: 0110 KKKK dddd KKKK 
	Ori = 0x6000; OriM = 0xF000
	# set bits in register (ori)			: 0110 KKKK dddd KKKK 
	#{0x6000, 0xF000, "sbr", OP_R4, OP_K8},
	# logical and with immediate			: 0111 KKKK dddd KKKK 
	Andi = 0x7000; AndiM = 0xF000
	# clear bits in register (andi)		: 0111 ____ dddd ____ 
	#{0x7000, 0xF000, "cbr"},

	# load indirect from SRAM using (Z)	: 1000 000 ddddd 0000 
#	0x8000, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (Z+q)	: 10q0 qq0 ddddd 0qqq 
#	0x8000, 0xD208, 2, "ldd",
	# load indirect from SRAM using (Y)	: 1000 000 ddddd 1000 
#	0x8008, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (Y+q)	: 10q0 qq0 ddddd 1qqq 
#	0x8008, 0xD208, 2, "ldd",
	# store indirect to SRAM using (Z)		: 1000 001 rrrrr 0000 
#	0x8200, 0xFE0F, 2, "st",
	# store indirect to SRAM using (Z+q)	: 10q0 qq1 rrrrr 0qqq 
#	0x8200, 0xD208, 2, "std",
	# store indirect to SRAM using (Y)		: 1000 001 rrrrr 1000 
#	0x8208, 0xFE0F, 2, "st",
	# store indirect to SRAM using (Y+q)	: 10q0 qq1 rrrrr 1qqq 
#	0x8208, 0xD208, 2, "std",

	# add immediate to word				: 1001 0110 KK dd KKKK 
	Adiw = 0x9600; AdiwM = 0xFF00
	# subtract immediate from word			: 1001 0111 KK dd KKKK 
#	0x9700, 0xFF00, 2, "sbiw",

	# bit set in SREG						: 1001 0100 0 sss 1000 
	#{0x9408, 0xFF8F, "bset", OP_SB, None},
	# bit clear in SREG					: 1001 0100 1 sss 1000 
	#{0x9488, 0xFF8F, "bclr", OP_SB, None},
	# set carry flag						: 1001 0100 0 000 1000 
	Sec = 0x9408; SecM = 0xFFFF
	# clear carry flag						: 1001 0100 1 000 1000 
	Clc = 0x9488; ClcM = 0xFFFF
	# set zero flag						: 1001 0100 0 001 1000 
	Sez = 0x9418; SezM = 0xFFFF
	# clear zero flag						: 1001 0100 1 001 1000 
	Clz = 0x9498; ClzM = 0xFFFF
	# set negative flag					: 1001 0100 0 010 1000 
	Sen = 0x9428; SenM = 0xFFFF
	# clear negative flag					: 1001 0100 1 010 1000 
	Cln = 0x94A8; ClnM = 0xFFFF
	# set overflow flag					: 1001 0100 0 011 1000 
	Sev = 0x9438; SevM = 0xFFFF
	# clear overflow flag					: 1001 0100 1 011 1000 
	Clv = 0x94B8; ClvM = 0xFFFF
	# set signed flag						: 1001 0100 0 100 1000 
	Ses = 0x9448; SesM = 0xFFFF
	# clear signed flag					: 1001 0100 1 100 1000 
	Cls = 0x94C8; ClsM = 0xFFFF
	# set half carry flag					: 1001 0100 0 101 1000 
	Seh = 0x9458; SehM = 0xFFFF
	# clear half carry flag				: 1001 0100 1 101 1000 
	Clh = 0x94D8; ClhM = 0xFFFF
	# set T flag							: 1001 0100 0 110 1000 
	Set = 0x9468; SetM = 0xFFFF
	# clear T flag							: 1001 0100 1 110 1000 
	Clt = 0x94E8; CltM = 0xFFFF
	# set global interrupt flag			: 1001 0100 0 111 1000 
	Sei = 0x9478; SeiM = 0xFFFF
	# clear global interrupt flag			: 1001 0100 1 111 1000 
	Cli = 0x94F8; CliM = 0xFFFF

	# indirect jump						: 1001 0100 0000 1001 
	Ijmp = 0x9409; IjmpM = 0xFFFF
	# extended indirect jump				: 1001 0100 0001 1001 
	Eijmp = 0x9419; EijmpM = 0xFFFF
	# indirect call to subroutine			: 1001 0101 0000 1001 
	Icall = 0x9509; IcallM = 0xFFFF
	# extended indirect call to subroutine	: 1001 0101 0001 1001 
	Eicall = 0x9519; EicallM = 0xFFFF
	# extended load program memory			: 1001 0101 1101 1000 
	Elpm = 0x95D8; ElpmM = 0xFFFF
	# extended store program memory		: 1001 0101 1111 1000 
	Espm = 0x95F8; EspmM = 0xFFFF

	# jump									: 1001 010 kkkkk 110 k 16*k 
	Jmp = 0x940C; JmpM = 0xFE0E
	# long call to a subroutine			: 1001 010 kkkkk 111 k 16*k 
	Call = 0x940E; CallM = 0xFE0E

	# return from subroutine				: 1001 0101 0000 1000 
	Ret = 0x9508; RetM = 0xFFFF
	# return from interrupt				: 1001 0101 0001 1000 
	Reti = 0x9518; RetiM = 0xFFFF
	# set MCU in sleep mode				: 1001 0101 1000 1000 
	Sleep = 0x9588; SleepM = 0xFFFF
	# watchdog reset						: 1001 0101 1010 1000 
	Wdr = 0x95A8; WdrM = 0xFFFF
	# load program memory					: 1001 0101 1100 1000 
	Lpm = 0x95C8; LpmM = 0xFFFF
	# store program memory					: 1001 0101 1110 1000 
	Spm = 0x95E8; SpmM = 0xFFFF

	# load direct from SRAM				: 1001 000 ddddd 0000 16*k 
	Lds = 0x9000; LdsM = 0xFE0F
	# load indirect from SRAM using (Z+)	: 1001 000 ddddd 0001 
#	0x9001, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (-Z)	: 1001 000 ddddd 0010 
#	0x9002, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (Y+)	: 1001 000 ddddd 1001 
#	0x9009, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (-Y)	: 1001 000 ddddd 1010 
#	0x900A, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (X)	: 1001 000 ddddd 1100 
#	0x900C, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (X+)	: 1001 000 ddddd 1101 
#	0x900D, 0xFE0F, 2, "ld",
	# load indirect from SRAM using (-X)	: 1001 000 ddddd 1110 
#	0x900E, 0xFE0F, 2, "ld",

	# store direct to SRAM					: 1001 001 ddddd 0000 16*k 
	Sts = 0x9200; StsM = 0xFE0F
	# store indirect to SRAM using (Z+)	: 1001 001 rrrrr 0001 
#	0x9201, 0xFE0F, 2, "st",
	# store indirect to SRAM using (-Z)	: 1001 001 rrrrr 0010 
#	0x9202, 0xFE0F, 2, "st",
	# store indirect to SRAM using (Y+)	: 1001 001 rrrrr 1001 
#	0x9209, 0xFE0F, 2, "st",
	# store indirect to SRAM using (-Y)	: 1001 001 rrrrr 1010 
#	0x920A, 0xFE0F, 2, "st",
	# store indirect to SRAM using (X)		: 1001 001 rrrrr 1100 
#	0x920C, 0xFE0F, 2, "st",
	# store indirect using (X+)			: 1001 001 rrrrr 1101 
#	0x920D, 0xFE0F, 2, "st",
	# store indirect using (-X)			: 1001 001 rrrrr 1110 
#	0x920E, 0xFE0F, 2, "st",


#	0x9004, 0xFE0F, 2, "lpm", OP_R5, None,# 1001 000 ddddd 0100# load program mem (Z)
#	0x9005, 0xFE0F, 2, "lpm", OP_R5, None,	# 1001 000 ddddd 0101	# load program mem (Z+)
#	0x9006, 0xFE0F, 2, "elpm", OP_R5, None,	# 1001 000 ddddd 0110
#	0x9007, 0xFE0F, 2, "elpm", OP_R5, None,	# 1001 000 ddddd 0111

	# one's complement						: 1001 010 ddddd 0000 
	Com = 0x9400; ComM = 0xFE0F
	# two's complement						: 1001 010 ddddd 0001 
	Neg = 0x9401; NegM = 0xFE0F
	# swap nibbles							: 1001 010 ddddd 0010 
	Swap = 0x9402; SwapM = 0xFE0F
	# increment							: 1001 010 ddddd 0011 
	Inc = 0x9403; IncM = 0xFE0F
	# arithmetic shift right				: 1001 010 ddddd 0101 
	Asr = 0x9405; AsrM = 0xFE0F
	# logical shift right					: 1001 010 ddddd 0110 
	Lsr = 0x9406; LsrM = 0xFE0F
	# rotate right through carry			: 1001 010 ddddd 0111 
	Ror = 0x9407; RorM = 0xFE0F
	# decrement							: 1001 010 ddddd 1010 
	Dec = 0x940A; DecM = 0xFE0F
	# pop register from stack				: 1001 000 ddddd 1111 
	Pop = 0x900F; PopM = 0xFE0F
	# push register on stack				: 1001 001 ddddd 1111 
	Push = 0x920F; PushM = 0xFE0F

	# clear bit in I/O register			: 1001 1000 AAAAA bbb 
	Cbi = 0x9800; CbiM = 0xFF00
	# skip if bit in I/O register cleared	: 1001 1001 AAAAA bbb 
	Sbic = 0x9900; SbicM = 0xFF00
	# set bit in I/O register				: 1001 1010 AAAAA bbb 
	Sbi = 0x9A00; SbiM = 0xFF00
	# skip if bit in I/O register is set	: 1001 1011 AAAAA bbb 
	Sbis = 0x9B00; SbisM = 0xFF00

	# multiply unsigned					: 1001 11 r ddddd rrrr 
	Mul = 0x9C00; MulM = 0xFC00

	# load an I/O location to register		: 1011 0 AA ddddd AAAA 
	In = 0xB000; InM = 0xF800
	# store register to I/O location		: 1011 1 AA rrrrr AAAA 
	Out = 0xB800; OutM = 0xF800

	# relative jump						: 1100 kkkkkkkkkkkk 
	Rjmp = 0xC000; RjmpM = 0xF000
	# relative call to subroutine			: 1101 kkkkkkkkkkkk 
	Rcall = 0xD000; RcallM = 0xF000

	# load immediate						: 1110 KKKK dddd KKKK 
	Ldi = 0xE000; LdiM = 0xF000
	# set all bits in register				: 1110 1111 dddd 1111 
	#{0xEF0F, 0xFF0F, "ser", OP_R4, None},

	#{0xF000, 0xFC00, "brbs",},# 11110 0 kkkkkkk sss # br if b SREG set
	#{0xF400, 0xFC00, "brbc",},# 11110 1 kkkkkkk sss # br if b SREG clr
	# branch if carry set					: 11110 0 kkkkkkk 000 
	Brcs = 0xF000; BrcsM = 0xFC07
	# branch if carry cleared				: 11110 1 kkkkkkk 000 
	Brcc = 0xF400; BrccM = 0xFC07
	#{0xF000, 0xFC07, "brlo",},# 11110 0 kkkkkkk 000 # (brcs)
	#{0xF400, 0xF400, "brsh",},# 11110 1 kkkkkkk 000 # (brcc)
	# branch if equal						: 11110 0 kkkkkkk 001 
	Breq = 0xF001; BreqM = 0xFC07
	# branch if not equal					: 11110 1 kkkkkkk 001 
	Brne = 0xF401; BrneM = 0xFC07
	# branch if minus						: 11110 0 kkkkkkk 010 
	Brmi = 0xF002; BrmiM = 0xFC07
	# branch if plus						: 11110 1 kkkkkkk 010 
	Brpl = 0xF402; BrplM = 0xFC07
	# branch if overflow set				: 11110 0 kkkkkkk 011 
	Brvs = 0xF003; BrvsM = 0xFC07
	# branch if overflow cleared			: 11110 1 kkkkkkk 011 
	Brvc = 0xF403; BrvcM = 0xFC07
	# branch if less than (signed)			: 11110 0 kkkkkkk 100 
	Brlt = 0xF004; BrltM = 0xFC07
	# branch if greater or equal (signed)	: 11110 1 kkkkkkk 100 
	Brge = 0xF404; BrgeM = 0xFC07
	# branch if half carry flag is set		: 11110 0 kkkkkkk 101 
	Brhs = 0xF005; BrhsM = 0xFC07
	# branch if half carry flag is cleared	: 11110 1 kkkkkkk 101 
	Brhc = 0xF405; BrhcM = 0xFC07
	# branch if T flag is set				: 11110 0 kkkkkkk 110 
	Brts = 0xF006; BrtsM = 0xFC07
	# branch if T flag is cleared			: 11110 1 kkkkkkk 110 
	Brtc = 0xF406; BrtcM = 0xFC07
	# branch if global interrupts enabled	: 11110 0 kkkkkkk 111 
	Brie = 0xF007; BrieM = 0xFC07
	# branch if global interrupts disabled	: 11110 1 kkkkkkk 111 
	Brid = 0xF407; BridM = 0xFC07

	# bit load from T flag to bit in reg	: 11111 00 ddddd 0 bbb 
	Bld = 0xF800; BldM = 0xFE08
	# bit store from bit in reg to T flag	: 11111 01 ddddd 0 bbb 
	Bst = 0xFA00; BstM = 0xFE08
	# skip if bit in register is cleared	: 11111 10 rrrrr 0 bbb 
	Sbrc = 0xFC00; SbrcM = 0xFE08
	# skip if bit in register is set		: 11111 11 rrrrr 0 bbb 
	Sbrs = 0xFE00; SbrsM = 0xFE08


	@@opcode_table = [
		# no operation
		AvrInstruction.new('nop', 2, Nop, NopM, None, None),

		# copy register word
		AvrInstruction.new('movw', 2, Movw, MovwM, OP_R4_l, OP_R4_l),
		# multiply signed
		AvrInstruction.new('muls', 2, Muls, MulsM, OP_R4, OP_R4),
		# multiply signed with unsigned
		AvrInstruction.new('mulsu', 2, Mulsu, MulsuM, OP_R3, OP_R3),
		# fractional multiply unsigned
		AvrInstruction.new('fmul', 2, Fmul, FmulM, OP_R3, OP_R3),
		# fractional multiply signed
		AvrInstruction.new('fmuls', 2, Fmuls, FmulsM, OP_R3, OP_R3),
		# fractional multiply signed with unsigned
		AvrInstruction.new('fmulsu', 2, Fmulsu, FmulsuM, OP_R3, OP_R3),
		# compare with carry
		AvrInstruction.new('cpc', 2, Cpc, CpcM, OP_R5, OP_R5),
		# subtract with carry
		AvrInstruction.new('sbc', 2, Sbc, SbcM, OP_R5, OP_R5),

		# add without carry
		AvrInstruction.new('add', 2, Add, AddM, OP_R5, OP_R5),
		# logical shift left
		# AvrInstruction.new('lsl', 2, Lsl, LslM, ?, ?)

		# compare skip if equal
		AvrInstruction.new("cpse", 2, Cpse, CpseM, OP_R5, OP_R5),
		# compare
		AvrInstruction.new("cp", 2, Cp, CpM, OP_R5, OP_R5),
		# subtract without carry
		AvrInstruction.new("sub", 2, Sub, SubM, OP_R5, OP_R5),

		# add with carry
		AvrInstruction.new("adc", 2, Adc, AdcM, OP_R5, OP_R5),
		# rotate left through carry (adc)		: 0001 11 dddddddddd 
		#{0x1C00, 0xFC00, "rol"},

		# logical and
		AvrInstruction.new("and", 2, And, AndM, OP_R5, OP_R5),
		# test for zero or minus (and)			: 0010 00 dddddddddd 
		#{0x2000,0xFC00, "tst", },

		# exclusive or
		AvrInstruction.new("eor", 2, Eor, EorM, OP_R5, OP_R5),
		# clear register (eor)					: 0010 01 dddddddddd 
		#{0x2400, 0xFC00, "clr"},

		# logical or
		AvrInstruction.new("or", 2, Or, OrM, OP_R5, OP_R5),
		# copy register
		AvrInstruction.new("mov", 2, Mov, MovM, OP_R5, OP_R5),

		# compare with immediate
		AvrInstruction.new("cpi", 2, Cpi, CpiM, OP_R4, OP_K8),

		# subtract immediate with carry
		AvrInstruction.new("sbci", 2, Sbci, SbciM, OP_R4, OP_K8),
		# subtract immediate
		AvrInstruction.new("subi", 2, Subi, SubiM, OP_R4, OP_K8),
		# logical or with immediate
		AvrInstruction.new("ori", 2, Ori, OriM, OP_R4, OP_K8),
		# set bits in register (ori)			: 0110 KKKK dddd KKKK 
		#{0x6000, 0xF000, "sbr", OP_R4, OP_K8},
		# logical and with immediate
		AvrInstruction.new("andi", 2, Andi, AndiM, OP_R4, OP_K8),
		# clear bits in register (andi)		: 0111 ____ dddd ____ 
		#{0x7000, 0xF000, "cbr"},

		# load indirect from SRAM using (Z)	: 1000 000 ddddd 0000 
	#	AvrInstruction.new(0x8000, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (Z+q)	: 10q0 qq0 ddddd 0qqq 
	#	AvrInstruction.new(0x8000, 0xD208, 2, "ldd", OP_R5, OP_q6)
		# load indirect from SRAM using (Y)	: 1000 000 ddddd 1000 
	#	AvrInstruction.new(0x8008, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (Y+q)	: 10q0 qq0 ddddd 1qqq 
	#	AvrInstruction.new(0x8008, 0xD208, 2, "ldd", OP_R5, OP_q6)
		# store indirect to SRAM using (Z)		: 1000 001 rrrrr 0000 
	#	AvrInstruction.new(0x8200, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (Z+q)	: 10q0 qq1 rrrrr 0qqq 
	#	AvrInstruction.new(0x8200, 0xD208, 2, "std", OP_q6, OP_R5_r)
		# store indirect to SRAM using (Y)		: 1000 001 rrrrr 1000 
	#	AvrInstruction.new(0x8208, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (Y+q)	: 10q0 qq1 rrrrr 1qqq 
	#	AvrInstruction.new(0x8208, 0xD208, 2, "std", OP_q6, OP_R5_r)

		# add immediate to word
		AvrInstruction.new("adiw", 2, Adiw, AdiwM, OP_R2, OP_K6),
		# subtract immediate from word
	#	AvrInstruction.new("sbiw", 2, Sbiw, SbiwM, OP_R2, OP_K6),

		# bit set in SREG						: 1001 0100 0 sss 1000 
		#{0x9408, 0xFF8F, "bset", OP_SB, None},
		# bit clear in SREG					: 1001 0100 1 sss 1000 
		#{0x9488, 0xFF8F, "bclr", OP_SB, None},
		# set carry flag
		AvrInstruction.new("sec", 2, Sec, SecM, None, None),
		# clear carry flag
		AvrInstruction.new("clc", 2, Clc, ClcM, None, None),
		# set zero flag
		AvrInstruction.new("sez", 2, Sez, SezM, None, None),
		# clear zero flag
		AvrInstruction.new("clz", 2, Clz, ClzM, None, None),
		# set negative flag
		AvrInstruction.new("sen", 2, Sen, SenM, None, None),
		# clear negative flag
		AvrInstruction.new("cln", 2, Cln, ClnM, None, None),
		# set overflow flag
		AvrInstruction.new("sev", 2, Sev, SevM, None, None),
		# clear overflow flag
		AvrInstruction.new("clv", 2, Clv, ClvM, None, None),
		# set signed flag
		AvrInstruction.new("ses", 2, Ses, SesM, None, None),
		# clear signed flag
		AvrInstruction.new("cls", 2, Cls, ClsM, None, None),
		# set half carry flag
		AvrInstruction.new("seh", 2, Seh, SehM, None, None),
		# clear half carry flag
		AvrInstruction.new("clh", 2, Clh, ClhM, None, None),
		# set T flag
		AvrInstruction.new("set", 2, Set, SetM, None, None),
		# clear T flag
		AvrInstruction.new("clt", 2, Clt, CltM, None, None),
		# set global interrupt flag
		AvrInstruction.new("sei", 2, Sei, SeiM, None, None),
		# clear global interrupt flag
		AvrInstruction.new("cli", 2, Cli, CliM, None, None),

		# indirect jump
		AvrInstruction.new("ijmp", 2, Ijmp, IjmpM, None, None),
		# extended indirect jump
		AvrInstruction.new("eijmp", 2, Eijmp, EijmpM, None, None),
		# indirect call to subroutine
		AvrInstruction.new("icall", 2, Icall, IcallM, None, None),
		# extended indirect call to subroutine
		AvrInstruction.new("eicall", 2, Eicall, EicallM, None, None),
		# extended load program memory
		AvrInstruction.new("elpm", 2, Elpm, ElpmM, None, None),
		# extended store program memory
		AvrInstruction.new("espm", 2, Espm, EspmM, None, None),

		# jump
		AvrInstruction.new("jmp", 4, Jmp, JmpM, OP_k22, None),
		# long call to a subroutine
		AvrInstruction.new("call", 4, Call, CallM, OP_k22, None),

		# return from subroutine
		AvrInstruction.new("ret", 2, Ret, RetM, None, None),
		# return from interrupt
		AvrInstruction.new("reti", 2, Reti, RetiM, None, None),
		# set MCU in sleep mode
		AvrInstruction.new("sleep", 2, Sleep, SleepM, None, None),
		# watchdog reset
		AvrInstruction.new("wdr", 2, Wdr, WdrM, None, None),
		# load program memory
		AvrInstruction.new("lpm", 2, Lpm, LpmM, None, None),
		# store program memory
		AvrInstruction.new("spm", 2, Spm, SpmM, None, None),

		# load direct from SRAM
		AvrInstruction.new("lds", 4, Lds, LdsM, OP_R5, OP_k16),
		# load indirect from SRAM using (Z+)	: 1001 000 ddddd 0001 
	#	AvrInstruction.new(0x9001, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (-Z)	: 1001 000 ddddd 0010 
	#	AvrInstruction.new(0x9002, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (Y+)	: 1001 000 ddddd 1001 
	#	AvrInstruction.new(0x9009, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (-Y)	: 1001 000 ddddd 1010 
	#	AvrInstruction.new(0x900A, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (X)	: 1001 000 ddddd 1100 
	#	AvrInstruction.new(0x900C, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (X+)	: 1001 000 ddddd 1101 
	#	AvrInstruction.new(0x900D, 0xFE0F, 2, "ld", OP_R5, None)
		# load indirect from SRAM using (-X)	: 1001 000 ddddd 1110 
	#	AvrInstruction.new(0x900E, 0xFE0F, 2, "ld", OP_R5, None)

		# store direct to SRAM
		AvrInstruction.new("sts", 4, Sts, StsM, OP_k16, OP_R5),
		# store indirect to SRAM using (Z+)	: 1001 001 rrrrr 0001 
	#	AvrInstruction.new(0x9201, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (-Z)	: 1001 001 rrrrr 0010 
	#	AvrInstruction.new(0x9202, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (Y+)	: 1001 001 rrrrr 1001 
	#	AvrInstruction.new(0x9209, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (-Y)	: 1001 001 rrrrr 1010 
	#	AvrInstruction.new(0x920A, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect to SRAM using (X)		: 1001 001 rrrrr 1100 
	#	AvrInstruction.new(0x920C, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect using (X+)			: 1001 001 rrrrr 1101 
	#	AvrInstruction.new(0x920D, 0xFE0F, 2, "st", OP_R5, None)
		# store indirect using (-X)			: 1001 001 rrrrr 1110 
	#	AvrInstruction.new(0x920E, 0xFE0F, 2, "st", OP_R5, None)

		# 1001 000 ddddd 0100# load program mem (Z)
	#	AvrInstruction.new(0x9004, 0xFE0F, 2, "lpm", OP_R5, None)
		# 1001 000 ddddd 0101	# load program mem (Z+)
	#	AvrInstruction.new(0x9005, 0xFE0F, 2, "lpm", OP_R5, None)
		# 1001 000 ddddd 0110
	#	AvrInstruction.new(0x9006, 0xFE0F, 2, "elpm", OP_R5, None)
		# 1001 000 ddddd 0111
	#	AvrInstruction.new(0x9007, 0xFE0F, 2, "elpm", OP_R5, None)

		# one's complement
		AvrInstruction.new("com", 2, Com, ComM, OP_R5, None),
		# two's complement
		AvrInstruction.new("neg", 2, Neg, NegM, OP_R5, None),
		# swap nibbles
		AvrInstruction.new("swap", 2, Swap, SwapM, OP_R5, None),
		# increment
		AvrInstruction.new("inc", 2, Inc, IncM, OP_R5, None),
		# arithmetic shift right
		AvrInstruction.new("asr", 2, Asr, AsrM, OP_R5, None),
		# logical shift right
		AvrInstruction.new("lsr", 2, Lsr, LsrM, OP_R5, None),
		# rotate right through carry
		AvrInstruction.new("ror", 2, Ror, RorM, OP_R5, None),
		# decrement
		AvrInstruction.new("dec", 2, Dec, DecM, OP_R5, None),
		# pop register from stack
		AvrInstruction.new("pop", 2, Pop, PopM, OP_R5, None),
		# push register on stack
		AvrInstruction.new("push", 2, Push, PushM, OP_R5, None),

		# clear bit in I/O register
		AvrInstruction.new("cbi", 2, Cbi, CbiM, OP_A5, OP_b3),
		# skip if bit in I/O register cleared
		AvrInstruction.new("sbic", 2, Sbic, SbicM, OP_A5, OP_b3),
		# set bit in I/O register
		AvrInstruction.new("sbi", 2, Sbi, SbiM, OP_A5, OP_b3),
		# skip if bit in I/O register is set
		AvrInstruction.new("sbis", 2, Sbis, SbisM, OP_A5, OP_b3),

		# multiply unsigned
		AvrInstruction.new("mul", 2, Mul, MulM, OP_R5, OP_R5),

		# load an I/O location to register
		AvrInstruction.new("in", 2, In, InM, OP_R5, OP_A6),
		# store register to I/O location
		AvrInstruction.new("out", 2, Out, OutM, OP_A6, OP_R5_r),

		# relative jump
		AvrInstruction.new("rjmp", 2, Rjmp, RjmpM, OP_k12, None),
		# relative call to subroutine
		AvrInstruction.new("rcall", 2, Rcall, RcallM, OP_k12, None),

		# load immediate
		AvrInstruction.new("ldi", 2, Ldi, LdiM, OP_R4, OP_K8),
		# set all bits in register				: 1110 1111 dddd 1111 
		#{0xEF0F, 0xFF0F, "ser", OP_R4, None},

		#{0xF000, 0xFC00, "brbs",},# 11110 0 kkkkkkk sss # br if b SREG set
		#{0xF400, 0xFC00, "brbc",},# 11110 1 kkkkkkk sss # br if b SREG clr
		# branch if carry set
		AvrInstruction.new("brcs", 2, Brcs, BrcsM, OP_k7, None),
		# branch if carry cleared
		AvrInstruction.new("brcc", 2, Brcc, BrccM, OP_k7, None),
		#{0xF000, 0xFC07, "brlo",},# 11110 0 kkkkkkk 000 # (brcs)
		#{0xF400, 0xF400, "brsh",},# 11110 1 kkkkkkk 000 # (brcc)
		# branch if equal
		AvrInstruction.new("breq", 2, Breq, BreqM, OP_k7, None),	# OP_b3
		# branch if not equal
		AvrInstruction.new("brne", 2, Brne, BrneM, OP_k7, None),	# OP_b3
		# branch if minus
		AvrInstruction.new("brmi", 2, Brmi, BrmiM, OP_k7, None),	# OP_b3
		# branch if plus
		AvrInstruction.new("brpl", 2, Brpl, BrplM, OP_k7, None),	# OP_b3
		# branch if overflow set
		AvrInstruction.new("brvs", 2, Brvs, BrvsM, OP_k7, None),	# OP_b3
		# branch if overflow cleared
		AvrInstruction.new("brvc", 2, Brvc, BrvcM, OP_k7, None),	# OP_b3
		# branch if less than (signed)
		AvrInstruction.new("brlt", 2, Brlt, BrltM, OP_k7, None),	# OP_b3
		# branch if greater or equal (signed)
		AvrInstruction.new("brge", 2, Brge, BrgeM, OP_k7, None),	# OP_b3
		# branch if half carry flag is set
		AvrInstruction.new("brhs", 2, Brhs, BrhsM, OP_k7, None),	# OP_b3
		# branch if half carry flag is cleared
		AvrInstruction.new("brhc", 2, Brhc, BrhcM, OP_k7, None),	# OP_b3
		# branch if T flag is set
		AvrInstruction.new("brts", 2, Brts, BrtsM, OP_k7, None),	# OP_b3
		# branch if T flag is cleared
		AvrInstruction.new("brtc", 2, Brtc, BrtcM, OP_k7, None),	# OP_b3
		# branch if global interrupts enabled
		AvrInstruction.new("brie", 2, Brie, BrieM, OP_k7, None),	# OP_b3
		# branch if global interrupts disabled
		AvrInstruction.new("brid", 2, Brid, BridM, OP_k7, None),	# OP_b3

		# bit load from T flag to bit in reg
		AvrInstruction.new("bld", 2, Bld, BldM, OP_R5, OP_b3),
		# bit store from bit in reg to T flag
		AvrInstruction.new("bst", 2, Bst, BstM, OP_R5, OP_b3),
		# skip if bit in register is cleared
		AvrInstruction.new("sbrc", 2, Sbrc, SbrcM, OP_R5, OP_b3),
		# skip if bit in register is set
		AvrInstruction.new("sbrs", 2, Sbrs, SbrsM, OP_R5, OP_b3)
	]
end
