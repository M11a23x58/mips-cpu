/*
Byte Order : Big-endian 
ADDR |   0x3   |   0x2   |   0x1   |   0x0   |
DATA | [ 7: 0] | [15: 8] | [23:16] | [31:24] |

This is a simple memory.
Give addr get data, store data at posedge when WEN

*/
module dram
#(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 12,
	parameter MEMORY_FILE = "./tb/dram.dat"
)
(
	input CLK,
	input RST,
	// Interface
	input WEN,
	input [$clog2(DATA_WIDTH)-3:0] wwide, // memory write wide, if wide=x then wide is 8*x, for example, wide=1 means write byte, wide=2 means write half 
	input [ADDR_WIDTH-1:0] addr,
	input [DATA_WIDTH-1:0] wdata,
	output reg[DATA_WIDTH-1:0] rdata

);
	reg [7:0] mem [0:(1<<ADDR_WIDTH)-1];

	integer idx;
	initial $readmemh(MEMORY_FILE, mem);


	always @(*)begin
		for (idx=0; idx < DATA_WIDTH>>3; idx=idx+1) rdata[8*idx+:8] = mem[addr+3-idx];
	end

	always @(posedge CLK)begin
		if(WEN) for (idx=0; idx<wwide; idx=idx+1) mem[addr+3-idx] <= wdata[idx*8+:8];
	end


endmodule // dram