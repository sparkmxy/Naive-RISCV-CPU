module id(
	input		wire 					rst,
	input		wire[`InstAddrBus]		pc_i,
	input		wire[`InstBus]			inst_i,

	// Data from Regfile
	input 		wire[`RegBus]			reg1_data_i,
	input 		wire[`RegBus]			reg2_data_i,

	// Output to Regfile
	output  	reg 					reg1_read_o,
	output 		reg 					reg2_read_o,
	output 		reg[`RegAddrBus]		reg1_addr_o,
	output 		reg[`RegAddrBus]		reg2_addr_o,

	// Output to EXE
	output 		reg[`AluOpBus]			aluop_o,
	output 		reg[`AluSelBus]			alusel_o,
	output 		reg[`RegBus]			reg1_o,
	output 		reg[`RegBus]			reg2_o,
	output 		reg[`RegAddrBus]		wAddr_o,
	output 		reg 					wreg_o,

	//forwarding
	input		wire 				exe_wreg_i,
	input		wire[`RegAddrBus]	exe_wAddr_i,
	input 		wire[`RegBus]		exe_wData_i,

	input		wire 				mem_wreg_i,
	input		wire[`RegAddrBus] 	mem_wAddr_i,
	input 		wire[`RegBus]		mem_wData_i,

	//branchFlag
	output    	reg  				branchFlag,     
	output      reg[`InstAddrBus] 	branchTarget,

	//control(mainly for load/store)
	output 		reg  				stallFlag,


	// For branch
	output		wire[`RegBus]		inst_o,


	input		wire 				ex_mem_wreg_i,
	input		wire[`RegAddrBus] 	ex_mem_wAddr_i,
	input 		wire[`RegBus]		ex_mem_wData_i
);


// Devide the instruction into parts.
wire[6:0] opcode = inst_i[6:0];
wire[2:0] func3 =  inst_i[`FUNC3];
wire[6:0] func7 = inst_i[`FUNC7];

//The immediate num.
reg[`RegBus] imm;
/*Decode the instruction*/ 

wire[`RegBus] offset;
wire[`InstAddrBus] pc_plus4;

assign  pc_plus4 = pc_i + 4;

assign offset = {{19{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
assign inst_o = inst_i;


always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		aluop_o <= `EXE_OP_NOP;
		alusel_o <= `OP_NOP;
		reg1_addr_o <= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		imm <= `ZeroWord;
		wAddr_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		branchFlag <= `LFalse;
		branchTarget <= `ZeroWord;
		stallFlag <= `NOSTOP;
	end
	else begin
		// the default parameters
		aluop_o <= `EXE_OP_NOP;
		alusel_o <= `OP_NOP;
		branchFlag<= `LFalse;
		reg1_read_o <= `ReadDisable;
		reg2_read_o <= `ReadDisable;
		wreg_o <= `WriteDisable;
		imm <= `ZeroWord;
		branchTarget <= `ZeroWord;
		stallFlag <= `NOSTOP;

		reg1_addr_o <= inst_i[19:15];   // default r1
		reg2_addr_o <= inst_i[24:20];	// default r2
		wAddr_o <= inst_i[11:7];
			case (opcode)
				`EXE_JAL: begin
					// Do JAL
					stallFlag <= `NOSTOP;
					wreg_o <= `WriteEnable;
					// wAddr_o as default
					aluop_o <= `EXE_OP_JAL;
					alusel_o <= `OP_JAMP;
					branchTarget <= $signed(pc_i) + $signed({{11{inst_i[31]}},inst_i[31],inst_i[19:12],inst_i[20],inst_i[30:21],1'b0});
					branchFlag <= `LTrue;
					imm <= pc_plus4; 
					// reg1_o is the value of pc(before jump) + 4 and will be put into rd later in EXE.
				end
				`EXE_JALR: begin
					// Do JALR
					stallFlag <= `NOSTOP;
					reg1_read_o <= `ReadEnable;
					aluop_o <= `EXE_OP_JALR;
					alusel_o <= `OP_JAMP;

					wreg_o <= `WriteEnable;

					branchFlag <= `LTrue;
					branchTarget <= ($signed({inst_i[31:20],{20{1'b0}}}) + $signed(reg1_o)) & {{31{1'b1}},1'b0};
					imm <= pc_plus4;
					// (pc+4) will be in reg2_o
				end
				`EXE_AUIPC: begin
					// Do AUIPC
					stallFlag <= `NOSTOP;
					aluop_o <= `EXE_OP_AUIPC;
					alusel_o <= `OP_JAMP;
					wreg_o <= `WriteEnable;
					imm <= $signed(pc_i) + $signed({inst_i[31:12],{12{1'b0}}});
				end
				`EXE_LUI: begin
					// Do LUI
					stallFlag <= `NOSTOP;
					aluop_o <= `EXE_OP_LUI;
					alusel_o <= `OP_JAMP;
					wreg_o <= `WriteEnable;
					imm <= {inst_i[31:12],{12{1'b0}}};
				end
				`EXE_BRANCH: begin
					// some default settings
					stallFlag <= `NOSTOP;
					wreg_o <= `WriteDisable;
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadEnable;
					alusel_o <= `OP_BRANCH;
					branchFlag <= 1'b0;
					branchTarget <= `ZeroWord;
					case (func3)
						`FUNC3_BEQ: begin
							aluop_o <= `EXE_OP_BEQ;
							if (reg1_o == reg2_o) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);
							end	
						end
						`FUNC3_BNE: begin
							aluop_o <= `EXE_OP_BNE;
							if (reg1_o != reg2_o) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);
							end	
						end
						`FUNC3_BLT: begin
							aluop_o <= `EXE_OP_BLT;
							if ($signed(reg1_o) < $signed(reg2_o)) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);	
							end	
						end
						`FUNC3_BGE: begin
							aluop_o <= `EXE_OP_BGE;
							if ($signed(reg1_o) >= $signed(reg2_o)) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);
							end	
						end
						`FUNC3_BLTU: begin
							aluop_o <= `EXE_OP_BLTU;
							if (reg1_o  < reg2_o) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);
							end	
						end
						`FUNC3_BGEU: begin
							aluop_o <= `EXE_OP_BGEU;
							if (reg1_o  >= reg2_o) begin
								branchFlag <= 1'b1;
								branchTarget <= $signed(pc_i) + $signed(offset);
							end	
						end
						default: begin
						end
					endcase
				end
				`EXE_CAL: begin
						wreg_o <= `WriteEnable;
						reg1_read_o <= `ReadEnable;
						reg2_read_o <= `ReadEnable;
						stallFlag <= `NOSTOP;
					case (func3)
						`FUNC3_ADD: begin
							if (func7 == `FUNC7_0) begin
								aluop_o <= `EXE_OP_ADD;
								alusel_o <= `OP_ARI;
							end
							else begin
								aluop_o <= `EXE_OP_SUB;
								alusel_o <= `OP_ARI;
							end
						end
						`FUNC3_SLT: begin
							aluop_o <= `EXE_OP_SLT;
							alusel_o <= `OP_ARI;
						end
						`FUNC3_SLTU: begin
							aluop_o <= `EXE_OP_SLTU;
							alusel_o <= `OP_ARI;
						end
						`FUNC3_XOR: begin
							aluop_o <= `EXE_OP_XOR;
							alusel_o <= `OP_LOGIC;
						end
						`FUNC3_SLL: begin
							aluop_o <= `EXE_OP_SLL;
							alusel_o <= `OP_SHIFT;
						end
						`FUNC3_SRL: begin
							if (func7 == `FUNC7_0) begin
								aluop_o <= `EXE_OP_SRL;
								alusel_o <= `OP_SHIFT;
							end
							else begin
								aluop_o <= `EXE_OP_SRA;
								alusel_o <= `OP_SHIFT;
							end
						end
						`FUNC3_OR: begin
							aluop_o <= `EXE_OP_OR;
							alusel_o <= `OP_LOGIC;
						end
						`FUNC3_AND: begin
							aluop_o <= `EXE_OP_AND;
							alusel_o <= `OP_LOGIC;
						end		
						default:begin	
						end
					endcase	
				end
				`EXE_CALI: begin
					wreg_o <= `WriteEnable;
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadDisable;
					stallFlag <= `NOSTOP;
					case (func3)
						`FUNC3_ADDI: begin
							aluop_o <= `EXE_OP_ADD;
							alusel_o <= `OP_ARI;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end	
						`FUNC3_SLTI: begin
							aluop_o <= `EXE_OP_SLT;
							alusel_o <= `OP_ARI;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end	
						`FUNC3_SLTIU: begin
							aluop_o <= `EXE_OP_SLTU;
							alusel_o <= `OP_ARI;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end	
						`FUNC3_XORI: begin
							aluop_o <= `EXE_OP_XOR;
							alusel_o <= `OP_LOGIC;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end	
						`FUNC3_ORI: begin
							aluop_o <= `EXE_OP_OR;
							alusel_o <= `OP_LOGIC;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end		
						`FUNC3_ANDI: begin
							aluop_o <= `EXE_OP_AND;
							alusel_o <= `OP_LOGIC;
							imm <= {{20{inst_i[31]}},inst_i[31:20]};
						end	
						`FUNC3_SLLI: begin
							aluop_o <= `EXE_OP_SLL;
							alusel_o <= `OP_SHIFT;
							imm[4:0] <= inst_i[24:20];
						end	
						`FUNC3_SRLI: begin
							if (func7 == `FUNC7_0) begin
								aluop_o <= `EXE_OP_SRL;
								alusel_o <= `OP_SHIFT;
								imm[4:0] <= inst_i[24:20];
							end
							else begin
								aluop_o <= `EXE_OP_SRA;
								alusel_o <= `OP_SHIFT;
								imm[4:0] <= inst_i[24:20];
							end
						end	
						default: begin
						end
					endcase
				end
				`EXE_LOAD: begin

					wreg_o <= `WriteDisable;
					alusel_o <= `OP_LOAD_STORE;

					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadDisable;

					stallFlag <= `STOP;
					imm <= {{20{inst_i[31]}},inst_i[31:20]};

					case (func3)
						`FUNC3_LB: begin
							aluop_o <= `EXE_OP_LB;
						end	
						`FUNC3_LH: begin
							aluop_o <= `EXE_OP_LH;
						end	
						`FUNC3_LW: begin
							aluop_o <= `EXE_OP_LW;
						end	
						`FUNC3_LHU: begin
							aluop_o <= `EXE_OP_LHU;
						end	
						`FUNC3_LBU: begin
							aluop_o <= `EXE_OP_LBU;
						end	
						default: begin
						end
					endcase
				end
				`EXE_ST: begin
					wreg_o <= `WriteDisable;
					alusel_o <= `OP_LOAD_STORE;
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadEnable;
					stallFlag <= `STOP;
					case (func3)
						`FUNC3_SB: begin
							aluop_o <= `EXE_OP_SB;
						end	
						`FUNC3_SH: begin
							aluop_o <= `EXE_OP_SH;
						end	
						`FUNC3_SW: begin
							aluop_o <= `EXE_OP_SW;
						end	
						default:begin
						end
					endcase
				end
				default: begin
					stallFlag <= `NOSTOP;
				end
			endcase // case opcode
	end
end   // always end

/*Get the first oprand*/

always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		reg1_o <= `ZeroWord;
	end
	else if ((reg1_read_o == `ReadEnable) && (exe_wreg_i == `WriteEnable) && (exe_wAddr_i == reg1_addr_o)) begin
		reg1_o <= exe_wData_i;		
	end
	else if ((reg1_read_o == `ReadEnable) && (ex_mem_wreg_i == `WriteEnable) && (ex_mem_wAddr_i == reg1_addr_o)) begin
		reg1_o <= ex_mem_wData_i;		
	end
	else if ((reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wAddr_i == reg1_addr_o)) begin
		reg1_o <= mem_wData_i;
	end
	else if (reg1_read_o == `ReadEnable) begin
		reg1_o <= reg1_data_i;
	end
	else if (reg1_read_o == `ReadDisable) begin
		reg1_o <= imm;
	end
	else begin
		reg1_o <= `ZeroWord;
	end
end

/*Get the second oprand*/

always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		reg2_o <= `ZeroWord;
	end
	else if ((reg2_read_o == `ReadEnable) && (exe_wreg_i == `WriteEnable) && (exe_wAddr_i == reg2_addr_o)) begin
		reg2_o <= exe_wData_i;		
	end
	else if ((reg2_read_o == `ReadEnable) && (ex_mem_wreg_i == `WriteEnable) && (ex_mem_wAddr_i == reg2_addr_o)) begin
		reg2_o <= ex_mem_wData_i;		
	end
	else if ((reg2_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wAddr_i == reg2_addr_o)) begin
		reg2_o <= mem_wData_i;
	end
	else if (reg2_read_o == `ReadEnable) begin
		reg2_o <= reg2_data_i;
	end
	else if (reg2_read_o == `ReadDisable) begin
		reg2_o <= imm;
	end
	else begin
		reg2_o <= `ZeroWord;
	end
end

endmodule