
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

	//Decode Inst.
	wire [ 5:0] opcode = IM_rdata[31:26];
	wire [ 4:0] Rs     = IM_rdata[25:21];
	wire [ 4:0] Rt     = IM_rdata[20:16];
	wire [ 4:0] Rd     = IM_rdata[15:11];
	wire [ 4:0] shamt  = IM_rdata[10: 6];
	wire [ 5:0] funct  = IM_rdata[ 5: 0];
	wire [15:0] Imm    = IM_rdata[15: 0];
	wire [25:0] target = IM_rdata[25: 0];
// Wiring
	// others
	wire [31:0] zImm = {16'b0, Imm};
	wire [31:0] sImm = {{16{Imm[15]}}, Imm};
	
	// PC
	wire                   pc_stall ;
	wire [`ADDR_WIDTH-1:0] npc      ;
	wire [`ADDR_WIDTH-1:0] pc_seq   ;
	wire [`ADDR_WIDTH-1:0] pc_branch;
	wire [`ADDR_WIDTH-1:0] pc_reg   ;
	wire [`ADDR_WIDTH-1:0] pc_jump  ;
	// RegFile
	wire [`DATA_WIDTH-1:0] RsData; 
	wire [`DATA_WIDTH-1:0] RtData;
	wire [            4:0] reg_waddr;
	wire [`DATA_WIDTH-1:0] reg_wdata;
	wire                   reg_write;	
	// ALU
	wire [`DATA_WIDTH-1:0] ALUSrc1;
	wire [`DATA_WIDTH-1:0] ALUSrc2;
	wire [`DATA_WIDTH-1:0] ALUout;
	wire [            4:0] ALUshamt;
	wire [            4:0] ALUop;

	assign pc_seq    = IM_addr + 4;
	assign pc_branch = pc_seq + (sImm << 2);
	assign pc_reg    = RsData;
	assign pc_jump   = {pc_seq[31:28], target << 2};

	assign npc = (`is_R && (`is_R_jr || `is_R_jalr))? pc_reg :
				 ((`is_beq && (ALUout == 0)) || (`is_bne && (ALUout != 0)))? pc_branch :
				 (`is_j || `is_jal)? pc_jump : pc_seq;

	assign pc_stall = (`is_sw || `is_lw)? (DM_stall)? DM_stall : IM_stall : IM_stall;

	assign reg_waddr = (`is_jal)? 'd31 : 
					   (`is_R)? Rd   : Rt;

	assign reg_write = ((`is_R & ~`is_R_jr)     ||
						 `is_addiu || `is_andi  ||
						 `is_ori   || `is_xori  ||
						 `is_lui   || `is_lw    ||
						 `is_slti  || `is_sltiu ||
						 `is_jal )? (pc_stall)? 0 : 1 : 0;  

	assign reg_wdata = (`is_jal || `is_R_jalr)? pc_seq+4 :
					   (`is_lw )? DM_rdata  : ALUout;

	assign ALUop = (`is_addiu  )? `alu_add :
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

	assign ALUSrc1 = RsData;
	assign ALUSrc2 = (`is_R || `is_beq || `is_bne)? RtData :
					 (`is_andi || `is_ori || `is_xori || `is_lui)? zImm :
					 (`is_addiu || `is_lw || `is_sw || `is_slti || `is_sltiu)? sImm : 'hx;
	assign ALUshamt = (`is_lui)? 'd16 : shamt;

	
	// Submodule				   
	PC pc(
	 .CLK( CLK ),
	 .RST( RST ),
	 .npc( npc ),
	 .pc( IM_addr ),
	 .stall( pc_stall )
	);

	Regfile
#(
	.stack_start(`STACK)
)
	regfile(
	.CLK( CLK ),
	.RST( RST ),
	// Read 
	.raddr1( Rs ), 
	.raddr2( Rt ),
	.rdata1( RsData ), 
	.rdata2( RtData ),
	// Write
	.waddr( reg_waddr ),
	.wdata( reg_wdata ),
	.WEN  ( reg_write )
	);

	ALU alu(
	.src1( ALUSrc1 ),
	.src2( ALUSrc2 ),
	.ALUop( ALUop ),
	.shamt( ALUshamt ),
	.ALUout( ALUout )
	);
	// Interface
	assign DM_addr = ALUout;
	assign DM_wdata = RtData;
	assign DM_WEN = (`is_sw & ~IM_stall)? 1 : 0;
	assign finish = `is_syscall? 1 : 0;
endmodule




