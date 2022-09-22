## assembly code & comment
## fibonacci.S
    .data
result:
    .word 0

    .text                          # code section 
    .globl fibonacci_asm           # declar the sum_asm function as a  global function
 
fibonacci_asm:
    # Write your assembly code funtion here.
    # Please notice the rules of calling convention.    
    # input n in a0, return value in a0
    li $a0, 10
    addiu $sp, $sp, -8   #移動stack
    sw $ra, 0($sp)       #將回傳地址存入stack
    jal fibonacci        #呼叫fibonacci
    nop
    lw $ra, 4($sp)       #fibonacci回傳後，將存在stack的ra取回
    lw $a0, 0($sp)       #將fibonacci存在stack中的答案取出，放入a0
    addiu $sp, $sp, 8    #回覆stack
    la $t0, result
    sw $a0, 0($t0)
    syscall
    jr $ra               #return
    nop
fibonacci:
    beq $a0, $zero, F0   #若n=0，轉移至F0
    nop
    li $t0, 1            #將t0設為1
    beq $a0, $t0, F1     #若n=1，轉移至F1
    nop 
    addiu $sp, $sp, -8   #將ra與n存入stack
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    addiu $a0, $a0, -1   #n=n-1
    jal fibonacci        #呼叫fibonacci，此時為F(n-1)
    nop
    addiu $a0, $a0, -1   #n=n-1
    jal fibonacci        #呼叫fibonacci，此時為F(n-2)
    nop
    lw $a1, 0($sp)       #將stack中存放的值取出，放入a1
    lw $a2, 4($sp)       #將stack中存放的值取出，放入a2
    lw $ra, 8($sp)       #取回ra
    lw $a0, 12($sp)      #取回n
    addu $a1, $a1, $a2   #a1 = a1 + a2
    addiu $sp, $sp, 12   #將stack歸位
    sw $a1, 0($sp)       #將a1存入stack
    jr $ra               #跳回ra所存的地址
    nop
F0:
    addiu $sp, $sp, -4   #將0推入stack後，跳回ra所存的地址
    li $t0, 0
    sw $t0, 0($sp)
    jr $ra
    nop
F1:
    addiu $sp, $sp, -4   #將1推入stack後，跳回ra所存的地址
    li $t0, 1
    sw $t0, 0($sp)
    jr $ra
    nop