.section .text
.globl start 
.globl blinker
.globl put_hello

calculator:

loopM:	
   li   sp,0x2000
   li   sp,0x2000

	la   a0, command
	call putstring
	call get_number
	call bcd2bin


	call sqrt
	call bin2bcd
	j    loopM

.section .data
command:
	.asciz "\n\r - Calc: - "
operator:
	.asciz "\n\rEnter operator \n\r"
result:
	.asciz "\n\rResult = "
