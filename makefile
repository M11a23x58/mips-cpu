single:
	mkdir -p ./build
	iverilog -I "./tb" -I "./single cycle" -DVCD -DREGVALUE -DSINGLE -DIV -o ./build/cpu ./tb/tb_cpu.v
	vvp ./build/cpu
p:
	mkdir -p ./build
	iverilog -I "./tb" -I "./pipe" -DVCD -DREGVALUE -DPIPE -DIV -o ./build/cpu ./tb/tb_cpu.v
	vvp ./build/cpu
gol:
	python translate.py "./tb/resourse/code/before.txt" before && python translate.py "./tb/resourse/code/after.txt" after
	