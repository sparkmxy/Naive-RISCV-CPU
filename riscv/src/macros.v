/**************************Global Macro Definitions****************************/
`define RstEnable			1'b1			// Reset signal is Enabled
`define RstDisable			1'b0			// Reset signal is Disabled
`define ZeroWord			32'h00000000	// 32-bit value 0
`define WriteEnable			1'b1			
`define WriteDisable		1'b0
`define ReadEnable			1'b1			
`define ReadDisable			1'b0
`define AluOpBus			5:0				// The width of aluop_o
`define AluSelBus			2:0				// The widrh of alusel_o
`define LTrue				1'b1			// Logical true value
`define LFalse				1'b0 			// Logical false value
`define ChipEnable			1'b1			
`define ChipDisable			1'b0

/*********************Marco Definitions About Instructions*********************/

// Operation type
`define OP_NOP 				3'b000
`define OP_LOGIC			3'b001
`define OP_ARI				3'b010
`define OP_SHIFT			3'b011
`define OP_JAMP				3'b100
`define OP_BRANCH			3'b101
`define OP_LOAD_STORE		3'b110

//opcode
`define EXE_CALI			7'b0010011
`define	EXE_CAL 			7'b0110011	
`define	EXE_BRANCH			7'b1100011
`define EXE_JAL				7'b1101111
`define EXE_JALR   			7'b1100111
`define	EXE_AUIPC			7'b0010111
`define	EXE_LUI				7'b0110111
`define EXE_LOAD 			7'b0000011
`define EXE_ST 				7'b0100011

// FUNC3
`define FUNC3 				14:12
`define FUNC3_JALR			3'b000
`define FUNC3_BEQ			3'b000
`define	FUNC3_BNE			3'b001
`define FUNC3_BLT			3'b100 
`define FUNC3_BGE			3'b101
`define	FUNC3_BLTU			3'b110
`define FUNC3_BGEU			3'b111

`define	 FUNC3_LB 			3'b000
`define	 FUNC3_LH 			3'b001
`define	 FUNC3_LW 			3'b010
`define	 FUNC3_LHU 			3'b100
`define	 FUNC3_LBU 			3'b101

`define	FUNC3_SB 			3'b000
`define	FUNC3_SH 			3'b001
`define	FUNC3_SW	 		3'b010

`define FUNC3_ADDI			3'b000
`define FUNC3_SLTI			3'b010
`define FUNC3_SLTIU			3'b011
`define FUNC3_XORI			3'b100
`define FUNC3_ORI			3'b110
`define FUNC3_ANDI			3'b111
`define FUNC3_SLLI			3'b001
`define FUNC3_SRLI			3'b101
`define FUNC3_SRAI			3'b101

`define FUNC3_ADD			3'b000
`define FUNC3_SUB			3'b000
`define FUNC3_SLL			3'b001
`define FUNC3_SLT 			3'b010
`define FUNC3_SLTU 			3'b011
`define FUNC3_XOR 			3'b100
`define FUNC3_SRL 			3'b101
`define FUNC3_SRA 			3'b101
`define FUNC3_OR 			3'b110
`define FUNC3_AND 			3'b111

//FUNC7
`define FUNC7 				31:25
`define FUNC7_0				7'b0000000

//AluOp
`define AluOpBus			5:0
`define EXE_OP_NOP			6'b000000
`define EXE_OP_AUIPC		6'b000001
`define EXE_OP_JAL			6'b000010
`define EXE_OP_JALR			6'b000011

`define EXE_OP_BEQ			6'b000100
`define EXE_OP_BNE			6'b000101
`define EXE_OP_BLT			6'b000110
`define EXE_OP_BGE			6'b000111
`define EXE_OP_BLTU			6'b001000
`define EXE_OP_BGEU			6'b001001

`define EXE_OP_LB			6'b001010
`define EXE_OP_LH			6'b001011
`define EXE_OP_LW			6'b001100
`define EXE_OP_LBU			6'b001101
`define EXE_OP_LHU			6'b001110

`define EXE_OP_SB			6'b001111
`define EXE_OP_SH			6'b010000
`define EXE_OP_SW			6'b010001

`define EXE_OP_ADD			6'b010010 //ARITHEMIC
`define EXE_OP_SUB		 	6'b010011 //ARITHEMIC
`define EXE_OP_SLL   		6'b010100 
`define EXE_OP_SLT			6'b010101
`define EXE_OP_SLTU			6'b010110
`define EXE_OP_XOR			6'b010111
`define EXE_OP_SRL  		6'b011000
`define EXE_OP_SRA			6'b011001
`define EXE_OP_OR			6'b011010
`define EXE_OP_AND			6'b011011

`define EXE_OP_LUI			6'b011100
/*********************Marco Definitions About control***********************/
`define STOP				1'b1
`define NOSTOP				1'b0
/*********************Marco Definitions About ROM***********************/
`define InstAddrBus			31:0			// Width of the instrction bus
`define InstBus 			31:0			// Width of the data Bus
`define InstMemNum			131071			// The size of ROM if 128 KB
`define InstMemNumLog2		17				// The width of instructin bus used by ROM

/*******************Macro Definitions About Regfile********************/
`define RegAddrBus			4:0				// Width of the address bus in regfile
`define RegBus 				31:0			// Width of the data bus in regfile
`define RegWidth			32				// Width of registers
`define DoubleRegWidth		64
`define DoubleRegBus		63:0
`define RegNum				32
`define RegNumLog2			5
`define	NOPRegAddr			5'b00000

/*******************Macro Definitions About Instruction Cache********************/
`define NumOfLines			256
`define TagLength			24
`define IndexLength			8  //log(NumOfLines)		