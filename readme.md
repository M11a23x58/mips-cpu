# MIPS CPU

## Description
For self-learning Computer Orgnization,
build verification environment and implemnet a CPU.
* 5 stage pipelined MIPS CPU
* Support forwarding and stall
* Branch at ID stage

## Requirement
* Icarus Verilog
* python
* SPIM (QtSPIM)


## How to use
0. Install the project.
0. `cd mips`
1. Write MIPS assembly code `mips.s`.
2. Start SPIM and load `mips.s`
3. Save log file as `before.txt`to `./tb/resourse/code`.
	Remember choose both `Data segment` and `Text segment`.
4. Run SPIM and save log file as `after.txt` to `./tb/resourse/code`.
	Remember choose both `Data segment` and `Text segment`.
5. Run `make gol` to generate test data.
6. Run `make single`, `make p`to run simulation.
7. Wave file is dumped to `./build/cpu.vcd`.

## Makefile
`make gol`: Generate test data.
`make single`: Run single cycle cpu simulation.
`make p`: Run pipeline cpu simulation.

## Note
* Enable delay branch while using SPIM, inserting nop after every branch or jump instruction.
* Use `syscall` to end program.
* The data memory size is 4KB, the `tb_cpu` only check 0x000~0x3fc since others were viewed as stack. If stack pointer reach 0x3fc, simulation will stop and show "Stack overflow!".
* Use `addu`, `addiu`, `subu`. instead of `add`, `addi`,`sub` since the cpu does not support overflow detection. All instructions supported can be found in `0.define.v`.
* There minght be some bugs in `translate.py` for generating test data due to unexpectable format of `before.txt`, `after.txt`, to avoid bugs, default data segment to non-zero could be helpful. i.e. `.word 1`

## Handle RAW Hazard
* R-type / R-type
* R-type / beq, bne, jal, jalr
* R-type / sw
* lw (stall)
