module mem_wb(
	input	wire 				clk,
	input	wire				rst,

	//From MEM
	input	wire[`RegAddrBus]	mem_wAddr,
	input	wire[`RegBus]		mem_wData,
	input	wire				mem_wreg,

	//from control module
	input		wire[5:0]			stall,
	//To WB
	output	reg[`RegAddrBus]	wb_wAddr,
	output	reg 				wb_wreg,
	output	reg[`RegBus]		wb_wData

);

always @(posedge clk) begin
	if (rst == `RstEnable) begin
		// reset
		wb_wAddr <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wData <= `ZeroWord;
		
	end
	else if (stall[4] == `STOP && stall[5] == `NOSTOP) begin
		wb_wAddr <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wData <= `ZeroWord;
	end
	else if (stall[4] == `NOSTOP) begin
		wb_wreg <= mem_wreg;
		wb_wData <= mem_wData;
		wb_wAddr <= mem_wAddr;
	end
	else begin
		wb_wAddr <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
		wb_wData <= `ZeroWord;
	end
end

endmodule