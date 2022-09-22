module PC(
	input CLK,
	input RST,
	input [31:0] npc,
	output reg [31:0] pc,
	input stall
	);

	always @(posedge CLK or posedge RST)begin
		if(RST) pc <= 'h00400000;
		else if (~stall) pc <= npc;
	end

endmodule