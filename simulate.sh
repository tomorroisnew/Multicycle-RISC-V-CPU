rm tests/CPU_testbench
iverilog -g2012 tests/CPU_test.sv cpu/CPU.sv cpu/ControlUnit.sv cpu/ALU.sv -o tests/CPU_testbench
./tests/CPU_testbench