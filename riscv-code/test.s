    .globl _start

_start:
    # Initialize the stack pointer
    lui x2, 0x1                     # Load upper immediate for stack pointer
    addi x2, x2, -2048              # Adjust stack pointer to 0x800 (1 << 12 - 2048)

    jal main                        # Jump to main function
    nop                             # No-op (optional)
1:  j 1b

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -12(s0)
        li      a1, 65
        sb      a1, -11(zero)
        li      a1, 255
        sb      a1, -12(zero)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret