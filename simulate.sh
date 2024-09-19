export PATH="$PATH:/mnt/storage/nas/design/riscvtoolchain/bin"
cd riscv-code
./generate_files.sh
cd ../
iverilog -g2012 tests/SOC_test.sv cpu/CPU.sv soc/BRAM_MMIO.sv cpu/ControlUnit.sv cpu/ALU.sv soc/GPIO_MMIO.sv -o tests/a.out soc/SOC.sv tests/cells_sim.v
./tests/a.out