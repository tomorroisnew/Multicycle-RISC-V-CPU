.section .text
.global _start

_start:
    # Initialize the stack pointer to the top of your available memory
    la sp, _stack_top     # Load the address of the top of the stack into sp

    # Step 1: Initialize mstatus with a known value
    li t0, 0xFFFFFFFF       # Load initial value (e.g., setting bit 1) into t0
    csrrw x0, mstatus, t0   # Write the initial value to mstatus

    # Step 2: Set the MIE bit (bit 3) in mstatus using CSRRS
    li t0, 0x8              # Load bitmask for MIE (bit 3) into t0
    csrrc t2, mstatus, t0   # Set the MIE bit in mstatus using CSRRS
                            # t2 holds the original value of mstatus before modification

    # Step 3: Restore the original value using CSRRW
    csrrw x0, mstatus, t2   # Restore the original value of mstatus from t2
                            # Writing t2 to mstatus

    # Infinite loop after main (in case main returns)
1:  j 1b

# Declare the top of the stack
.section .bss
.globl _stack_top
_stack_top = 0x00000600   # Set this to the top of your available memory
