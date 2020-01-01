module control (
	input 		wire			rst,
	input		wire			stall_from_id,
	input 		wire			stall_from_mem,
	input 		wire 			stall_from_ram,
	output		reg[5:0]		stall
);

always @(*) begin
	if (rst == `RstEnable) begin
		// reset
		stall <= 6'b000000;
	end
	else if (stall_from_id == `STOP) begin
		stall <= 6'b000111;
	end
	else if (stall_from_mem == `STOP) begin
		stall <= 6'b001111;
	end
	else if (stall_from_ram == `STOP) begin
		stall <= 6'b001111;
	end
	else begin
		stall <= 6'b000000;
	end
end

endmodule