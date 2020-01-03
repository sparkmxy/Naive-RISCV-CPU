module exe_mem(
	input		wire		clk,
	input		wire 		rst,

	//From EXE
	input		wire[`RegAddrBus]		exe_wAddr,
	input		wire					exe_wreg,
	input		wire[`RegBus]			exe_wData,

	input		wire[`AluOpBus]			exe_aluop,
	input		wire[`RegBus]			exe_mem_addr,
	//from control module
	input		wire[5:0]				stall,

	//Send to MEM
	output		reg[`RegAddrBus]		mem_wAddr,
	output		reg 					mem_wreg,
	output		reg[`RegBus]			mem_wData,

	output		reg[`AluOpBus]			mem_aluop,
	output		reg[`RegBus]			mem_addr,

	output		reg[`RegAddrBus]	wAddr2id,
	output		reg 				wreg2id,
	output		reg[`RegBus]		wData2id
);

always @(posedge clk) begin
	if (rst == `RstEnable) begin
		// reset
		mem_wreg <= `WriteDisable;
		mem_wData <= `ZeroWord;
		mem_wAddr <= `NOPRegAddr;
		mem_aluop <= `ZeroWord;
		mem_addr <= `ZeroWord;
	end
	else if (stall[3] == `STOP && stall[4] == `NOSTOP) begin
		mem_wreg <= `WriteDisable;
		mem_wData <= `ZeroWord;
		mem_wAddr <= `NOPRegAddr;
		mem_aluop <= 6'b000000;
		mem_addr <= `ZeroWord;
	end
	else if(stall[3] == `NOSTOP)begin
		mem_wAddr <= exe_wAddr;
		mem_wData <= exe_wData;
		mem_wreg <= exe_wreg;
		mem_aluop <=  exe_aluop;
		mem_addr <= exe_mem_addr;
		wreg2id <= exe_wreg;
		wData2id <= exe_wData;
		wAddr2id <= exe_wAddr;
	end
	else begin
		mem_wreg <= `WriteDisable;
		mem_wData <= `ZeroWord;
		mem_wAddr <= `NOPRegAddr;
		mem_aluop <= `ZeroWord;
		mem_addr <= `ZeroWord;
	end
end

endmodule