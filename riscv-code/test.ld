MEMORY
{
  RAM (xrw)  : ORIGIN = 0x00000000, LENGTH = 0x0800  /* 2048 bytes of RAM */
  GPIO_MMIO  : ORIGIN = 0xFFFFFFF0, LENGTH = 0x0004 /* 4 bytes (32 bits) for GPIO MMIO */
}

SECTIONS
{
  . = 0x00000000;           /* Starting address of the program */
  .text : { *(.text*) }      /* Code section */
  .data : { *(.data*) }      /* Data section */
  .bss  : { *(.bss*) }       /* BSS section */

  /* Define the top of the RAM for stack pointer initialization */
  _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}