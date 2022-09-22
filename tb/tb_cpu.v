`timescale 1ns/1ns
`ifdef SINGLE
`include "../single cycle/0.define.v"
`endif
`ifdef PIPE
`include "../pipe/0.define.v"
`endif
module tb_cpu;
//================
//  dumpfiles
//================
`ifdef VCD
initial begin
	$dumpfile(`WAVE_FILE);
	$dumpvars(0, tb_cpu);
end
`endif

reg CLK, RST;
//================
//  CLK
//================
initial CLK = 0;
always #(`CYCLE/2) CLK=~CLK;
//================
//  RST
//================
initial RST = 1;
initial #20 RST = 0;
//================
//  sunmodule
//================
wire [31:0] inst;
wire [31:0] pc;
wire [31:0] dm_wdata, dm_addr, dm_rdata;
Core C0(
	.CLK( CLK ),
	.RST( RST ),
	// IM Interface
	.IM_addr( pc ), // PC
	.IM_rdata( inst ), // Inst.
	.IM_WEN(  ),
	.IM_stall( 1'b0 ),
	// DM Interface
	.DM_addr( dm_addr ),
	.DM_rdata( dm_rdata ),
	.DM_wdata( dm_wdata ),
	.DM_WEN( DM_WEN ),
	.DM_stall( 1'b0 ),
	.finish( finish ) // for end of program
	);

dram
#(
	.DATA_WIDTH(`DRAM_DATA_WIDTH),
	.ADDR_WIDTH(`DRAM_ADDR_WIDTH),
	.MEMORY_FILE(`IM_FILE)
)IM(
	.CLK( CLK ),
	.RST( RST ),
	.WEN( 1'b0 ),
	.wwide( 3'd4 ),
	.addr( pc[`DRAM_ADDR_WIDTH-1:0] ),
	.wdata(  ),
	.rdata( inst )
	//.stall( IM_resp )
	);
dram
#(
	.DATA_WIDTH(`DRAM_DATA_WIDTH),
	.ADDR_WIDTH(`DRAM_ADDR_WIDTH),
	.MEMORY_FILE(`DM_FILE)
)DM(
	.CLK( CLK ),
	.RST( RST ),
	.WEN( DM_WEN ),
	.wwide( 3'd4 ),
	.addr( dm_addr[`DRAM_ADDR_WIDTH-1:0] ),
	.wdata( dm_wdata ),
	.rdata( dm_rdata )
	//.stall( DM_resp )
	);

`ifdef REGVALUE
generate
  genvar x;
  for(x = 0; x < 32; x = x+1) begin: register
    wire [31:0] tmp;
    assign tmp = C0.regfile.RegisterFile[x];
  end
endgenerate
`endif


integer cycles;
always @(posedge CLK)begin
	if(RST) cycles <= 0;
	else cycles <= cycles + 1;
end

reg [7:0] golden [0:1023];
reg [3:0]err;
initial err = 0;
initial $readmemh(`golden_FILE, golden);
integer idx;
always @(posedge CLK) begin
	if(finish) begin
		for(idx=0; idx<1024; idx=idx+1)begin
			if (golden[idx] !== DM.mem[idx])begin
				$display("mem[%h] should be %2h, your ans is %2h, ", idx, golden[idx], DM.mem[idx]);
				if(err < 15) err = err + 1;
				else begin
					$display("Too much err");
					display_fail;
					$finish;
				end
			end
		end

		if(err === 0) display_pass;
		else display_fail;

		#20 $display("Total cycles = %d", cycles);
		$finish;
	end
end
// Terminate when unstopable
initial begin
	#(`END_CYCLE*`CYCLE) $display("Dead loop...? Can't stop!");
	$finish;
end
// Stack Overflow
always @(posedge CLK)begin
	if(C0.regfile.RegisterFile[29] < `STACK_OVERFLOW)begin
		$display("Stack overflow!");
		$finish;
	end 
end


task display_pass; begin
        $display("\n");
        $display("\n");
        $display("        ----------------------------               ");
        $display("        --                        --       |\__||  ");
        $display("        --  Congratulations !!    --      / O.O  | ");
        $display("        --                        --    /_____   | ");
        $display("        --  \033[0;32mSimulation PASS!!\033[m     --   /^ ^ ^ \\  |");
        $display("        --                        --  |^ ^ ^ ^ |w| ");
        $display("        ----------------------------   \\m___m__|_|");
        $display("\n");
end endtask

task display_fail; begin
        $display("\n");
        $display("\n");
        $display("        ----------------------------               ");
        $display("        --                        --       |\__||  ");
        $display("        --  OOPS!!                --      / X,X  | ");
        $display("        --                        --    /_____   | ");
        $display("        --  \033[0;31mSimulation Failed!!\033[m   --   /^ ^ ^ \\  |");
        $display("        --                        --  |^ ^ ^ ^ |w| ");
        $display("        ----------------------------   \\m___m__|_|");
        $display("\n");
end endtask
endmodule