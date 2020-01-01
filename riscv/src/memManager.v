// this module is used to handle the problem of IF and MEM
// need to access the memory at the same time.
// The tactic is 'MEM prior', that is, we always 
// handle the request from MEM first.

module memManager(
	input		wire 					clk,
	input 		wire 					ce,
	// To RAM
	input		wire[7:0]				data_i,
	output		reg 					RWflag,		// 0 for read; 1 for write
	output		reg[`InstAddrBus] 		address_o,
	output 		reg[7:0]				data_o,
	// To CPU 
	input		wire[7:0]	 			cpu_data_i,
	input		wire[`RegBus]			address_i,
	input 		wire[1:0]				type,  // 0 = read,  1 = write
	input		wire[`InstAddrBus]		pc_address,
	input       wire                   pcValid,
	output 		reg[7:0]				ram_data_o,
    
	// To CPU for control				
	output		reg 					stall_if
);


always @(*) begin
	if (ce == `ChipDisable) begin
		ram_data_o <= `ZeroWord;
	end
	else begin
		ram_data_o <= data_i;
	end
	if (type == 2'b01) begin // from MEM, load
		// call stall for pc
		stall_if <= `LTrue;
		data_o <= `ZeroWord;
		address_o <= address_i;
		RWflag <= 1'b0;
	end
	else if (type == 2'b10) begin // from MEM, store
		stall_if <= `LTrue;
		data_o <= cpu_data_i;
		address_o <= address_i;
		RWflag <= 1'b1;
	end
	else begin  // no req from mem
		stall_if <= `LFalse;
		if (pcValid == `LTrue) begin
			data_o <= `ZeroWord;
			address_o <= pc_address;
			RWflag <= 1'b0;
		end
		else begin
			address_o <= `ZeroWord;
			RWflag <= 1'b0;
		end
	end
end
endmodule