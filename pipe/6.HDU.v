module HDU (
	input is_lw_EXE,
	input [4:0] Rt_EXE,
	input [4:0] Rs_ID,
	input [4:0] Rt_ID,

	output hazard_detected
);

	assign hazard_detected = (is_lw_EXE & ((Rt_EXE == Rs_ID) || (Rt_EXE == Rt_ID)))? 1 : 0;


endmodule