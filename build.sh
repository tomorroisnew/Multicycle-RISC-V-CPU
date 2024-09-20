yosys -p "read_verilog -sv ./cpu/ALU.sv ./cpu/ControlUnit.sv ./cpu/CPU.sv ./soc/SOC.sv ./soc/UART_MMIO.sv ./soc/BRAM_MMIO.sv ./soc/GPIO_MMIO.sv; synth_ice40 -top SOC -json ./synthesis/soc.json"

nextpnr-ice40 --seed 1 --up5k --json ./synthesis/soc.json --pcf ./soc/SOC.pcf --asc ./synthesis/soc.asc

icepack ./synthesis/soc.asc ./synthesis/soc.bin

iceprog ./synthesis/soc.bin