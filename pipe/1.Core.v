
module Core(
	input CLK,
	input RST,

	// IM Interface
	output [`ADDR_WIDTH-1:0] IM_addr, // PC
	input  [`DATA_WIDTH-1:0] IM_rdata, // Inst.
	output IM_WEN, // always read
	input IM_stall,
	// DM Interface
	output [`ADDR_WIDTH-1:0] DM_addr,
	input  [`DATA_WIDTH-1:0] DM_rdata,
	output [`DATA_WIDTH-1:0] DM_wdata,
	output DM_WEN,
	input DM_stall,
	 // End program
	output finish
	);

	wire pc_stall = 1'b0;
	wire [`ADDR_WIDTH-1:0] npc;
	// pipeline reg
	wire [`ADDR_WIDTH-1:0] pc_seq_IF;
	reg  [`ADDR_WIDTH-1:0] pc_seq_ID;
	reg  [`ADDR_WIDTH-1:0] pc_seq_EXE;
	reg  [`ADDR_WIDTH-1:0] pc_seq_MEM;
	reg  [`ADDR_WIDTH-1:0] pc_seq_WB;


	wire [`DATA_WIDTH-1:0] inst_IF;
	reg  [`DATA_WIDTH-1:0] inst_ID;

// Start From ID
	wire [            5:0] opcode;

	wire [            4:0] Rs_ID    ;
	reg  [            4:0] Rs_EXE    ;

	wire [            4:0] Rt_ID    ;
	reg  [            4:0] Rt_EXE    ;

	wire [            4:0] Rd_ID    ;
	reg  [            4:0] Rd_EXE    ;

	wire [            4:0] shamt_ID ;
	reg  [            4:0] shamt_EXE ;


	wire [            5:0] funct;
	reg  [            5:0] funct_EXE ;

	wire [           15:0] Imm_ID   ;
	reg  [           15:0] Imm_EXE   ;


	wire [           25:0] target_ID;


	wire [`DATA_WIDTH-1:0] sImm_ID ;
	wire [`DATA_WIDTH-1:0] sImm_EXE ;


	wire [`DATA_WIDTH-1:0] RsData_ID;
	reg  [`DATA_WIDTH-1:0] RsData_EXE;

	wire [`DATA_WIDTH-1:0] RtData_ID;
	reg  [`DATA_WIDTH-1:0] RtData_EXE;
	reg  [`DATA_WIDTH-1:0] RtData_MEM;

	wire [            4:0] ALUop_ID ;
	reg  [            4:0] ALUop_EXE ;

	wire [            1:0] ALUSrc2_sel_ID;
	reg  [            1:0] ALUSrc2_sel_EXE;


	wire                   ALUShamt_sel_ID;
	reg                    ALUShamt_sel_EXE;

	wire [            1:0] pcSrc_ID;
	wire [            1:0] reg_waddr_sel_ID;
	reg  [            1:0] reg_waddr_sel_EXE;

	wire [            1:0] reg_wdata_sel_ID;
	reg  [            1:0] reg_wdata_sel_EXE;
	reg  [            1:0] reg_wdata_sel_MEM;
	reg  [            1:0] reg_wdata_sel_WB;


	wire                   reg_write_ID;
	reg                    reg_write_EXE;
	reg                    reg_write_MEM;
	reg                    reg_write_WB;

	wire                   DM_WEN_ID;
	reg                    DM_WEN_EXE;
	reg                    DM_WEN_MEM;

	wire [            1:0] fwd_Rs_sel;
	wire [            1:0] fwd_Rt_sel;

	wire [`DATA_WIDTH-1:0] branch_Rs_ID;
	wire [`DATA_WIDTH-1:0] branch_Rt_ID;
	wire                   branch_tacken_ID;

	wire [`ADDR_WIDTH-1:0] pc_branch_ID;
	wire [`ADDR_WIDTH-1:0] pc_jump_ID;

// Start From EXE
	wire [`DATA_WIDTH-1:0] zImm_EXE  ;

	wire [            4:0] reg_waddr_EXE;
	reg  [            4:0] reg_waddr_MEM;
	reg  [            4:0] reg_waddr_WB;

	wire [`DATA_WIDTH-1:0] ALUout_EXE;
	reg  [`DATA_WIDTH-1:0] ALUout_MEM;
	reg  [`DATA_WIDTH-1:0] ALUout_WB;

	wire [`DATA_WIDTH-1:0] forward_DM_rdata_EXE;
	reg  [`DATA_WIDTH-1:0] forward_DM_rdata_MEM;

	reg                    is_lw_EXE;

	wire                   hazard_detected_EXE;
// Strat From MEM
	wire [`DATA_WIDTH-1:0] DM_rdata_MEM;
	reg  [`DATA_WIDTH-1:0] DM_rdata_WB;

// Start From WB
	wire [`DATA_WIDTH-1:0] reg_wdata_WB;

	wire IF_ID_Flush;
	
	// datapath	
//==================//
//                  //
//     IF stage     //
//                  //
//==================//			   
	PC pc(
	 .CLK( CLK ),
	 .RST( RST ),
	 .npc( npc ),
	 .pc( IM_addr ),
	 .stall( hazard_detected_EXE|finish_id )
	);

	assign inst_IF = IM_rdata;
	assign pc_seq_IF = IM_addr + 4;
	// pc_reg : pc_branch : pc_jump : pc_seq
	assign npc = (pcSrc_ID == 'd3)? branch_Rs_ID :
				 (pcSrc_ID == 'd2)? pc_branch_ID :
				 (pcSrc_ID == 'd1)? pc_jump_ID   :
				 (pcSrc_ID == 'd0)? pc_seq_IF    : 'dx;

//==================//
//                  //
//     ID stage     //
//                  //
//==================//
	assign opcode    = inst_ID[31:26];
	assign funct     = inst_ID[ 5: 0];
	assign Rs_ID     = inst_ID[25:21];
	assign Rt_ID     = inst_ID[20:16];
	assign Rd_ID     = inst_ID[15:11];
	assign shamt_ID  = inst_ID[10: 6];
	assign Imm_ID    = inst_ID[15: 0];
	assign sImm_ID   = {{16{Imm_ID[15]}}, Imm_ID};
	assign target_ID = inst_ID[25: 0];
	assign reg_waddr_sel_ID = (`is_jal)? 'd2 : 
					      (`is_R  )? 'd1 : 'd0;  // 'd31 : Rd : Rt
	assign reg_write_ID = ((`is_R & ~`is_R_jr)     ||
						    `is_addiu || `is_andi  ||
						    `is_ori   || `is_xori  ||
						    `is_lui   || `is_lw    ||
						    `is_slti  || `is_sltiu ||
						    `is_jal )? (hazard_detected_EXE)? 0 : 1 : 0;  
	// pc+8 : mem : aluout
	assign reg_wdata_sel_ID = (`is_jal || `is_R_jalr)? 'd2 :
					          (`is_lw )? 'd1  : 'd0;

	assign ALUop_ID = (`is_addiu  )? `alu_add :
				      (`is_andi   )? `alu_and :
				      (`is_ori    )? `alu_or  :
				      (`is_xori   )? `alu_xor :
				      (`is_lui    )? `alu_sll :
				      (`is_lw     )? `alu_add :
				      (`is_sw     )? `alu_add :
				      (`is_beq    )? `alu_sub :
				      (`is_bne    )? `alu_sub :
				      (`is_slti   )? `alu_slt :
				      (`is_sltiu  )? `alu_sltu:
				      (`is_R_sll  )? `alu_sll : 
				      (`is_R_srl  )? `alu_srl :
				      (`is_R_sra  )? `alu_sra :
				      (`is_R_addu )? `alu_add :
				      (`is_R_subu )? `alu_sub :
				      (`is_R_and  )? `alu_and :
				      (`is_R_or   )? `alu_or  :
				      (`is_R_xor  )? `alu_xor :
				      (`is_R_nor  )? `alu_nor :
				      (`is_R_slt  )? `alu_slt :
				      (`is_R_sltu )? `alu_sltu: 'hx;
    // Rt : zImm : sImm
	assign ALUSrc2_sel_ID = (`is_R     || `is_beq || `is_bne)? 'd2 :
					        (`is_andi  || `is_ori || `is_xori || `is_lui)? 'd1 :
					        (`is_addiu || `is_lw  || `is_sw   || `is_slti || `is_sltiu)? 'd0 : 'hx;
	// 'd16 : shamt
	assign ALUShamt_sel_ID = (`is_lui)? 'd1 : 'd0;

	// pc_reg : pc_branch : pc_jump : pc_seq
	assign pcSrc_ID = (`is_R && (`is_R_jr || `is_R_jalr))? 'd3 :
				      (branch_tacken_ID)? 'd2 :
				      (`is_j || `is_jal)? 'd1 : 'd0;

	assign branch_Rs_ID = (fwd_Rs_sel == 'b10)? ALUout_EXE :
					      (fwd_Rs_sel == 'b01)? ALUout_MEM : RsData_ID;
	assign branch_Rt_ID = (fwd_Rt_sel == 'b10)? ALUout_EXE :
					      (fwd_Rt_sel == 'b01)? ALUout_MEM : RtData_ID;
	assign branch_tacken_ID = (((branch_Rs_ID == branch_Rt_ID) & `is_beq) || ((branch_Rs_ID != branch_Rt_ID) & `is_bne));

	assign pc_branch_ID = pc_seq_ID + (sImm_ID << 2);
	assign pc_jump_ID   = {pc_seq_ID[31:28], (target_ID << 2)};

	assign DM_WEN_ID = (`is_sw & ~hazard_detected_EXE & ~`is_syscall)? 1 : 0;

	Regfile
#(
	.stack_start(`STACK)
)
	regfile(
	.CLK( CLK ),
	.RST( RST ),
	// Read 
	.raddr1( Rs_ID ), 
	.raddr2( Rt_ID ),
	.rdata1( RsData_ID ), 
	.rdata2( RtData_ID ),
	// Write
	.waddr( reg_waddr_WB ),
	.wdata( reg_wdata_WB ),
	.WEN  ( reg_write_WB )
	);

	HDU hdu(
	.is_lw_EXE(is_lw_EXE),
	.Rt_EXE(Rt_EXE),
	.Rs_ID(Rs_ID),
	.Rt_ID(Rt_ID),
	.hazard_detected(hazard_detected_EXE)
	);
//==================//
//                  //
//     EXE stage    //
//                  //
//==================//
									 
										 
	wire [            4:0] ALUShamt_EXE = (ALUShamt_sel_EXE)? 'd16 : shamt_EXE;
	wire [            1:0] FwdSrc1;
	wire [            1:0] FwdSrc2;

	wire [`DATA_WIDTH-1:0] ForwardSrc1_EXE = (FwdSrc1 == 'b10)? ALUout_MEM   : 
										     (FwdSrc1 == 'b01)? reg_wdata_WB : RsData_EXE;
	
	wire [`DATA_WIDTH-1:0] ForwardSrc2_EXE = (FwdSrc2 == 'b10)? ALUout_MEM   : 
										     (FwdSrc2 == 'b01)? reg_wdata_WB : RtData_EXE;

	wire [`DATA_WIDTH-1:0] ALUSrc1_EXE = ForwardSrc1_EXE; 
	
	wire [`DATA_WIDTH-1:0] ALUSrc2_EXE = (ALUSrc2_sel_EXE == 'd2)? ForwardSrc2_EXE :
										 (ALUSrc2_sel_EXE == 'd1)? zImm_EXE        :  
										 (ALUSrc2_sel_EXE == 'd0)? sImm_EXE        : 'hx;
	
	assign reg_waddr_EXE =  (reg_waddr_sel_EXE == 'd2)? 'd31 :
							(reg_waddr_sel_EXE == 'd1)? Rd_EXE : 
							(reg_waddr_sel_EXE == 'd0)? Rt_EXE : 'dx;
	
	assign forward_DM_rdata_EXE = (FwdSrc2 == 'b10)? ALUout_MEM :
								  (FwdSrc2 == 'b01)? reg_wdata_WB : RtData_EXE;
	assign zImm_EXE = {16'b0, Imm_EXE};
	assign sImm_EXE = {{16{Imm_EXE[15]}}, Imm_EXE};

	ALU alu(
	.src1( ALUSrc1_EXE ),
	.src2( ALUSrc2_EXE ),
	.ALUop( ALUop_EXE ),
	.shamt( ALUShamt_EXE ),
	.ALUout( ALUout_EXE )
	);

	Forward fwd(
	.reg_waddr_EXE( reg_waddr_EXE ),
	.reg_waddr_MEM( reg_waddr_MEM ),
	.reg_waddr_WB( reg_waddr_WB ),
	.reg_write_EXE( reg_write_EXE ),
	.reg_write_MEM( reg_write_MEM ),
	.reg_write_WB( reg_write_WB ),
	.Rs_EXE( Rs_EXE ),
	.Rt_EXE( Rt_EXE ),
	.Rs_ID( Rs_ID ),
	.Rt_ID( Rt_ID ),

	.ForwardSrc1( FwdSrc1 ),
	.ForwardSrc2( FwdSrc2 ),
	.fwd_Rs_sel( fwd_Rs_sel ),
	.fwd_Rt_sel( fwd_Rt_sel )
	);
//==================//
//                  //
//     MEM stage    //
//                  //
//==================//
	assign DM_addr = ALUout_MEM;
	assign DM_WEN  = DM_WEN_MEM;
	assign DM_wdata = forward_DM_rdata_MEM;
	assign DM_rdata_MEM = DM_rdata;
//==================//
//                  //
//     WB stage    //
//                  //
//==================//
	assign reg_wdata_WB =   (reg_wdata_sel_WB == 'd2)? pc_seq_WB+4 :
							(reg_wdata_sel_WB == 'd1)? DM_rdata_WB :
							(reg_wdata_sel_WB == 'd0)? ALUout_WB   : 'hx;
	wire finish_id = (`is_syscall);
	reg  finish_exe;
	reg  finish_mem;
	reg  finish_wb;
	always @(posedge CLK)begin
		finish_exe <= finish_id;
		finish_mem <= finish_exe;
		finish_wb <= finish_mem;
	end
	assign finish = finish_wb;
//==================//
//                  //
//     pipeline     //
//                  //
//==================//
	// pipeline stage IF->ID
	always @(posedge CLK)begin
		if(RST)begin
			pc_seq_ID <= 'd0;
			inst_ID <= 'd0;
		end else if(~hazard_detected_EXE)begin
			pc_seq_ID <= pc_seq_IF;
			inst_ID <= (finish_id)? {26'b0, 6'd12}: (branch_tacken_ID | `is_j | `is_jal | `is_R_jalr | `is_R_jr)? 'd0 : inst_IF;	
		end
	end
	// pipeline stage ID->EXE
	always @(posedge CLK)begin
		if(RST)begin
			Rs_EXE     <= 'd0;
			Rt_EXE     <= 'd0;
			Rd_EXE     <= 'd0;
			shamt_EXE  <= 'd0;
			funct_EXE  <= 'd0;
			Imm_EXE    <= 'd0;
			RsData_EXE <= 'd0;
			RtData_EXE <= 'd0;
			ALUop_EXE  <= 'd0;
			DM_WEN_EXE <= 'd0;
			is_lw_EXE  <= 'd0;
			pc_seq_EXE <= 'd0;
			ALUSrc2_sel_EXE   <= 'd0;
			ALUShamt_sel_EXE  <= 'd0;
			reg_wdata_sel_EXE <= 'd0;
			reg_write_EXE     <= 'd0;
			reg_waddr_sel_EXE <= 'd0;
		end else begin
			Rs_EXE     <= Rs_ID;
			Rt_EXE     <= Rt_ID;
			Rd_EXE     <= Rd_ID;
			shamt_EXE  <= shamt_ID;
			funct_EXE  <= funct;
			Imm_EXE    <= Imm_ID;
			RsData_EXE <= RsData_ID;
			RtData_EXE <= RtData_ID;
			ALUop_EXE  <= ALUop_ID;
			DM_WEN_EXE <= DM_WEN_ID;
			is_lw_EXE  <= (`is_lw)? (hazard_detected_EXE)? 0 : 1 : 0;
			pc_seq_EXE <= pc_seq_ID;
			ALUSrc2_sel_EXE   <= ALUSrc2_sel_ID;
			ALUShamt_sel_EXE  <= ALUShamt_sel_ID;
			reg_wdata_sel_EXE <= reg_wdata_sel_ID;
			reg_write_EXE     <= reg_write_ID;
			reg_waddr_sel_EXE <= reg_waddr_sel_ID;
		end
	end
	// pipeline stage EXE->MEM
	always @(posedge CLK)begin
		if(RST)begin
			RtData_MEM        <= 'd0;
			reg_waddr_MEM     <= 'd0;
			reg_wdata_sel_MEM <= 'd0;
			reg_write_MEM     <= 'd0;
			ALUout_MEM        <= 'd0;
			DM_WEN_MEM        <= 'd0;
			pc_seq_MEM        <= 'd0;
			forward_DM_rdata_MEM <= 'd0;
		end else begin
			RtData_MEM        <= RtData_EXE;
			reg_waddr_MEM     <= reg_waddr_EXE;
			reg_wdata_sel_MEM <= reg_wdata_sel_EXE;		
			reg_write_MEM     <= reg_write_EXE;
			ALUout_MEM        <= ALUout_EXE;
			DM_WEN_MEM        <= DM_WEN_EXE;
			pc_seq_MEM        <= pc_seq_EXE;
			forward_DM_rdata_MEM <= forward_DM_rdata_EXE;
		end
	end
	// pipeline stage MEM->WB
	always @(posedge CLK)begin
		if(RST)begin
			reg_waddr_WB     <= 'd0;
			reg_wdata_sel_WB <= 'd0;
			reg_write_WB     <= 'd0;
			ALUout_WB        <= 'd0;
			DM_rdata_WB      <= 'd0;
			pc_seq_WB        <= 'd0;
		end else begin
			reg_waddr_WB     <= reg_waddr_MEM;
			reg_wdata_sel_WB <= reg_wdata_sel_MEM;
			reg_write_WB     <= reg_write_MEM;
			ALUout_WB        <= ALUout_MEM;
			DM_rdata_WB      <= DM_rdata_MEM;
			pc_seq_WB       <= pc_seq_MEM;
		end
	end
endmodule




