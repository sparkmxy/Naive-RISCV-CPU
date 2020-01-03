module id_exe(

	input		wire		clk,
	input 		wire 		rst,

	// information from ID
	input		wire[`AluOpBus]	 	id_aluop,
	input		wire[`AluSelBus] 	id_alusel,
	input		wire[`RegBus]		id_reg1,
	input 		wire[`RegBus]		id_reg2,
	input	 	wire[`RegAddrBus] 	id_wAddr,
	input		wire				id_wreg,
	//from the control module
	input		wire[5:0]			stall,

	//Informatino send to EXE
	output		reg[`AluOpBus]	 	exe_aluop,
	output		reg[`AluSelBus] 	exe_alusel,
	output		reg[`RegBus]		exe_reg1,
	output	 	reg[`RegBus]		exe_reg2,
	output		reg[`RegAddrBus] 	exe_wAddr,
	output		reg				    exe_wreg,
	//branch related

	// for load store
	input		wire[`RegBus]		id_inst,
	output		reg[`RegBus]		exe_inst		
);

always @(posedge clk) begin
	if (rst == `RstEnable) begin
		// reset
		exe_aluop <= `EXE_OP_NOP;
		exe_alusel <= `OP_NOP;
		exe_reg1 <= `ZeroWord;
		exe_reg2 <= `ZeroWord;
		exe_wAddr <= `NOPRegAddr;
		exe_wreg <= `WriteDisable;
	end
	else if (stall[2] == `STOP && stall[3] == `NOSTOP) begin
		exe_aluop <= `EXE_OP_NOP;
		exe_alusel <= `OP_NOP;
		exe_reg1 <= `ZeroWord;
		exe_reg2 <= `ZeroWord;
		exe_wAddr <= `NOPRegAddr;
		exe_wreg <= `WriteDisable;
	end
	else if(stall[2] == `NOSTOP) begin
		exe_aluop <= id_aluop;
		exe_alusel <= id_alusel;
		exe_reg1 <= id_reg1;
		exe_reg2 <= id_reg2;
		exe_wreg <= id_wreg;
		exe_wAddr <= id_wAddr;
		exe_inst <= id_inst;
	end
	else begin
		exe_aluop <= `EXE_OP_NOP;
		exe_alusel <= `OP_NOP;
		exe_reg1 <= `ZeroWord;
		exe_reg2 <= `ZeroWord;
		exe_wAddr <= `NOPRegAddr;
		exe_wreg <= `WriteDisable;
	end
end

endmodule