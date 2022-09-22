
module ALU(
	input [`DATA_WIDTH-1:0] src1,
	input [`DATA_WIDTH-1:0] src2,
	input [4:0] ALUop,
	input [4:0] shamt,
	output reg [`DATA_WIDTH-1:0] ALUout
	);
	
	always @(*)begin
		ALUout = 'dx;
		case(ALUop)
			`alu_add: ALUout = $signed(src1) + $signed(src2);
			`alu_sub: ALUout = $signed(src1) - $signed(src2);
			`alu_and: ALUout = src1 & src2;
			`alu_or : ALUout = src1 | src2;
			`alu_xor: ALUout = src1 ^ src2;
			`alu_nor: ALUout = ~(src1 | src2);
			`alu_slt: ALUout = ($signed(src1) < $signed(src2))? 1 : 0;
			`alu_sll: ALUout = src2 << shamt;
			`alu_srl: ALUout = src2 >> shamt;
			`alu_sra: ALUout = $signed(src2) >>> shamt;
			`alu_sltu: ALUout = (src1 <src2)? 1 : 0;
		endcase // ALUop
	end

endmodule