module Regfile
#(
	parameter stack_start = 'hfff
)
(
	input CLK,
	input RST,
	// Read 
	input [4:0] raddr1, raddr2,
	output [`DATA_WIDTH-1:0] rdata1, rdata2,
	// Write
	input [4:0] waddr,
	input [`DATA_WIDTH-1:0] wdata,
	input WEN
);

	integer i;

	reg [`DATA_WIDTH-1:0] RegisterFile [0:31];

	always @(posedge CLK or posedge RST)begin
		if(RST)begin
			for (i=0; i<32; i=i+1) begin
				if (i == 29) RegisterFile[i] <= stack_start;
				else RegisterFile[i] <= 'd0;
			end
		end else if (WEN & (waddr != 'd0)) begin
			RegisterFile[waddr] <= wdata;
		end
	end
	// Internal Forwarding
	assign rdata1 = (WEN && (waddr != 'd0) && (waddr == raddr1))? wdata : RegisterFile[raddr1];
	assign rdata2 = (WEN && (waddr != 'd0) && (waddr == raddr2))? wdata : RegisterFile[raddr2];
endmodule