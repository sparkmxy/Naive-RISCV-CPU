module exe(
    input       wire                rst,
    input		wire[`InstBus]		inst_i,

	input		wire[`AluOpBus]		aluop_i,
	input		wire[`AluSelBus]	alusel_i,
	input		wire[`RegBus]		reg1_i,
	input		wire[`RegBus]		reg2_i,
	input		wire[`RegAddrBus]	wAddr_i,
	input		wire				wreg_i,

	// Result
	output		reg[`RegAddrBus]	wAddr_o,
	output		reg[`RegBus]		wData_o,
	output		reg 				wreg_o,

	//to MEM	
	output		reg[`AluOpBus]		aluop_o,
	output		reg[`RegBus]		mem_addr_o,

	output 		reg 				stallFlag

);

// store the result of operation of different type
reg[`RegBus] logicOut;
reg[`RegBus] arithemicOut;
reg[`RegBus] shiftResult;
reg[`RegBus] PCrelatedValue;
reg[`RegBus] StoreValue;

//Logic
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		logicOut <= `ZeroWord;
		
	end
	else begin
		case (aluop_i)
			`EXE_OP_OR: begin
				logicOut <= reg1_i | reg2_i;
			end
			`EXE_OP_AND: begin
				logicOut <= reg1_i & reg2_i; 
			end
			`EXE_OP_XOR: begin
				logicOut <= reg1_i ^ reg2_i;
			end
			default:begin
				logicOut <= `ZeroWord;
			end
		endcase
	end
end

//Alrithemic
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		arithemicOut <= `ZeroWord;
		
	end
	else begin
		case (aluop_i)
			`EXE_OP_ADD: begin
				arithemicOut <= reg1_i + reg2_i;
			end
			`EXE_OP_SUB: begin
				arithemicOut <= reg1_i - reg2_i;
			end
			`EXE_OP_SLT: begin  // signed comparison
				arithemicOut <= ($signed(reg1_i) < $signed(reg2_i)) ? {{31{1'b0}},1'b1} : `ZeroWord;
			end
			`EXE_OP_SLTU: begin
				arithemicOut <= (reg1_i < reg2_i) ? {{31{1'b0}},1'b1} : `ZeroWord;
			end
			default:begin
				arithemicOut <= `ZeroWord;
			end
		endcase
	end
end

//Shift 
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		shiftResult <= `ZeroWord;
		
	end
	else begin
			case (aluop_i)
			`EXE_OP_SLL: begin
				shiftResult <= reg1_i << reg2_i[4:0];
			end
			`EXE_OP_SRL: begin
				shiftResult <= reg1_i >> reg2_i[4:0];
			end
			`EXE_OP_SRA: begin  // Arithemic shift
				shiftResult <= ({32{reg1_i[31]}} << (6'd32 - {1'b0,reg2_i[4:0]}))|(reg1_i >> reg2_i[4:0]);
			end
			default:begin
				shiftResult <= `ZeroWord;
			end
		endcase
	end
end

//JUMP
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		PCrelatedValue <= `ZeroWord;
		
	end
	else begin
			case (aluop_i)
			`EXE_OP_AUIPC: begin
				PCrelatedValue <= reg1_i;
			end
			`EXE_OP_LUI: begin
				PCrelatedValue <= reg1_i;
			end
			`EXE_OP_JAL: begin
				PCrelatedValue <= reg1_i;
			end
			`EXE_OP_JALR: begin
				PCrelatedValue <= reg2_i;
			end
			default:begin
				PCrelatedValue <= `ZeroWord;
			end
		endcase
	end
end


// LOAD AND STORE
always @(*) begin
	if (rst) begin
		// reset
		StoreValue <= `ZeroWord;
	end
	else begin
		case (aluop_i)
			`EXE_OP_SW: begin
				StoreValue <= reg2_i;
				mem_addr_o <= reg1_i + {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
			end
			`EXE_OP_SH: begin
				StoreValue <= reg2_i;
				mem_addr_o <= reg1_i + {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
			end
			`EXE_OP_SB: begin
				StoreValue <= reg2_i;
				mem_addr_o <= reg1_i + {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
			end
			default:begin
				mem_addr_o <= reg1_i + reg2_i;
				StoreValue <= `ZeroWord;
			end
		endcase
	end
end
/*Choose a result to write back, only logical operation is considered in this case.*/

always @(*) begin
	wAddr_o <= wAddr_i;
	wreg_o <= wreg_i;
	aluop_o <= aluop_i;
	case (alusel_i)
		`OP_LOGIC: begin
			wData_o <= logicOut;
			stallFlag <= `NOSTOP;
		end
		`OP_SHIFT: begin
			wData_o <= shiftResult;
			stallFlag <= `NOSTOP;
		end
		`OP_ARI: begin
			wData_o <= arithemicOut;
			stallFlag <= `NOSTOP;
		end
		`OP_JAMP: begin
			wData_o <= PCrelatedValue;
			stallFlag <= `NOSTOP;
		end
		`OP_LOAD_STORE: begin
			wData_o <= 	StoreValue;
			stallFlag <= `STOP;
		end
		default: begin
			wData_o <= `ZeroWord;
			stallFlag <= `NOSTOP;
		end
	endcase
end

endmodule