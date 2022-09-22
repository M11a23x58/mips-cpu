.data
Rtest:
	.word 0 # addu
	.word 0 # subu
	.word 0 # sll
	.word 0 # srl
	.word 0 # sra
	.word 0 # and
	.word 0 # or
	.word 0 # xor
	.word 0 # slt
	.word 0 # sltu
Itest:
	.word 0 #addiu +
	.word 0 #addiu -
	.word 0 #andi
	.word 0 #xori
	.word 0 #slti
	.word 0 #sltiu
Jtest:
	.word 0
ForwardTest:
	.word 0
	.word 0
	.word 0
fx:
	.word 0
.text
.globl main

main:	jal R_TEST
		nop
		jal I_TEST
		nop
		jal B_TEST
		nop
		jal J_TEST
		nop
		jal J_PASS
		nop
		jal Forward_Test
		nop
		j FAIL
		nop
		syscall


R_TEST:	la $t0, Rtest
		li $t1, 0xffffffff
		li $t2, 0x520c8763
		addu $t3, $t1, $t2
		sw $t3, 0($t0)
		subu $t3, $t1, $t2
		sw $t3, 4($t0)
		sll $t3, $t1, 5
		sw $t3, 8($t0)
		srl $t3, $t1, 5
		sw $t3, 12($t0)
		sra $t3, $t1, 5
		sw $t3, 16($t0)
		and $t3, $t1, $t2
		sw $t3, 20($t0)
		or $t3, $t1, $t2
		sw $t3, 24($t0)
		xor $t3, $t1, $t2
		sw $t3, 28($t0)
		nor $t3, $t1, $t2
		sw $t3, 32($t0)
		slt $t3, $t1, $t2
		sw $t3, 36($t0)
		sltu $t3, $t1, $t2
		sw $t3, 40($t0)
		j R_PASS
		nop
I_TEST: la $t0, Itest
		lw $t1, 0($t0)
		lw $t2, 0($t0)
		addiu $t3, $t1, 40
		sw $t3, 0($t0)
		addiu $t3, $t1, -40
		sw $t3, 4($t0)
		andi $t3, $t1, 0x0f0f
		sw $t3, 8($t0)
		xori $t3, $t1, 0x0f0f
		sw $t3, 12($t0)
		slti $t3, $t1, -1
		sw $t3, 16($t0)
		sltiu $t3, $t1, -1
		sw $t3, 20($t0)
		j I_PASS
		nop
B_TEST: li $t1, 0
		li $t2, 9
LOOP:	addiu $t1, $t1, 1
		bne $t1, $t2, LOOP
		nop
		beq $t1, $t2, B_PASS
		nop
J_TEST: j JALR_TEST
		nop
		la $t0, Jtest
		li $t1, 0x8787
		sw $t1, 0($t0)
JALR_TEST: 
		jalr $t0, $ra
		nop
R_PASS:	jr $ra
		nop
I_PASS: jr $ra
		nop
B_PASS: jr $ra
		nop
J_PASS: la $t1, Jtest
		sw $t0, 0($t1)
		jr $ra
		nop

Forward_Test: li $t0, 5
		la $a0, ForwardTest
		addiu $t0, $t0, 5
		addiu $t0, $t0, 4
		addiu $t0, $t0, 3
		sw $t0, 0($a0)
		addiu $a0, 4
		sw $t0, 0($a0)
		lw $t0, 0($a0)
		sw $t0, 4($a0)
		li $t1, 5
		li $t2, 4
		addiu $t2, 1
		bne $t1, $t2, FAIL2
		nop
		addiu $ra, 8
		jr $ra
		nop

FAIL:	la $t0, fx
		li $t1, 0x87878787
		sw $t1, 0($t0)
		syscall
FAIL2:	la $t0, fx
		li $t1, 0x69696969
		sw $t1, 0($t0)
		syscall