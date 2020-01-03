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
		case (aluop_i)
			`EXE_OP_LW: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b01;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				delayed_waddr <= wAddr_i;
				wreg_o <= `WriteDisable;
			end
			`EXE_OP_LH: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b01;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				delayed_waddr <= wAddr_i;
				wreg_o <= `WriteDisable;
			end
			`EXE_OP_LB: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b01;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wreg_o <= `WriteDisable;
				delayed_waddr <= wAddr_i;
			end
			`EXE_OP_LBU: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b01;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wreg_o <= `WriteDisable;
				delayed_waddr <= wAddr_i;
			end
			`EXE_OP_LHU: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b01;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wreg_o <= `WriteDisable;
				delayed_waddr <= wAddr_i;
			end
			`EXE_OP_SW: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b10;
				ram_data_o <= wData_i[7:0];
				content <= wData_i;
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wData_o <= wData_i;
				wAddr_o <= wAddr_i;
				wreg_o <= `WriteDisable;
			end
			`EXE_OP_SH: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b10;
				content <= wData_i;
				ram_data_o <= wData_i[7:0];
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wData_o <= wData_i;
				wAddr_o <= wAddr_i;
				wreg_o <= `WriteDisable;
			end
			`EXE_OP_SB: begin
				LS_done_flag <= 3'b001;
				this <= aluop_i;
				stallFlag <= `STOP;
				RWtype <= 2'b10;
				content <= wData_i;
				ram_data_o <= wData_i[7:0];
				target_addr <= addr_i;
				ram_addr <= addr_i;
				wData_o <= wData_i;
				wAddr_o <= wAddr_i;
				wreg_o <= `WriteDisable;
			end
			default: begin
				RWtype <= 2'b00;
				LS_done_flag <= 3'b000;
				//this <= 6'b000000;
				stallFlag <= `NOSTOP;
				wData_o <= wData_i;
				wAddr_o <= wAddr_i;
				wreg_o <= wreg_i;
			end
		endcase
		case (this)
			`EXE_OP_LW: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
					end
					3'b010: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 2;
						stallFlag <= `LTrue;
						result[7:0] <= ram_data_i[7:0];
						wreg_o <= `WriteDisable;
					end
					3'b011: begin
						RWtype <= 2'b01;
						ram_addr <= target_addr + 3;
						stallFlag <= `LTrue;
						result[15:8] <= ram_data_i[7:0];
						wreg_o <= `WriteDisable;
					end
					3'b100: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						result[23:16] <= ram_data_i[7:0];
						wreg_o <= `WriteDisable;
					end
					3'b101: begin
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
						ram_addr <= target_addr + 1;
						wreg_o <= `WriteDisable;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
						result[7:0] <= ram_data_i[7:0];
					end
					3'b011: begin
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
						RWtype <= 2'b00;
						wreg_o <= `WriteDisable;
						ram_addr <= `ZeroWord;
						stallFlag <= `LTrue;
					end
					3'b010: begin
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
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
					end
					3'b010: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						result[7:0] <= ram_data_i[7:0];
						wreg_o <= `WriteDisable;
					end
					3'b011: begin
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
						RWtype <= 2'b00;
						ram_addr <= `ZeroWord;
						wreg_o <= `WriteDisable;
						stallFlag <= `LTrue;
					end
					3'b010: begin
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
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
					end
					3'b010: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						wData_o <= wData_i;
						wAddr_o <= wAddr_i;
						stallFlag <= `LFalse;
						wreg_o <= `WriteDisable;
						this <= 6'b000000;
					end
				endcase
			end
			`EXE_OP_SH: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 1;
						ram_data_o <= content[15:8];
						wreg_o <= `WriteDisable;
						stallFlag <= `LTrue;
					end
					3'b010: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
					end
					3'b011: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						this <= 6'b000000;
						wreg_o <= `WriteDisable;
						stallFlag <= `LFalse;
					end
				endcase
			end
			`EXE_OP_SW: begin
				LS_done_flag <= LS_done_flag + 1;
				case (LS_done_flag)
					3'b001: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 1;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
						ram_data_o <= content[15:8];
					end
					3'b010: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 2;
						stallFlag <= `LTrue;
						ram_data_o <= content[23:16];
						wreg_o <= `WriteDisable;
					end
					3'b011: begin
						RWtype <= 2'b10;
						ram_addr <= target_addr + 3;
						stallFlag <= `LTrue;
						ram_data_o <= content[31:24];
						wreg_o <= `WriteDisable;
					end
					3'b100: begin
						RWtype <= 2'b00;
						stallFlag <= `LTrue;
						wreg_o <= `WriteDisable;
					end
					3'b101: begin
						RWtype <= 2'b00;
						LS_done_flag <= 3'b000;
						stallFlag <= `LFalse;
						this <= 6'b000000;
						wreg_o <= `WriteDisable;
					end
				endcase
			end
			default: begin
				/*
				RWtype <= 2'b00;
				LS_done_flag <= 3'b000;
				wData_o <= wData_i;
				stallFlag <= `NOSTOP;
				wAddr_o <= wAddr_i;
				wreg_o <= wreg_i;
				*/
			end
		endcase 	

	end
end

endmodule