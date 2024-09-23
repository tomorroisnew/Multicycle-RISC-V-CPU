module test_PLIC;
    // Parameters
    parameter logic [31:0] BASE_MEMORY = 32'h0000_0000;
    parameter logic [31:0] TOP_MEMORY  = 32'h003FFFFFC;

    // Signals
    logic clk;
    logic reset;
    logic [31:0] memAddress;
    logic [31:0] memWriteData;
    logic memWrite;
    logic [3:0] byteMask;
    logic [31:0] memReadData;
    logic signal1, signal2;
    logic interruptComplete1, interruptComplete2;
    logic EIP;

    // Instantiate PLIC
    PLIC #(
        .BASE_MEMORY(BASE_MEMORY),
        .TOP_MEMORY(TOP_MEMORY)
    ) uut (
        .clk(clk),
        .reset(reset),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(memReadData),
        .signal1(signal1),
        .signal2(signal2),
        .interruptComplete1(interruptComplete1),
        .interruptComplete2(interruptComplete2),
        .EIP(EIP)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initial block for test cases
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        memAddress = 0;
        memWriteData = 0;
        memWrite = 0;
        byteMask = 4'b1111;
        signal1 = 0;
        signal2 = 0;

        // Apply reset
        #10 reset = 0;

        // Test reset behavior
        #10;
        assert(uut.interruptSource1Priority == 32'h00);
        assert(uut.interruptSource2Priority == 32'h00);
        assert(uut.interruptEnableContext0 == 32'h00);
        assert(uut.interruptPriorityThresholdContext0 == 32'h00);
        assert(uut.interruptClaimCompleteContext0 == 32'h00);

        // Test write operations
        memAddress = BASE_MEMORY + 32'h000004;
        memWriteData = 32'hA5A5A5A5;
        memWrite = 1;
        #10 memWrite = 0;
        assert(uut.interruptSource1Priority == 32'hA5A5A5A5);

        memAddress = BASE_MEMORY + 32'h000008;
        memWriteData = 32'h5A5A5A5A;
        memWrite = 1;
        #10 memWrite = 0;
        assert(uut.interruptSource2Priority == 32'h5A5A5A5A);

        // Test read operations
        memAddress = BASE_MEMORY + 32'h000004;
        #10;
        assert(memReadData == 32'hA5A5A5A5);

        memAddress = BASE_MEMORY + 32'h000008;
        #10;
        assert(memReadData == 32'h5A5A5A5A);

        // Test interrupt logic
        signal1 = 1;
        signal2 = 0;
        uut.interruptEnableContext0 = 32'h00000002;
        uut.interruptSource1Priority = 32'h00000010;
        uut.interruptPriorityThresholdContext0 = 32'h00000005;
        #10;
        assert(uut.EIP == 1);
        assert(uut.interruptPending[1] == 1);

        signal1 = 0;
        signal2 = 1;
        uut.interruptEnableContext0 = 32'h00000004;
        uut.interruptSource2Priority = 32'h00000020;
        uut.interruptPriorityThresholdContext0 = 32'h00000005;
        #10;
        assert(uut.EIP == 1);
        assert(uut.interruptPending[2] == 1);

        // Test interrupt claim/complete
        memAddress = BASE_MEMORY + 32'h00200004;
        #10;
        assert(memReadData == 32'h2);
        memWriteData = 32'h2;
        memWrite = 1;
        #10 memWrite = 0;
        assert(interruptComplete2 == 1);

        $finish;
    end
endmodule