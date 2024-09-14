rm tests/CPU_testbench
iverilog -g2012 tests/CPU_test.sv cpu/CPU.sv cpu/ControlUnit.sv cpu/ALU.sv soc/RAM.sv tests/cells_sim.v -o tests/CPU_testbench
./tests/CPU_testbench