module ControlUnit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic Zero,
    input logic clk, reset,
    // Fetch
    output logic PCEnable, InstructionRegisterEnable, InstructionOrData, OLDPCEnable,
    // Decode 
    output logic [2:0] ImmediateSrc,
    output logic REGAEnable, REGBEnable,
    // Execute
    output logic [1:0] ALUSrcA, ALUSrcB, 
    output logic [3:0] ALUControlSignal,
    // Memory
    output logic [1:0] ResultSrc,
    output logic MemWrite,
    // WriteBack
    output logic RegWrite
);
    // ALUOp Wire. For the ALUControl 
    logic [1:0] ALUOp;
    // Connect the ALUControl Unit. Generates the ALUControlSignal
    ALUControl ALUControlUnit (
        .funct7(funct7),
        .funct3(funct3),
        .ALUOp(ALUOp),
        .ALUControlSignal(ALUControlSignal)
    );

    // State machine. Control all the signals and ALUOp base on state. Implement all needed states.
    typedef enum logic [4:0] {
        FETCH = 5'b00000,
        DECODE = 5'b00001,
        // RTYPE Flow
        RTYPE_EXECUTION = 5'b00010,
        ALU_WRITEBACK = 5'b00011,
        // JAL/JARL
        JAL_EXECUTION = 5'b00100,
        JALR_EXECUTION = 5'b01011, // Added late so order is not correct
        JALR_EXECUTION2 = 5'b01100, // Added late so order is not correct
        // BEQ Flow
        BRANCH_COMPLETION = 5'b00101,
        // LW/SW Flow
        MEMORY_ADDRESS_COMPUTATION = 5'b00110,
        LW_MEMORY_ACCESS = 5'b00111,
        LW_WRITEBACK = 5'b01000,
        SW_MEMORY_ACCESS = 5'b01001,
        // Immediate Flow
        IMMEDIATE_EXECUTION = 5'b01010,
        // LUI
        LUI_WRITEBACK = 5'b01101,
        // AUIPC
        AUIPC_EXECUTE = 5'b01110,
        // Apparantely, memory read is sequential, so i need a state just to read from memory
        MEMORY_FETCH_WAIT = 5'b01111,
        // SW/LW
        MEMORY_LW_WAIT = 5'b10000
    } state_t;

    state_t current_state, next_state;

    // Update State Registers
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Next State Logic
    always_comb begin
        case (current_state)
            FETCH:                          next_state = MEMORY_FETCH_WAIT;
            MEMORY_FETCH_WAIT:                next_state = DECODE; // For simulation
            //MEMORY_WAIT:                    next_state = (opcode == 7'b0000011) ? LW_WRITEBACK : DECODE; // For synthesizing
            DECODE: begin
                case (opcode)
                    7'b0110011:             next_state = RTYPE_EXECUTION;
                    7'b1101111:             next_state = JAL_EXECUTION;
                    7'b1100111:             next_state = JALR_EXECUTION;
                    7'b1100011:             next_state = BRANCH_COMPLETION;
                    7'b0000011:             next_state = MEMORY_ADDRESS_COMPUTATION;
                    7'b0100011:             next_state = MEMORY_ADDRESS_COMPUTATION;
                    7'b0010011:             next_state = IMMEDIATE_EXECUTION;
                    7'b0110111:             next_state = LUI_WRITEBACK;
                    7'b0010111:             next_state = AUIPC_EXECUTE;	
                    default:                next_state = FETCH;
                endcase
            end
            // R-Type 
            RTYPE_EXECUTION:                next_state = ALU_WRITEBACK;
            ALU_WRITEBACK:                  next_state = FETCH;
            // JAL/JALR Flow
            JAL_EXECUTION:                next_state = ALU_WRITEBACK;
            JALR_EXECUTION:                next_state = JALR_EXECUTION2;
            JALR_EXECUTION2:                next_state = ALU_WRITEBACK;
            // BEQ Flow
            BRANCH_COMPLETION:              next_state = FETCH;
            // LW/SW Flow
            MEMORY_ADDRESS_COMPUTATION: begin
                case (opcode)
                    7'b0000011:             next_state = LW_MEMORY_ACCESS;
                    7'b0100011:             next_state = SW_MEMORY_ACCESS;
                    default:                next_state = FETCH;
                endcase
            end
            LW_MEMORY_ACCESS:               next_state = MEMORY_LW_WAIT;
            MEMORY_LW_WAIT:                next_state = LW_WRITEBACK;
            LW_WRITEBACK:                   next_state = FETCH;
            SW_MEMORY_ACCESS:               next_state = FETCH;
            // Immediate Flow
            IMMEDIATE_EXECUTION:            next_state = ALU_WRITEBACK;
            // LUI
            LUI_WRITEBACK:                  next_state = FETCH;
            // AUIPC
            AUIPC_EXECUTE:                  next_state = ALU_WRITEBACK;
            default:    next_state = FETCH;
        endcase
    end

    // Signals Logic
    always_comb begin
        // Default Value
        PCEnable = 1'b0;                    // Update PC
        InstructionRegisterEnable = 1'b0;   // Update Instruction Register
        InstructionOrData = 1'b0;           // Instruction or Data mux
        ImmediateSrc = 3'b000;              // Immediate Type
        REGAEnable = 1'b0;                  // Update Register A
        REGBEnable = 1'b0;                  // Update Register B
        ALUSrcA = 2'b00;                    // ALU Source A MUX
        ALUSrcB = 2'b00;                    // ALU Source B MUX
        ResultSrc = 2'b00;                  // Result Source MUX
        MemWrite = 1'b0;                    // Memory Write
        RegWrite = 1'b0;                    // Register File Write
        ALUOp = 2'b00;                      // ALU Operation
        OLDPCEnable = 1'b0;

        case (current_state)
            FETCH: begin
                // Update PC to point to the next address. PC + 4 by default
                // We can rewrite this later to just skip the fetch, and go to decode MEM_WAIT immediately when jumped
                if (opcode != 7'b1101111 && opcode != 7'b1100111 && opcode != 7'b1100011) begin
                    PCEnable = 1'b1;                     // Update PC
                    OLDPCEnable = 1'b1;                 // Update OLD PC
                end
                ResultSrc = 2'b10;                  // ALURESULT which is PC + 4 Can remove this since its default
                ALUSrcB = 2'b10;                       // Constant 4 for updating pc
            end
            DECODE: begin
                // Use Decode to calculate PC next for jump and branches and store to ALUOUT So next state jump can use it
                ALUSrcA = 2'b01;                    // OLD PC
                ALUSrcB = 2'b01;                    // Immediate
                ALUOp = 2'b00;                      // ADD
                ImmediateSrc = (opcode == 7'b1100011) ? 3'b010 : 3'b100; //BTYPE (1100011) or JTYPE
            end
            // R-TYPE
            RTYPE_EXECUTION: begin
                ALUSrcA = 2'b10;                    // REGA
                ALUSrcB = 2'b00;                    // REGB. Can be removed since its default
                ALUOp = 2'b10;                      // Depend on the funct3 and funct7
            end
            ALU_WRITEBACK: begin
                // Write to register
                RegWrite = 1'b1;                    // Write to register
                ResultSrc = 2'b00;                  // ALUOUT. Can be removed since its default
            end
            // JAL
            JAL_EXECUTION: begin
                PCEnable = 1'b1;                    // Update PC
                ALUSrcA = 2'b01;                    // OLD PC
                ALUSrcB = 2'b10;                    // 4
                //OLDPCEnable = 1'b1;                 // Update OLD PC
            end
            // JALR
            JALR_EXECUTION: begin
                // Do the PC Update First. Then calculate the rd = PC + 4 next cycle
                PCEnable = 1'b1;                    // Update PC
                //OLDPCEnable = 1'b1;                 // Update OLD PC
                ALUSrcA = 2'b10;                    // REGA
                ALUSrcB = 2'b01;                    // Immediate
                ResultSrc = 2'b10;                  // ALURESULT
            end
            JALR_EXECUTION2: begin
                // Now the calculated PC + 4 which we store in rd but let the ALU writeout do the writing to reg. Just compute to be stored in ALUOUT
                ALUSrcA = 2'b01;                    // OLD PC
                ALUSrcB = 2'b10;                    // 4
            end
            // BEQ
            BRANCH_COMPLETION: begin
                ALUOp = 2'b01;                      // SUB
                ALUSrcA = 2'b10;                    // REGA
                case (funct3)
                    3'b000: PCEnable = Zero ? 1'b1 : 1'b0; // BEQ
                    3'b001: PCEnable = Zero ? 1'b0 : 1'b1; // BNE
                    3'b100: PCEnable = Zero ? 1'b0 : 1'b1; // BLT
                    3'b101: PCEnable = Zero ? 1'b0 : 1'b1; // BGE
                    3'b110: PCEnable = Zero ? 1'b0 : 1'b1; // BLTU
                    3'b111: PCEnable = Zero ? 1'b0 : 1'b1; // BGEU
                    default: PCEnable = 1'b0;
                endcase
                //OLDPCEnable = PCEnable;                 // Update OLD PC
            end
            // LW/SW
            MEMORY_ADDRESS_COMPUTATION: begin
                ALUSrcA = 2'b10;                    // REGA
                ALUSrcB = 2'b01;                    // Immediate
                ImmediateSrc = (opcode == 7'b0000011) ? 3'b000 : 3'b001; // I-Type for LW, S-Type for SW
            end
            LW_MEMORY_ACCESS: begin
                InstructionOrData = 1'b1;           // Data
            end
            LW_WRITEBACK: begin
                ResultSrc = 2'b01;                  // Data From MemoryRegister
                RegWrite = 1'b1;
            end
            SW_MEMORY_ACCESS: begin
                InstructionOrData = 1'b1;
                MemWrite = 1'b1;
            end
            // Immediate
            IMMEDIATE_EXECUTION: begin
                ALUSrcA = 2'b10;                    // REGA
                ALUSrcB = 2'b01;                    // Immediate
                ALUOp = 2'b11;                      // Depend on the funct3 and funct7
            end
            // LUI
            LUI_WRITEBACK: begin
                RegWrite = 1'b1;                    // Write to register
                ResultSrc = 2'b11;                  // Immediate
                ImmediateSrc = 3'b011;              // U-Type
            end
            // AUIPC
            AUIPC_EXECUTE: begin
                ALUSrcA = 2'b01;                    // OLD PC
                ALUSrcB = 2'b01;                    // Immediate
                ImmediateSrc = 3'b011;              // U-Type
            end
            // MEMORY_WAIT
            MEMORY_FETCH_WAIT: begin
                // LW
                InstructionOrData = 1'b0;           // Instruction
                InstructionRegisterEnable = 1'b1;   // Update Instruction Register
            end
            // MEMORY_WAIT
            MEMORY_LW_WAIT: begin
                // LW
                InstructionOrData = 1'b1;           
            end
        endcase
    end
endmodule

module ALUControl (
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    input logic [1:0] ALUOp,
    output logic [3:0] ALUControlSignal
);

    logic funct7_5;
    assign funct7_5 = funct7[5];
    
    always_comb begin
        case (ALUOp)
            2'b00: ALUControlSignal = 4'b0000; 
            2'b01: begin
                case (funct3)
                    3'b000: ALUControlSignal = 4'b0001; // BEQ
                    3'b001: ALUControlSignal = 4'b0001; // BNE
                    3'b100: ALUControlSignal = 4'b1101; // BLT
                    3'b101: ALUControlSignal = 4'b1110; // BGE
                    3'b110: ALUControlSignal = 4'b1000; // BLTU
                    3'b111: ALUControlSignal = 4'b1001; // BGEU
                    default: ALUControlSignal = 4'b0001;
                endcase
            end
            2'b10: begin
                case (funct3)
                    3'b000: ALUControlSignal = (funct7_5 == 1'b1) ? 4'b0001 : 4'b0000;
                    3'b100: ALUControlSignal = 4'b0100;
                    3'b110: ALUControlSignal = 4'b0011;
                    3'b111: ALUControlSignal = 4'b0010;
                    3'b001: ALUControlSignal = 4'b0101;
                    3'b101: ALUControlSignal = (funct7_5 == 1'b1) ? 4'b0111 : 4'b0110;
                    3'b010: ALUControlSignal = 4'b1000;
                    3'b011: ALUControlSignal = 4'b1000;
                    default: ALUControlSignal = 4'b0000;
                endcase
            end
            2'b11: begin
                case (funct3)
                    3'b000: ALUControlSignal = 4'b0000;
                    3'b100: ALUControlSignal = 4'b0100;
                    3'b110: ALUControlSignal = 4'b0011;
                    3'b111: ALUControlSignal = 4'b0010;
                    3'b001: ALUControlSignal = 4'b1010;
                    3'b101: ALUControlSignal = (funct7_5 == 1'b1) ? 4'b1100 : 4'b1011;
                    3'b010: ALUControlSignal = 4'b1101;
                    3'b011: ALUControlSignal = 4'b1000;
                    default: ALUControlSignal = 4'b0000;
                endcase
            end
            default: ALUControlSignal = 4'b0000;
        endcase
    end
endmodule