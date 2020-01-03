module if_id(
	input wire					clk,
	input wire 					rst,

	input wire[`InstAddrBus]	if_pc,
	input wire[`InstBus]		if_inst,

	output reg[`InstAddrBus]	id_pc,
	output reg[`InstBus]		id_inst,
	
	input wire[5:0]             stall
);

always @(posedge clk) begin
	if (rst == `RstEnable) begin
		// reset
		id_pc <= `ZeroWord;
		id_inst <= `ZeroWord;
		
	end
	else if (stall[1] == `STOP && stall[2] == `NOSTOP) begin  // IF has stalled, while ID continues.
		id_pc <= `ZeroWord;
		id_inst <= `ZeroWord;
	end
	else if(stall[1] == `NOSTOP)begin     //no stalling
		id_pc <= if_pc;
		id_inst <= if_inst;
	end
	else begin
		id_pc <= `ZeroWord;
		id_inst <= `ZeroWord;
	end
end

endmodule