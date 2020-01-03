module pc_reg(
	input wire						clk,
	input wire						rst,
	input wire[5:0]					stall,

	// Branch
	input 	wire 					branchFlag_i,
	input	wire[`InstAddrBus]		branchTarget_i,


	output  reg[`InstAddrBus] 		pc_o,
	output	reg[`InstBus]			inst_o,
	output 	reg[`RegBus]			ram_addr_o,
	output	reg 					pcValid,
	output  reg                     ce,
	// to stall, just use NOP  		

	input	wire[7:0] 					ram_data_i,

	// to cache
	output	reg 					req2cahce,
	output	reg[`InstBus]			inst2cache,
	output	reg 					cache_we,

	input	wire[`InstBus]			inst_from_cache
);


reg[`InstBus] inst;

reg[2:0] state; 
reg[`InstAddrBus] pc;
reg[`RegBus] inst_cnt;

always @(posedge clk) begin
	if (rst == `RstEnable) begin
		// reset
		state <= 3'b000;
		inst_cnt <= `ZeroWord;
		ce <= `ChipDisable;
	end
	else begin
		ce <= `ChipEnable;
	end
end

always @(posedge clk) begin
	if (ce == `ChipDisable) begin
		// reset
		pc <= `ZeroWord;
		pcValid <= `LFalse;
		inst_o <= `ZeroWord;
	end
	else if(stall[0] == `NOSTOP) begin
		if (branchFlag_i == `LTrue) begin // 是否需要向Cache发出取指令请求
			req2cahce <= `LTrue;
			pc_o <= branchTarget_i;
			pc <= branchTarget_i;
		end
		else if(state == 3'b000) begin
			pc_o <= pc;
			req2cahce <= `LTrue;
		end
		else begin
			req2cahce <= `LFalse;
			pc_o <= pc;
		end
		cache_we <= `WriteDisable;
		if (state == 3'b000 || branchFlag_i == `LTrue || inst_from_cache == `ZeroWord) begin
			// cache miss
			pcValid <= `LFalse;
			inst_o <= `ZeroWord;

			state <= state + 1;
			if (branchFlag_i == `LTrue) begin
				state <= 3'b001;
				ram_addr_o <= branchTarget_i;
				pcValid <= `LTrue;
			end
			else if (state == 3'b000) begin
				ram_addr_o <= pc;
				pcValid <= `LTrue;
			end
			else begin
				case (state)
				3'b001: begin
					pcValid <= `LTrue;
					ram_addr_o <= pc + 1;
					inst_o <= `ZeroWord;
				end 
				3'b010: begin
					pcValid <= `LTrue;
					ram_addr_o <= pc + 2;
					inst[7:0] <= ram_data_i[7:0];
					inst_o <= `ZeroWord;
				end
				3'b011: begin
					pcValid <= `LTrue;
					ram_addr_o <= pc + 3;
					inst[15:8] <= ram_data_i[7:0];
					inst_o <= `ZeroWord;
				end
				3'b100: begin
					pcValid <= `LFalse;
					inst[23:16] <= ram_data_i[7:0];
					inst_o <= `ZeroWord;
				end
				3'b101:begin
					pcValid <= `LFalse;
					pc <= pc + 4;
					state <= 3'b000;
					cache_we <= `WriteEnable;
					inst2cache <= {ram_data_i[7:0],inst[23:0]};
					inst_o <= {ram_data_i[7:0],inst[23:0]};
					inst_cnt <= inst_cnt + 1;
				end
				endcase
			end
		end
		else begin
			// cache hit
			inst_o <= inst_from_cache;
			state <= 3'b000;
			pcValid <= `LFalse;
			pc <= pc + 4;
			cache_we <= `WriteDisable;
			inst_cnt <= inst_cnt + 1;
		end
	end
	else begin
		state <= 3'b000;
		pcValid <= `LFalse;
		req2cahce <= `LFalse;
		cache_we <= `WriteDisable;
	end
end
endmodule