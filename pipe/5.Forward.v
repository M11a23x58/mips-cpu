module Forward (
	input [4:0] reg_waddr_EXE,
	input [4:0] reg_waddr_MEM,
	input [4:0] reg_waddr_WB,
	input       reg_write_EXE,
	input       reg_write_MEM,
	input       reg_write_WB,
	input [4:0] Rs_EXE,
	input [4:0] Rt_EXE,
	input [4:0] Rs_ID,
	input [4:0] Rt_ID,

	output [1:0] ForwardSrc1,
	output [1:0] ForwardSrc2,

	output [1:0] fwd_Rs_sel,
	output [1:0] fwd_Rt_sel

);
	assign ForwardSrc1 = (reg_write_MEM & (reg_waddr_MEM != 0) & (reg_waddr_MEM == Rs_EXE))? 'b10 :
						 (reg_write_WB  & (reg_waddr_WB != 0)  & (reg_waddr_WB == Rs_EXE ))? 'b01 : 'b00;
	assign ForwardSrc2 = (reg_write_MEM & (reg_waddr_MEM != 0) & (reg_waddr_MEM == Rt_EXE))? 'b10 :
						 (reg_write_WB  & (reg_waddr_WB != 0)  & (reg_waddr_WB == Rt_EXE ))? 'b01 : 'b00;


	assign fwd_Rs_sel = (reg_write_EXE & (reg_waddr_EXE != 0) & (reg_waddr_EXE == Rs_ID))? 'b10 :
						(reg_write_MEM & (reg_waddr_MEM != 0) & (reg_waddr_MEM == Rs_ID))? 'b01 : 'b00;
	assign fwd_Rt_sel = (reg_write_EXE & (reg_waddr_EXE != 0) & (reg_waddr_EXE == Rt_ID))? 'b10 :
						(reg_write_MEM & (reg_waddr_MEM != 0) & (reg_waddr_MEM == Rt_ID))? 'b01 : 'b00;
endmodule