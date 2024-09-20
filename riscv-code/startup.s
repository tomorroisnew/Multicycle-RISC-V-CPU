.section .text
.global _start

_start:
    # Initialize the stack pointer to the top of your available memory
    la sp, _stack_top     # Load the address of the top of the stack into sp

    # Call the main function
    call main

    # Infinite loop after main (in case main returns)
1:  j 1b

# Declare the top of the stack
.section .bss
.globl _stack_top
_stack_top = 0x00000800   # Set this to the top of your available memory
