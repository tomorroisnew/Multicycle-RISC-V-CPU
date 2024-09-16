riscv32-unknown-elf-as -march=rv32i -o startup.o startup.s
riscv32-unknown-elf-gcc -O0 -march=rv32i -mabi=ilp32 -mstrict-align -nostartfiles -nostdlib -T test.ld -save-temps -o test.elf startup.o test.c
riscv32-unknown-elf-objcopy -O binary test.elf test.bin

xxd -p -c 4 test.bin > test.hex

cut -c1-2 test.hex > bram_data/firstbyte.txt  # Least significant byte (LSB)
cut -c3-4 test.hex > bram_data/secondbyte.txt
cut -c5-6 test.hex > bram_data/thirdbyte.txt
cut -c7-8 test.hex > bram_data/fourthbyte.txt # Most significant byte (MSB)