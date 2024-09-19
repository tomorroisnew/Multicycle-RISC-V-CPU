	.file	"test.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	delay
	.type	delay, @function
delay:
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
	.size	delay, .-delay
	.align	2
	.globl	gitna
	.type	gitna, @function
gitna:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a5,-16
	lw	a4,0(a5)
	li	a5,-16
	addi	a4,a4,1
	sw	a4,0(a5)
	li	a5,-16
	li	a4,-286330880
	addi	a4,a4,-274
	sw	a4,0(a5)
	call	delay
	li	a5,-16
	li	a4,-555819008
	addi	a4,a4,-290
	sw	a4,0(a5)
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	gitna, .-gitna
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
.L4:
	li	a5,-16
	li	a4,-572661760
	addi	a4,a4,-547
	sw	a4,0(a5)
	call	gitna
	li	a5,-16
	li	a4,-1431654400
	addi	a4,a4,-1366
	sw	a4,0(a5)
	call	delay
	li	a5,-16
	li	a4,1431654400
	addi	a4,a4,1365
	sw	a4,0(a5)
	call	gitna
	j	.L4
	.size	main, .-main
	.ident	"GCC: () 13.2.0"
