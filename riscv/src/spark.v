module	spark(
	input		wire 				clk,
	input		wire				rst,

	// from/to memory manager
	input  		wire[`RegBus]		ram_data_i,
	output  	wire[7:0]			ram_data_o,
	output 		wire[`InstAddrBus]	rom_addr_o,
	output 		wire[`InstAddrBus]	ram_addr_o,
	output 		wire[1:0]			RWtype_o,
	output 		wire 				ram_ce,
	output		wire				pcValid_o,
	
	input 		wire 				stall_if_i
);
	
	wire[`InstAddrBus]				branch_target;
	wire							branch_flag;
	wire[`InstBus]					if_inst_o;
	//IF/ID -> ID
	wire[`InstAddrBus] 				pc;
	wire[`InstAddrBus]				id_pc_i;
	wire[`InstBus]					id_inst_i;

	//ID -> ID/EX
	wire[`AluOpBus]					id_aluop_o;
	wire[`AluSelBus]				id_alusel_o;
	wire[`RegBus]					id_reg1_o;
	wire[`RegBus]					id_reg2_o;
	wire[`RegAddrBus]				id_wAddr_o;
	wire							id_wreg_o;
	wire[`InstBus]					id_inst_o;

	// ID/EX -> EX
	wire[`InstBus]					exe_inst_i;
	wire[`AluOpBus]					exe_aluop_i;
	wire[`AluSelBus]				exe_alusel_i;
	wire[`RegBus]					exe_reg1_i;
	wire[`RegBus]					exe_reg2_i;
	wire[`RegAddrBus]				exe_wAddr_i;
	wire							exe_wreg_i;

	// EX -> EX/MEM
	wire[`RegAddrBus]				exe_wAddr_o;
	wire							exe_wreg_o;
	wire[`RegBus]					exe_wData_o;
	wire[`InstBus]					exe_inst_o;
	wire[`AluOpBus]					exe_aluop_o;
	wire[`RegBus]					exe_addr_o;

	//EX/MEM -> MEM
	wire[`RegBus]					mem_addr_i;
	wire[`AluOpBus]					mem_aluop_i;
	wire[`InstBus]					mem_inst_i;
	wire[`RegAddrBus]				mem_wAddr_i;
	wire							mem_wreg_i;
	wire[`RegBus]					mem_wData_i;

	//MEM -> MEM/WB
	wire[`RegAddrBus]				mem_wAddr_o;
	wire							mem_wreg_o;
	wire[`RegBus]					mem_wData_o;
	wire[1:0]						mem_RWtype;

	wire[`RegAddrBus]				mem_wAddr2id;
	wire							mem_wreg2id;
	wire[`RegBus]					mem_wData2id;

	//MEM/WB -> WB
	wire[`RegAddrBus]				wb_wAddr_i;
	wire							wb_wreg_i;
	wire[`RegBus]					wb_wData_i;

	//ID & Regfile
	wire							reg1_read;
	wire							reg2_read;
	wire[`RegBus]					reg1_data;
	wire[`RegBus]					reg2_data;
	wire[`RegAddrBus]				reg1_addr;
	wire[`RegAddrBus]				reg2_addr;	

	//Control
	wire							stallFlag_id;
	wire							stallFlag_mem;
	wire 							stallFlag_exe;
	wire[5:0]						stall_o;

	// cache 
	wire 							cache_we;
	wire 							if_req2cache;
	wire[`InstBus]					if_inst2cache;
	wire[`InstBus]					cache2if_inst;

		
	assign RWtype_o = mem_RWtype;
	//Instantiation of pc_reg

	pc_reg pc_reg0(
		.clk(clk), .rst(rst), .pc_o(pc),
		.stall(stall_o), .ce(ram_ce),
		.branchTarget_i(branch_target),
		.branchFlag_i(branch_flag),
		.pcValid(pcValid_o),
		.ram_data_i(ram_data_i),
		.ram_addr_o(rom_addr_o),
		.inst_o(if_inst_o),

		// to/from cache
		.req2cahce(if_req2cache),
		.inst2cache(if_inst2cache),
		.cache_we(cache_we),
		.inst_from_cache(cache2if_inst)
	);


	//Instantiation of IF/ID module
	if_id if_id0(
		.clk(clk), .rst(rst), .if_pc(pc),
		.if_inst(if_inst_o), .id_pc(id_pc_i),
		.id_inst(id_inst_i),
		
		.stall(stall_o)
	);

	//Instantiation of ID module
	id id0(
		.rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),

		// Input from Regfile
		.reg1_data_i(reg1_data), .reg2_data_i(reg2_data),

		// Send to Regfile
		.reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),

		// Send to ID/EX
		.aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
		.wreg_o(id_wreg_o),	.wAddr_o(id_wAddr_o),

		// Data forwarding, from EXE and MEM
		.exe_wreg_i(exe_wreg_o), .exe_wAddr_i(exe_wAddr_o),
		.exe_wData_i(exe_wData_o),
		.ex_mem_wreg_i(mem_wreg2id), .ex_mem_wAddr_i(mem_wAddr2id),
		.ex_mem_wData_i(mem_wData2id),
		.mem_wreg_i(mem_wreg_o), .mem_wAddr_i(mem_wAddr_o),
		.mem_wData_i(mem_wData_o),

		.stallFlag(stallFlag_id),

		.branchFlag(branch_flag), 
		.branchTarget(branch_target),

		.inst_o(id_inst_o)
	);


	//Instantiation of Regfile module
	regfile regfile0(
		.clk(clk), .rst(rst),
		.wEnable(wb_wreg_i), .wAddr(wb_wAddr_i),
		.wData(wb_wData_i),
		.r1Enable(reg1_read), .r2Enable(reg2_read),
		.r1Addr(reg1_addr),  .r2Addr(reg2_addr),
		.r1Data(reg1_data),	 .r2Data(reg2_data)
	);

	//Instantiation of ID/EXE

	id_exe id_exe0(
		.clk(clk), .rst(rst),

		// From ID
		.id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),   .id_reg2(id_reg2_o),
		.id_wAddr(id_wAddr_o), .id_wreg(id_wreg_o),
		
		// To EXE
		.exe_aluop(exe_aluop_i), .exe_alusel(exe_alusel_i),
		.exe_reg1(exe_reg1_i), 	.exe_reg2(exe_reg2_i),
		.exe_wAddr(exe_wAddr_i), .exe_wreg(exe_wreg_i),

		.stall(stall_o),
		
		.id_inst(id_inst_o), .exe_inst(exe_inst_i)
	);

	//Instantiation of EXE
	exe exe0(
		// From ID/EXE
		.aluop_i(exe_aluop_i), .alusel_i(exe_alusel_i),
		.reg1_i(exe_reg1_i), 	.reg2_i(exe_reg2_i),
		.wAddr_i(exe_wAddr_i), 	.wreg_i(exe_wreg_i),

		//To EXE/MEM
		.wAddr_o(exe_wAddr_o), .wreg_o(exe_wreg_o),
		.wData_o(exe_wData_o),

		.inst_i(exe_inst_i), 
		.aluop_o(exe_aluop_o),
		.mem_addr_o(exe_addr_o),

		.stallFlag(stallFlag_exe)
	);


	//Instantiation of EXE/MEM

	exe_mem exe_mem0(
		//From EXE
		.clk(clk), .rst(rst),
		.exe_wAddr(exe_wAddr_o), .exe_wreg(exe_wreg_o),
		.exe_wData(exe_wData_o), .exe_aluop(exe_aluop_o),

		//To MEM
		.mem_wAddr(mem_wAddr_i), .mem_wreg(mem_wreg_i),
		.mem_wData(mem_wData_i), .mem_aluop(mem_aluop_i),

		.stall(stall_o),
		.mem_addr(mem_addr_i),
		.exe_mem_addr(exe_addr_o),

		.wAddr2id(mem_wAddr2id),
		.wData2id(mem_wData2id),
		.wreg2id(mem_wreg2id)
	);

	//Instantiation of MEM
	mem mem0(
		.rst(rst), .clk(clk),

		//From EXE
		.wAddr_i(mem_wAddr_i), .wreg_i(mem_wreg_i),
		.wData_i(mem_wData_i),
		.aluop_i(mem_aluop_i), .addr_i(mem_addr_i),
		//To MEM/WB
		.wAddr_o(mem_wAddr_o), .wreg_o(mem_wreg_o),
		.wData_o(mem_wData_o),


		// from/to memory manager
		.RWtype(mem_RWtype),
		.ram_data_i(ram_data_i),
		.ram_addr(ram_addr_o),
		.ram_data_o(ram_data_o),

		.stallFlag(stallFlag_mem)
	);

	//Instantiation of MEM/WB
	mem_wb mem_wb0(
		.clk(clk), .rst(rst),

		//From MEM
		.mem_wAddr(mem_wAddr_o), .mem_wreg(mem_wreg_o),
		.mem_wData(mem_wData_o),

		//To WB
		.wb_wAddr(wb_wAddr_i), .wb_wreg(wb_wreg_i),
		.wb_wData(wb_wData_i),

		.stall(stall_o)
	);


	//Instantiation of control
	control control0(
		.rst(rst), 
		.stall_from_id(stallFlag_id),
		.stall_from_mem(stallFlag_mem),
		.stall_from_ram(stall_if_i),
		.stall_from_exe(stallFlag_exe),
		.stall(stall_o)
	);

	//Instantiation of I-cahce
	Icache Icache0(
		.rst(rst), .clk(clk),
		.pcValid(if_req2cache), .we(cache_we),
		.pc_address_i(pc),
		.inst_i(if_inst2cache),
		.inst_o(cache2if_inst)
	); 
endmodule
