
`define DATA_WIDTH 32 // CPU
`define ADDR_WIDTH 32 // CPU
`define CYCLE 10
`define END_CYCLE 600000
`define STACK 'hfff
`define DRAM_DATA_WIDTH 32
`define DRAM_ADDR_WIDTH 12
`define IM_FILE "./tb/resourse/data/IM.dat"
`define DM_FILE "./tb/resourse/data/DM.dat"
`define golden_FILE "./tb/resourse/data/golden.dat"
`define WAVE_FILE "./build/cpu.vcd"
`define STACK_OVERFLOW 'h400 //When will the stack reach data segment
// Op map
`define is_R     (opcode == 'h0 )
`define is_addiu (opcode == 'h9 ) 
`define is_andi  (opcode == 'hc ) 
`define is_ori   (opcode == 'hd ) 
`define is_xori  (opcode == 'he ) 
`define is_lui   (opcode == 'hf ) 
`define is_lw    (opcode == 'h23)
`define is_sw    (opcode == 'h2b)
`define is_beq   (opcode == 'h4 ) 
`define is_bne   (opcode == 'h5 ) 
`define is_slti  (opcode == 'ha )
`define is_sltiu (opcode == 'hb ) 
`define is_jal   (opcode == 'h3 ) 
`define is_j     (opcode == 'h2 )

// R-Format 
`define is_R_sll  (`is_R && ( funct == 'd0  ))
`define is_R_srl  (`is_R && ( funct == 'd2  ))
`define is_R_sra  (`is_R && ( funct == 'd3  ))
`define is_R_jr   (`is_R && ( funct == 'd8  ))
`define is_R_jalr (`is_R && ( funct == 'd9  ))
`define is_R_addu (`is_R && ( funct == 'd33 ))
`define is_R_subu (`is_R && ( funct == 'd35 ))
`define is_R_and  (`is_R && ( funct == 'd36 ))
`define is_R_or   (`is_R && ( funct == 'd37 ))
`define is_R_xor  (`is_R && ( funct == 'd38 ))
`define is_R_nor  (`is_R && ( funct == 'd39 ))
`define is_R_slt  (`is_R && ( funct == 'd42 ))
`define is_R_sltu (`is_R && ( funct == 'd43 ))

`define is_syscall (`is_R && ( funct == 'd12 ))

// Alu operation
`define alu_add 'd0
`define alu_sub 'd1
`define alu_and 'd2
`define alu_or  'd3
`define alu_xor 'd4
`define alu_nor 'd5
`define alu_sll 'd6
`define alu_srl 'd7
`define alu_sra 'd8
`define alu_slt 'd9
`define alu_sltu 'd10


// Include File
`include "../single cycle/simple_mem.v"
`include "../single cycle/1.Core.v"
`include "../single cycle/2.Pc.v"
`include "../single cycle/3.Regfile.v"
`include "../single cycle/4.Alu.v"
