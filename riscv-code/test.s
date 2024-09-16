    .section .text
    .globl _start

_start:
    #la sp, 0x800
    lui x2, 1
    addi x2, x2, -2048
    jal main
    nop
main:
    addi            sp, sp, -16
    sw              ra, 12(sp)
    sw              s0, 8(sp)
    addi            s0, sp, 16
    nop
    lw              ra, 12(sp)
    lw              s0, 8(sp)
    addi            sp, sp, 16
    # return
    jalr x0, ra, 0