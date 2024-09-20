	.file	"test.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	transmit_uart
	.type	transmit_uart, @function
transmit_uart:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	mv	a5,a0
	sb	a5,-17(s0)
	nop
.L2:
	li	a5,-9
	lbu	a5,0(a5)
	andi	a5,a5,0xff
	bne	a5,zero,.L2
	li	a5,-11
	lbu	a4,-17(s0)
	sb	a4,0(a5)
	li	a5,-12
	li	a4,-1
	sb	a4,0(a5)
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	transmit_uart, .-transmit_uart
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a0,72
	call	transmit_uart
	li	a0,101
	call	transmit_uart
	li	a0,108
	call	transmit_uart
	li	a0,108
	call	transmit_uart
	li	a0,111
	call	transmit_uart
	li	a0,32
	call	transmit_uart
	li	a0,87
	call	transmit_uart
	li	a0,111
	call	transmit_uart
	li	a0,114
	call	transmit_uart
	li	a0,108
	call	transmit_uart
	li	a0,100
	call	transmit_uart
	li	a0,10
	call	transmit_uart
	li	a5,0
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 13.2.0"
