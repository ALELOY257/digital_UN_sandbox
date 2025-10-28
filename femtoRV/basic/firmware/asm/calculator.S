.section .text
.globl start 
.globl blinker
.globl put_hello

calculator:
   li   sp,0x1000

loopM:	
	la   a0, command
	call putstring
	call get_number
	call bcd2bin
	call sqrt
	call bin2bcd

	call get_number
	call bcd2bin
	call sqrt
	call bin2bcd





	call get_number
	call bcd2bin
	call sqrt
	call bin2bcd






	j    loopM



	mv   t0, a0

	call get_number
	call bcd2bin
	mv   t1, a0

    mv   a0, t0
	mv   a1, t1
    call mult_hw
	call bin2bcd

	j    loopM



putstring:
	addi sp,sp,-4 # save ra on the stack
	sw ra,0(sp)   # (need to do that for functions that call functions)
	mv t2,a0	
.L1:    lbu a0,0(t2)
	beqz a0,.L2
	call putchar
	addi t2,t2,1	
	j .L1
.L2:    lw ra,0(sp)  # restore ra
	addi sp,sp,4 # restore sp
	ret	

.section .data
command:
	.asciz "\n\r - Enter calc: - "
operator:
	.asciz "\n\rEnter operator \n\r"
result:
	.asciz "\n\rResult = "

