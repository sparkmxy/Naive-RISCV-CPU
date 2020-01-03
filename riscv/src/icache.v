module Icache(
	input 	wire 					rst,
	input	wire 					clk,

	input	wire 					pcValid,
	input  	wire 					we,
	input 	wire[`InstAddrBus]		pc_address_i,
	input	wire[`InstBus]			inst_i,

	output	reg[`InstBus]			inst_o			
);


reg[`TagLength - 1: 0] 	tags[0:`NumOfLines - 1];
reg[`InstBus]			instrs[0:`NumOfLines - 1];


always @(*) begin
	if (rst == `RstEnable || pcValid == `LFalse) begin
		inst_o <= `ZeroWord;
	end
	else if(pcValid == `LTrue)begin
		if (pc_address_i[31 : `IndexLength] == tags[pc_address_i[`IndexLength - 1 : 0]][`TagLength-1 : 0]) begin
			inst_o <= instrs[pc_address_i[`IndexLength - 1 : 0]];
		end
		else begin
			inst_o <= `ZeroWord;
		end
	end
	else begin
		inst_o <= `ZeroWord;
	end
end

always @(posedge clk) begin
	if (rst == `RstDisable) begin
		if (we == `WriteEnable) begin
			instrs[pc_address_i[`IndexLength-1 : 0]] = inst_i;
			tags[pc_address_i[`IndexLength - 1 : 0]] = pc_address_i[31 : `IndexLength];
		end		
	end
end
endmodule
