module regfile(
	input		wire						clk,
	input		wire						rst,

	input 		wire						wEnable,
	input 		wire[`RegAddrBus] 			wAddr,
	input		wire[`RegBus]				wData,

	input		wire						r1Enable,
	input		wire[`RegAddrBus]			r1Addr,
	output		reg[`RegBus]				r1Data,

	input		wire						r2Enable,
	input		wire[`RegAddrBus]			r2Addr,
	output		reg[`RegBus]				r2Data
); 


// Define 32 32-bit registers
reg[`RegBus] regs[0:`RegNum-1];

integer i;
/*****************************Write Operations********************************/
always @(posedge clk) begin
	if (rst == `RstDisable) begin
		if ((wEnable == `WriteEnable) && (wAddr != `RegNumLog2'h0)) begin
			regs[wAddr] <= wData;
		end
	end
	else begin
		for(i = 0;i<32; i = i + 1) begin
			regs[i] = `ZeroWord;
		end
	end
end

/*****************************Read Operations********************************/
always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		r1Data <= `ZeroWord;
	end
	else if (r1Addr == `RegNumLog2'h0) begin
		r1Data <= `ZeroWord;
	end
	else if ((r1Addr == wAddr) && (wEnable == `WriteEnable) && (r1Enable == `ReadEnable)) begin // r1 is also to be written
		r1Data <= wData;
	end
	else if (r1Enable == `ReadEnable) begin
		r1Data <= regs[r1Addr];
	end
	else begin
		r1Data <= `ZeroWord;
	end
end

always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		r2Data <= `ZeroWord;
	end
	else if (r2Addr == `RegNumLog2'h0) begin
		r2Data <= `ZeroWord;
	end
	else if ((r2Addr == wAddr) && (wEnable == `WriteEnable) && (r2Enable == `ReadEnable)) begin // r1 is also to be written
		r2Data <= wData;
	end
	else if (r2Enable == `ReadEnable) begin
		r2Data <= regs[r2Addr];
	end
	else begin
		r2Data <= `ZeroWord;
	end
end

endmodule 