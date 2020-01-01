// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

/*
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end
*/
wire[1:0]            RW_type;
wire[`RegBus]        address;
wire[`RegBus]         pc_address;
wire[7:0]           wdata;
wire[7:0]           mem_data_o;
wire                 isPcValid;
wire                 stall_if_flag;
wire                 isEnabled;

spark spark0(
  .clk(clk_in), .rst(rst_in),

  .RWtype_o(RW_type), .ram_addr_o(address),
  .ram_data_o(wdata), .ram_data_i(mem_data_o), 
  .stall_if_i(stall_if_flag), 
  .rom_addr_o(pc_address),
  .ram_ce(isEnabled),
  .pcValid_o(isPcValid)
);

memManager memManager0(
  .clk(clk_in),
  .data_i(mem_din), .data_o(mem_dout),
  .address_o(mem_a), .RWflag(mem_wr),


  .cpu_data_i(wdata), .ram_data_o(mem_data_o),
  .type(RW_type),   .address_i(address),
  .pc_address(pc_address),
  .stall_if(stall_if_flag), 

  .ce(isEnabled),
  .pcValid(isPcValid)
);

endmodule