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
	.globl	test
	.type	test, @function
test:
	addi	sp,sp,-16
	sw	s0,12(sp)
	addi	s0,sp,16
	li	a5,-16
	li	a4,-1
	sw	a4,0(a5)
	nop
	lw	s0,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	test, .-test
	.align	2
	.globl	delay
	.type	delay, @function
delay:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a5,-16
	li	a4,-286330880
	addi	a4,a4,-274
	sw	a4,0(a5)
	call	test
	li	a5,-16
	li	a4,-572661760
	addi	a4,a4,-547
	sw	a4,0(a5)
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	delay, .-delay
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a5,-16
	li	a4,-1431654400
	addi	a4,a4,-1366
	sw	a4,0(a5)
	call	test
	li	a5,-16
	li	a4,-1145323520
	addi	a4,a4,-1093
	sw	a4,0(a5)
	call	delay
	call	test
	li	a5,-16
	li	a4,-858992640
	addi	a4,a4,-820
	sw	a4,0(a5)
	call	delay
	li	a5,0
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 13.2.0"
