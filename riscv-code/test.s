    .globl _start

_start:
    # Initialize the stack pointer
    lui x2, 0x1                     # Load upper immediate for stack pointer
    addi x2, x2, -2048              # Adjust stack pointer to 0x800 (1 << 12 - 2048)

    jal main                        # Jump to main function
    nop                             # No-op (optional)
1:  j 1b

transmit(char):
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sb      a0, -9(s0)
        j       .LBB0_1
.LBB0_1:
        lbu     a0, -9(zero)
        beqz    a0, .LBB0_3
        j       .LBB0_2
.LBB0_2:
        j       .LBB0_1
.LBB0_3:
        lbu     a0, -9(s0)
        sb      a0, -11(zero)
        li      a0, 255
        sb      a0, -12(zero)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -16(s0)
        sw      a0, -12(s0)
        li      a0, 65
        call    transmit(char)
        lw      a0, -16(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret