module RAM_tb;
    // Declare signals
    logic [31:0] memAddress;
    logic [31:0] memWriteData;
    logic memWrite;
    logic [3:0] byteMask;
    logic [31:0] memReadData;
    logic reset, clk;

    // Instantiate the RAM module
    RAM uut (
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(memReadData),
        .reset(reset),
        .clk(clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        memWrite = 0;
        memAddress = 0;
        memWriteData = 0;
        byteMask = 4'b0000;

        // Apply reset
        #10 reset = 0;

        // Test case 1: Write to address 0 with byteMask 4'b1111
        #10;
        memAddress = 32'h0000_0000;
        memWriteData = 32'hDEAD_BEEF;
        byteMask = 4'b1111;
        memWrite = 1;
        #10 memWrite = 0;

        // Test case 2: Read from address 0
        #10;
        memAddress = 32'h0000_0000;
        memWrite = 0;
        #10;
        assert(memReadData == 32'hDEAD_BEEF) else $fatal(1, "Test case 2 failed: ReadData = %h", memReadData);

        // Test case 3: Write to address 0x4000 with byteMask 4'b0011
        #10;
        memAddress = 32'h0000_4000;
        memWriteData = 32'hCAFE_BABE;
        byteMask = 4'b0011;
        memWrite = 1;
        #10 memWrite = 0;

        // Test case 4: Read from address 0x4000
        #10;
        memAddress = 32'h0000_4000;
        memWrite = 0;
        #10;
        assert(memReadData[15:0] == 16'hBABE) else $fatal(1, "Test case 4 failed: ReadData = %h", memReadData);

        // Additional Test Cases

        // Test case 5: Write to address 0x8000 with byteMask 4'b0001
        #10;
        memAddress = 32'h0000_8000;
        memWriteData = 32'h1234_5678;
        byteMask = 4'b0001;
        memWrite = 1;
        #10 memWrite = 0;

        // Test case 6: Read from address 0x8000
        #10;
        memAddress = 32'h0000_8000;
        memWrite = 0;
        #10;
        assert(memReadData[7:0] == 8'h78) else $fatal(1, "Test case 6 failed: ReadData = %h", memReadData);

        // Test case 7: Write to address 0xC000 with byteMask 4'b1100
        #10;
        memAddress = 32'h0000_C000;
        memWriteData = 32'h8765_4321;
        byteMask = 4'b1100;
        memWrite = 1;
        #10 memWrite = 0;

        // Test case 8: Read from address 0xC000
        #10;
        memAddress = 32'h0000_C000;
        memWrite = 0;
        #10;
        assert(memReadData[31:16] == 16'h8765) else $fatal(1, "Test case 8 failed: ReadData = %h", memReadData);

        // Test case 9: Write to address 0x10000 with byteMask 4'b0110
        #10;
        memAddress = 32'h0001_0000;
        memWriteData = 32'hAABB_CCDD;
        byteMask = 4'b0110;
        memWrite = 1;
        #10 memWrite = 0;

        // Test case 10: Read from address 0x10000
        #10;
        memAddress = 32'h0001_0000;
        memWrite = 0;
        #10;
        assert(memReadData[23:8] == 16'hBBCC) else $fatal(1, "Test case 10 failed: ReadData = %h", memReadData);

        // Finish simulation
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Address: %h | WriteData: %h | ReadData: %h | Write: %b | ByteMask: %b",
                 $time, memAddress, memWriteData, memReadData, memWrite, byteMask);
    end

    // Waveform dumping
    initial begin
        $dumpfile("RAM_tb.vcd");
        $dumpvars(0, RAM_tb);
    end
endmodule