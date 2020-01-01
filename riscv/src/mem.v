module mem(
	input		wire				rst,
	input 		wire 				clk,
	//From EXE
	input		wire[`RegAddrBus]	wAddr_i,
	input		wire				wreg_i,
	input		wire[`RegBus]		wData_i,
	input		wire[`AluOpBus]		aluop_i,
	input		wire[`RegBus]		addr_i,

	//Result
	output		reg[`RegAddrBus]	wAddr_o,
	output		reg 				wreg_o,
	output		reg[`RegBus]		wData_o,

	//from/to  memory manager
	input 		wire[7:0]			ram_data_i,		
	output		reg[1:0]			RWtype,
	output		reg[`RegBus]		ram_addr,
	output		reg[7:0]		ram_data_o,	

	//control
	output		reg 				stallFlag
);

reg[2:0] 			LS_done_flag; 

wire[`RegBus] zero32;
reg [`AluOpBus] this;
reg [`RegBus] result;
reg [`RegBus] content;
reg [`RegBus] target_addr;
reg [`RegAddrBus] delayed_waddr;

assign zero32 = `ZeroWord;

always @(posedge clk) begin
	if (aluop_i != 6'b000000) begin
		this <= aluop_i;
		content <= wData_i;
		target_addr <= addr_i;
		delayed_waddr <= wAddr_i;
	end
	if (rst == `RstEnable) begin
		// reset
		wAddr_o <= `NOPRegAddr;
		wreg_o <= `WriteDisable;
		wData_o <= `ZeroWord;

		RWtype <= 2'b00;
		ram_addr <= `ZeroWord;
		ram_data_o <= `ZeroWord;
		LS_done_flag <= 3'b000;
		stallFlag <= `LFalse;
		result <= `ZeroWord;
	end
	else begin
		wData_o <= ram_data_i;
		wAddr_o <= wAddr_i;
		wreg_o <= wreg_i;
		stallFlag <= `LFalse;
		case (this)
			`EXE_OP_LW: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 2;
						stallFlag <= `LTrue;
						result[7:0] <= ram_data_i[7:0];
					end
					3'b100: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 3;
						stallFlag <= `LTrue;
						result[15:8] <= ram_data_i[7:0];
					end
					3'b101: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						result[23:16] <= ram_data_i[7:0];
					end
					3'b110: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wAddr_o <= delayed_waddr;
						wreg_o <= `WriteEnable;
						stallFlag <= `LFalse;
						this <= 6'b000000;
						wData_o <= {ram_data_i[7:0],result[23:0]};
					end
				endcase
			end
			`EXE_OP_LH: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						result[7:0] <= ram_data_i[7:0];
					end
					3'b100: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wAddr_o <= delayed_waddr;
						wreg_o <= `WriteEnable;
						stallFlag <= `LFalse;
						this <= 6'b000000;
						wData_o <= {{16{ram_data_i[7]}},ram_data_i[7:0],result[7:0]};
					end
				endcase
			end
			`EXE_OP_LB: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b00;
						ram_addr <= `ZeroWord;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wData_o <= {{24{ram_data_i[7]}},ram_data_i[7:0]};
						wAddr_o <= delayed_waddr;
						wreg_o <= `WriteEnable;
						this <= 6'b000000;
						stallFlag <= `LFalse;
					end
				endcase		
			end
			`EXE_OP_LHU: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						result[7:0] <= ram_data_i[7:0];
					end
					3'b100: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wAddr_o <= delayed_waddr;
						wreg_o <= `WriteEnable;
						stallFlag <= `LFalse;
						this <= 6'b000000;
						wData_o <= {zero32[31:16],ram_data_i[7:0],result[7:0]};
					end
				endcase
			end
			`EXE_OP_LBU: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b00;
						ram_addr <= `ZeroWord;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wData_o <= {zero32[31:8],ram_data_i[7:0]};
						wAddr_o <= delayed_waddr;
						wreg_o <= `WriteEnable;
						this <= 6'b000000;
						stallFlag <= `LFalse;
					end
				endcase
			end
			`EXE_OP_SB: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						//$display("SB");
						RWtype <= 2'b10;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
						ram_data_o <= content[7:0];
					end
					3'b010: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wData_o <= wData_i;
						wAddr_o <= wAddr_i;
						wreg_o <= wreg_i;
						stallFlag <= `LFalse;
						this <= 6'b000000;
					end
				endcase
			end
			`EXE_OP_SH: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
						ram_data_o <= content[7:0];
					end
					3'b010: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 1;
						ram_data_o <= content[15:8];
						stallFlag <= `LTrue;
					end
					3'b011: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
					end
					3'b100: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						this <= 6'b000000;
						stallFlag <= `LFalse;
					end
				endcase
			end
			`EXE_OP_SW: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr;
						stallFlag <= `LTrue;
						ram_data_o <= content[7:0];
					end
					3'b010: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
						ram_data_o <= content[15:8];
					end
					3'b011: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 2;
						stallFlag <= `LTrue;
						ram_data_o <= content[23:16];
					end
					3'b100: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 3;
						stallFlag <= `LTrue;
						ram_data_o <= content[31:24];
					end
					3'b101: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
					end
					3'b110: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						stallFlag <= `LFalse;
						this <= 6'b000000;
					end
				endcase
			end
			default: begin
				RWtype <= 2'b00;
				LS_done_flag <= 3'b000;
				wData_o <= wData_i;
				stallFlag <= `NOSTOP;
			end
		endcase 	

	end
end

endmodule