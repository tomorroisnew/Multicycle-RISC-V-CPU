    .globl _start

_start:
    # Initialize the stack pointer
    lui x2, 0x1                     # Load upper immediate for stack pointer
    addi x2, x2, -2048              # Adjust stack pointer to 0x800 (1 << 12 - 2048)

    jal main                        # Jump to main function
    nop                             # No-op (optional)

main:
    # Stack frame setup
    addi            sp, sp, -16      # Create space on the stack
    sw              ra, 12(sp)       # Save return address
    sw              s0, 8(sp)        # Save s0 register

    li      a0, 0
        sw      a0, -12(s0)
        lui     a1, 699051
        addi    a1, a1, -1366
        sw      a1, 1280(zero)
        lui     a1, 12
        addi    a1, a1, -1093
        sh      a1, 1280(zero)
        li      a1, 204
        sb      a1, 1281(zero)
        lw      a1, 1280(zero)

    # Stack frame teardown and return
    lw              ra, 12(sp)       # Restore return address
    lw              s0, 8(sp)        # Restore s0 register
    addi            sp, sp, 16       # Free up stack space

    jalr x0, ra, 0                   # Return to caller
