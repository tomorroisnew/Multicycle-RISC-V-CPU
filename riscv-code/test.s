    .globl _start

_start:
    # Initialize the stack pointer
    lui x2, 0x1                     # Load upper immediate for stack pointer
    addi x2, x2, -2048              # Adjust stack pointer to 0x800 (1 << 12 - 2048)

    jal main                        # Jump to main function
    nop                             # No-op (optional)

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -12(s0)
        lw      a0, -16(zero)
        bnez    a0, .LBB0_2
        j       .LBB0_1
.LBB0_1:
        li      a0, -1
        sw      a0, -16(zero)
        j       .LBB0_3
.LBB0_2:
        li      a0, 0
        sw      a0, -16(zero)
        j       .LBB0_3
.LBB0_3:
        li      a0, 0
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret