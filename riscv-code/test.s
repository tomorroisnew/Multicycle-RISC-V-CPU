    .globl _start

_start:
    # Initialize the stack pointer
    lui x2, 0x1                     # Load upper immediate for stack pointer
    addi x2, x2, -2048              # Adjust stack pointer to 0x800 (1 << 12 - 2048)

    jal main                        # Jump to main function
    nop                             # No-op (optional)
1:  j 1b

delay:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      zero,-20(s0)
        j       .L2
.L3:
        nop
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        lw      a5,-36(s0)
        blt     a4,a5,.L3
        nop
        nop
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
.L5:
        li      a5,-16
        sw      zero,0(a5)
        li      a0,1
        call    delay
        li      a5,-16
        li      a4,-1
        sw      a4,0(a5)
        li      a0,1
        call    delay
        j       .L5