# Multicycle-RISC-V-CPU

## Description

This project implements a multi-cycle CPU based on the RISC-V instruction set architecture (ISA). The RISC-V ISA is a free and open ISA enabling a new era of processor innovation through open standard collaboration. The multi-cycle CPU design allows for each instruction to be broken down into multiple stages, with each stage taking one clock cycle to complete. This approach can lead to more efficient use of hardware resources compared to single-cycle designs.

The current project supports rv32i instruction sets.

## Folder Structure

The project directory is organized as follows:

```
/z:/design/risc-v-multi-cycle-cpu/
├── cpu/                # Main cpu implementation
├── riscv-code/         # Code for generating files to be initialized in the ram
├── soc/                # SOC utilizing the cpu, with additional gpio module
├── synthesis           # Output folder of the synthesis tools
└── tests/              # Test suites
```

## Memory Mapping

The current SOC has two memory devices: a RAM and a GPIO device that handles all the generic GPIO.

| Address Range             | Device       | Description                  |
|---------------------------|--------------|------------------------------|
| 0x0000_0000 - 0x0000_01FF | BRAM         | On-chip Block RAM            |
| 0x0000_0200 - 0xFFFF_FFEF | Unused       | Unused memory space          |
| 0xFFFF_FFF0 - 0xFFFF_FFF3 | GPIO         | General Purpose I/O          |
| 0xFFFF_FFF4 - 0xFFFF_FFFF | Unused       | Unused memory space          |

## Control Unit State Machine

The control unit of the multi-cycle CPU is implemented as a finite state machine (FSM). The FSM controls the sequence of operations for each instruction by transitioning through a series of states. Each state corresponds to a specific stage in the instruction execution process.

### States

The state machine includes the following states:

- **FETCH**: Fetch the instruction from memory.
- **MEMORY_FETCH_WAIT**: Wait for the memory fetch operation to complete.
- **DECODER_WAIT**: Add a delay for fetching the registers.
- **DECODE**: Decode the fetched instruction and determine the next state based on the opcode.
- **RTYPE_EXECUTION**: Execute R-type instructions.
- **ALU_WRITEBACK**: Write the result of ALU operations back to the register file.
- **JAL_EXECUTION**: Execute the first part of JAL (Jump and Link) instructions.
- **JAL_EXECUTION2**: Execute the second part of JAL instructions.
- **JALR_EXECUTION**: Execute the first part of JALR (Jump and Link Register) instructions.
- **JALR_EXECUTION2**: Execute the second part of JALR instructions.
- **BRANCH_COMPLETION**: Complete branch instructions based on the condition.
- **MEMORY_ADDRESS_COMPUTATION**: Compute the memory address for load/store instructions.
- **LW_MEMORY_ACCESS**: Access memory for load word (LW) instructions.
- **MEMORY_LW_WAIT**: Wait for the load word (LW) memory operation to complete.
- **LW_WRITEBACK**: Write the loaded word back to the register file.
- **SW_MEMORY_ACCESS**: Access memory for store word (SW) instructions.
- **IMMEDIATE_EXECUTION**: Execute immediate-type instructions.
- **LUI_WRITEBACK**: Write the result of LUI (Load Upper Immediate) instructions to the register file.
- **AUIPC_EXECUTE**: Execute AUIPC (Add Upper Immediate to PC) instructions.

### Control Signals

The control unit generates various control signals to manage the operations of the datapath components. These signals include:

- **PCEnable**: Enables updating the Program Counter.
- **InstructionRegisterEnable**: Enables updating the Instruction Register.
- **InstructionOrData**: Selects between instruction and data memory access.
- **ImmediateSrc**: Selects the type of immediate value to be used.
- **REGAEnable**: Enables updating Register A.
- **REGBEnable**: Enables updating Register B.
- **ALUSrcA**: Selects the source for the ALU's first operand.
- **ALUSrcB**: Selects the source for the ALU's second operand.
- **ResultSrc**: Selects the source of the result to be written back to the register file.
- **MemWrite**: Enables writing data to memory.
- **RegWrite**: Enables writing data to the register file.
- **ALUOp**: Specifies the operation to be performed by the ALU.

## ALU (Arithmetic Logic Unit)

The ALU is a critical component of the CPU responsible for performing arithmetic and logical operations. In this design, the ALU supports a variety of operations determined by the `ALUControlSignal`.

### Operations

The ALU can perform the following operations based on the 4-bit `ALUControlSignal`:

- **Addition (0000)**: Adds `ALUA` and `ALUB`.
- **Subtraction (0001)**: Subtracts `ALUB` from `ALUA`.
- **Bitwise AND (0010)**: Performs a bitwise AND between `ALUA` and `ALUB`.
- **Bitwise OR (0011)**: Performs a bitwise OR between `ALUA` and `ALUB`.
- **Bitwise XOR (0100)**: Performs a bitwise XOR between `ALUA` and `ALUB`.
- **Logical Shift Left (0101)**: Shifts `ALUA` left by the number of positions specified by `ALUB`.
- **Logical Shift Right (0110)**: Shifts `ALUA` right by the number of positions specified by `ALUB`.
- **Arithmetic Shift Right (0111)**: Shifts `ALUA` right arithmetically by the number of positions specified by `ALUB`.
- **Set Less Than Unsigned (1000)**: Sets the result to 1 if `ALUA` is less than `ALUB` (unsigned comparison), otherwise sets it to 0.
- **Set Greater Than or Equal Unsigned (1001)**: Sets the result to 1 if `ALUA` is greater than or equal to `ALUB` (unsigned comparison), otherwise sets it to 0.
- **Shift Left Immediate (1010)**: Shifts `ALUA` left by the immediate value extracted from `ALUB`.
- **Shift Right Immediate (1011)**: Shifts `ALUA` right by the immediate value extracted from `ALUB`.
- **Arithmetic Shift Right Immediate (1100)**: Shifts `ALUA` right arithmetically by the immediate value extracted from `ALUB`.
- **Set Less Than Signed (1101)**: Sets the result to 1 if `ALUA` is less than `ALUB` (signed comparison), otherwise sets it to 0.
- **Set Greater Than or Equal Signed (1110)**: Sets the result to 1 if `ALUA` is greater than or equal to `ALUB` (signed comparison), otherwise sets it to 0.

### Zero Flag

The ALU also generates a `Zero` flag, which is set to 1 if the result of the operation is zero. This flag is often used in conditional branch instructions to determine the next state.

### Immediate Values

For certain operations, the ALU uses a 5-bit immediate value extracted from `ALUB`. This is particularly useful for shift operations where the shift amount is specified as an immediate value.

By leveraging these operations, the ALU plays a pivotal role in executing instructions and performing computations within the CPU.

## Credits

This project uses code from the Yosys Open SYnthesis Suite. Yosys is an open-source framework for Verilog RTL synthesis. The code included in `cells_sim.v` is derived from Yosys to facilitate simulation and synthesis processes.

## TODO
- Implement PLIC (Platform-Level Interrupt Controller)
    - Add PLIC gateway module for each type of signal:
        - Level sensitive
        - Edge sensitive
- Add the ISA M extension (Multiplication and Division)
- Implement CSRs (Control and Status Registers)
- Add the ISA A extension (Atomic Instructions)
- Implement VGA I/O
- Implement QSPI for the flash memory