//////////////////////////////////////////////////////////////////////////////////////////////////////
// Top Module of the CPU
// Accepts data input from the bus, and an address output when the CPU is requesting memory access
//////////////////////////////////////////////////////////////////////////////////////////////////////

module CPU (
    input logic [31:0] TomemReadData,
    input logic clk,
    input logic reset,
    output logic [31:0] memAddress, memWriteData,
    output logic [3:0] byteMask,
    output logic memWrite
);

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////// FETCH //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Combinational Wires for signals. 
    logic PCEnable, InstructionRegisterEnable, InstructionOrData;// InstructionOrData control the multiplexer for the input in memory. Will also be used by Memory state

    // The registers.
    logic [31:0] PC, InstructionRegister, OLDPC;

    // Wire to contain the reversed memread data
    logic [31:0] memReadData;
    assign memReadData = {TomemReadData[7:0], TomemReadData[15:8], TomemReadData[23:16], TomemReadData[31:24]};

    // Update the registers
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            PC <= 32'b0;
            OLDPC <= 32'b0;
            InstructionRegister <= 32'b0;
        end else begin
            if (PCEnable) begin
                PC <= Result; // Update PC Either from PC+4 or ALURESULT. Result mux is in the memory state.
            end
            if (InstructionRegisterEnable) begin
                InstructionRegister <= memReadData;
            end
            if (OLDPCEnable) begin
                OLDPC <= PC;
            end
        end
    end

    // Combinational Logic in between
    // There's a multiplexer in the Address input for the memory that dictates if it should be handled by the Result or the PC reg. Implement here
    assign memAddress = (InstructionOrData == 1) ? Result : PC;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////// Decode /////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Combinational Wires for signals. 
    logic [2:0] ImmediateSrc; // Control the type of immediate i think. Im not sure.
    logic REGAEnable, REGBEnable; // Output from regfile

    // Registers
    logic [31:0] REGA, REGB;
    logic [31:0] RegFile [0:31];

    // Initialize the register file to 0
    initial begin
        for (int i = 0; i < 32; i++) begin
            RegFile[i] = 32'b0;
        end
    end

    // Combinational Wires as input to the Control Unit
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Wires in combinational logic
    logic [4:0] rs1, rs2, rd; // Input to register file
    logic [31:0] RegFileDataA, RegFileDataB; // Read data frp, regfo;e
    logic [31:0] Immediate; // Need an immediate Generator for this.
    // Immediate Types for the multiplexer, Icarus Verilog Doesnt like assiging them in an always comb
    logic [31:0] immIType, immSType, immBType, immUType, immJType;

    // Update the registers
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            REGA <= 32'b0;
            REGB <= 32'b0;
        end else begin
            REGA <= RegFileDataA;
            REGB <= RegFileDataB;
        end
    end

    // Combinational Logic in between
    // Extract part of the Instruction Registers
    assign opcode =     InstructionRegister[6:0];
    assign rs1 =        InstructionRegister[19:15];
    assign rs2 =        InstructionRegister[24:20];
    assign rd =         InstructionRegister[11:7];
    assign funct3 =     InstructionRegister[14:12];
    assign funct7 =     InstructionRegister[31:25];

    // Set Load up the immediate type wires. I cant do it inside the always block, Icarus verilog doesnt like it.
    assign immIType =  {{20{InstructionRegister[31]}}, InstructionRegister[31:20]}; 
    assign immSType =  {{20{InstructionRegister[31]}}, InstructionRegister[31:25], InstructionRegister[11:7]};
    assign immBType =  {{19{InstructionRegister[31]}}, InstructionRegister[31], InstructionRegister[7], InstructionRegister[30:25], InstructionRegister[11:8], 1'b0};
    assign immUType =  {InstructionRegister[31:12], 12'b0};
    assign immJType =  {{12{InstructionRegister[31]}}, InstructionRegister[19:12], InstructionRegister[20], InstructionRegister[30:21], 1'b0};

    // Immidiate Generator
    always_comb begin
        case (ImmediateSrc)
            0: Immediate = immIType;
            1: Immediate = immSType;
            2: Immediate = immBType;
            3: Immediate = immUType;
            4: Immediate = immJType;
            default: Immediate = immIType;
        endcase
    end

    // Combinational logic and wiring connections
    assign RegFileDataA = (rs1 == 5'b0) ? 32'b0 : RegFile[rs1];
    assign RegFileDataB = (rs2 == 5'b0) ? 32'b0 : RegFile[rs2];

    // Control Unit
    ControlUnit controlUnit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .Zero(Zero),
        .clk(clk),
        .reset(reset),
        // Fetch
        .PCEnable(PCEnable), 
        .InstructionRegisterEnable(InstructionRegisterEnable), 
        .InstructionOrData(InstructionOrData),
        .OLDPCEnable(OLDPCEnable),
        // Decode 
        .ImmediateSrc(ImmediateSrc),
        .REGAEnable(REGAEnable), 
        .REGBEnable(REGBEnable),
        // Execute
        .ALUSrcA(ALUSrcA), 
        .ALUSrcB(ALUSrcB), 
        .ALUControlSignal(ALUControlSignal),
        // Memory
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        // WriteBack
        .RegWrite(RegWrite)
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////// Execute /////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Combinational Wires for signals. 
    logic [1:0] ALUSrcA, ALUSrcB; // Control the multiplexer to choose for the input in alu
    logic [3:0] ALUControlSignal; // Control the Operation to be done by the ALU
    logic Zero; // Output from alu to the control unit.

    // Registers
    logic [31:0] ALUOUT;

    // Combinational Wires.
    logic [31:0] ALUResult; // Combinational output of ALU Before it got stored in ALUOUT;
    logic [31:0] ALUA, ALUB; // Wire connecting to the input

    // Update the registers
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            ALUOUT <= 32'b0;
        end else begin
            ALUOUT <= ALUResult;
        end
    end

    // Combinational Connections
    // Multiplexer for the input
    always_comb begin
        // SrcA
        case (ALUSrcA)
            2'b00: ALUA = PC;
            2'b01: ALUA = OLDPC;
            2'b10: ALUA = REGA;
            default: begin
                ALUA = REGA;
            end
        endcase

        // SrcB
        case (ALUSrcB)
            2'b00: ALUB = REGB;
            2'b01: ALUB = Immediate; // From the Immediate generator
            2'b10: ALUB = 32'd4; // Constant 4 for updating pc
            default: begin
                ALUB = REGB;
            end
        endcase
    end

    // ALU
    ALU alu(
        .ALUA(ALUA),
        .ALUB(ALUB),
        .ALUControlSignal(ALUControlSignal),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////// Memory //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Combinational Wires for signals. 
    logic [1:0] ResultSrc;
    logic MemWrite; // Can be refactored, naming can be a porblem
    //logic InstructionOrData; // Already in the fetch, but also used here. 

    // Registers
    logic [31:0] MemoryDataRegister; // Data From Memory

    // Multiplexer Wires
    logic [31:0] Result; // The multiplexer for choosing which data to choose. Either ALUOUT, ALuResult, or DataFromMem?
    logic [31:0] ToAddress;

    // Wire to the memory data register, here's where we do our extensions first
    logic [31:0] ToMemoryDataRegister;

    // Update the registers
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            MemoryDataRegister <= 32'b0;
        end else begin
            MemoryDataRegister <= ToMemoryDataRegister;
        end
    end

    // Multiplexers
    // Result Multiplexer
    always_comb begin
        case (ResultSrc)
            2'b00: Result = ALUOUT;
            2'b01: Result = MemoryDataRegister;
            2'b10: Result = ALUResult;
            2'b11: Result = Immediate; // For lui
            default: begin
                Result = ALUOUT;
            end
        endcase
    end

    // Wire them to the io of the cpu module. MemAddress is already wired in Fetch
    assign memWrite = MemWrite;
    logic [31:0] TomemWriteData;
    assign TomemWriteData  = {REGB[7:0], REGB[15:8], REGB[23:16], REGB[31:24]}; // Reverse the data to be written to memory
    assign memWriteData = TomemWriteData; // Output of the RegB Register

    // BYTE SELECT FOR LB and LW and SW and SB, generate a byte 4 bit mask to mask each bit of the data depending on instruction
    always_comb begin
        case (funct3)
            3'b000: byteMask = 4'b1000; // LB/SB
            3'b001: byteMask = 4'b1100; // LH/SH
            3'b010: byteMask = 4'b1111; // LW/SW
            3'b100: byteMask = 4'b1000; // LBU
            3'b101: byteMask = 4'b1100; // LHU
            default: byteMask = 4'b0000;
        endcase
    end

    // Reimplement the byte select, could use a refactor, but for reading, we should do some extensions either as signed or unsigned
    logic [31:0] LBData, LHData, LBUData, LHUData; // icarus doesnt like this inside the always comb
    assign LBData = {{24{memReadData[7]}}, memReadData[7:0]};
    assign LHData = {{16{memReadData[15]}}, memReadData[15:0]};
    assign LBUData = {24'b0, memReadData[7:0]};
    assign LHUData = {16'b0, memReadData[15:0]};
    always_comb begin
        case (funct3)
            3'b000: ToMemoryDataRegister = LBData; // LB/SB
            3'b001: ToMemoryDataRegister = LHData; // LH/SH
            3'b010: ToMemoryDataRegister = memReadData; // LW/SW
            3'b100: ToMemoryDataRegister = LBUData; // LBU
            3'b101: ToMemoryDataRegister = LHUData; // LHU
            default: ToMemoryDataRegister = memReadData;
        endcase
    end

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////// WriteBack ////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Combinational Wires for signals. 
    logic RegWrite; 

    // Update the registers / Register file in this instance
    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            MemoryDataRegister <= 32'b0;
        end else begin
            if (RegWrite) begin
                RegFile[rd] <= Result;
            end
        end
    end

endmodule