module CPU_Load_Testbench;

    // Signals for CPU and memory
    logic clk, reset;
    logic [31:0] memAddress, memWriteData, memReadData;
    logic [3:0] byteMask;
    logic memWrite;

    // Declare control signals for CPU operation
    logic PCEnable, InstructionRegisterEnable, ImmediateSrc;
    
    // Instantiate CPU and connect signals
    CPU uut (
        .memReadData(memReadData),
        .clk(clk),
        .reset(reset),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .byteMask(byteMask),
        .memWrite(memWrite)
    );

    // Instantiate BRAM_MMIO for memory access simulation
    BRAM_MMIO #(
        .BASE_MEMORY(32'h0000_0000),
        .TOP_MEMORY(32'h0000_01ff)
    ) memory (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(memReadData)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Testbench flow control
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        PCEnable = 0;
        InstructionRegisterEnable = 0;
        ImmediateSrc = 0;
        memWrite = 0;
        memAddress = 0;
        memWriteData = 0;
        byteMask = 4'b0000;

        // Release reset after a short delay
        #10 reset = 0;

        // Test 1: Load Word (LW)
        $display("Test 1: LW");
        @(posedge clk);
        memWrite = 1;
        memAddress = 32'h0000_0004;
        memWriteData = 32'hDEADBEEF;  // Write to memory
        byteMask = 4'b1111;  // Write 4 bytes
        @(posedge clk);
        memWrite = 0;

        // Simulate the LW instruction
        uut.PCEnable = 1;
        uut.InstructionRegisterEnable = 1;
        uut.ImmediateSrc = 0;  // I-Type

        // Manually set LW instruction (opcode for LW is 0000011)
        uut.InstructionRegister = {7'b0000011, 5'd0, 3'b010, 5'd0, 5'd1, 7'b0000000}; // LW instruction

        @(posedge clk);
        if (uut.RegFile[1] !== 32'hDEADBEEF) begin
            $display("Test 1 Failed: Expected DEADBEEF, got %h", uut.RegFile[1]);
        end else begin
            $display("Test 1 Passed");
        end

        // Continue with other test cases...
        // Add more tests for LH, LB, LBU, etc.

        // End simulation
        $stop;
    end

endmodule
