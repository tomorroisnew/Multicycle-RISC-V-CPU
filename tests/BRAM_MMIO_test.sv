module BRAM_MMIO_tb();

    // Parameters
    parameter logic [31:0] BASE_MEMORY = 32'h0000_0000;
    parameter logic [31:0] TOP_MEMORY  = 32'h0000_0810; // 512 bytes
    
    // Inputs
    logic clk;
    logic [31:0] memAddress;
    logic [31:0] memWriteData;
    logic memWrite;
    logic [3:0] byteMask;
    
    // Outputs
    logic [31:0] memReadData;

    // Instantiate the module under test (MUT)
    BRAM_MMIO #(
        .BASE_MEMORY(BASE_MEMORY),
        .TOP_MEMORY(TOP_MEMORY)
    ) mut (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(memReadData)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize VCD dump
        $dumpfile("BRAM_MMIO_tb.vcd");  // Specify the output VCD file
        $dumpvars(0, BRAM_MMIO_tb);     // Dump all variables

        // Initialize inputs
        memAddress = 32'h0000_0000;
        memWriteData = 32'h0000_0000;
        memWrite = 0;
        byteMask = 4'b0000;

        // Wait for reset
        #10;
        
        // Test 1: Write a full word (32 bits) to address 0x0000_0000
        memAddress = 32'h0000_0000;
        memWriteData = 32'hDEADBEEF;
        byteMask = 4'b1111; // Write all bytes
        memWrite = 1;
        #10;
        memWrite = 0;
        
        // Wait one clock cycle for the write to propagate
        #10;

        // Test 2: Read back the word from address 0x0000_0000
        memAddress = 32'h0000_0000;
        #10; // Wait for the read data to be captured
        $display("Test 2 - Read Data: %h (Expected: DEADBEEF)", memReadData);

        // Test 3: Write only the lower byte to address 0x0000_0004
        memAddress = 32'h0000_0004;
        memWriteData = 32'h000000FF;
        byteMask = 4'b0001; // Write only the least significant byte
        memWrite = 1;
        #10;
        memWrite = 0;
        
        // Wait one clock cycle for the write to propagate
        #10;

        // Test 4: Read back the word from address 0x0000_0004
        memAddress = 32'h0000_0004;
        #10; // Wait for the read data to be captured
        $display("Test 4 - Read Data: %h (Expected: 000000FF)", memReadData);

        // Test 5: Write to all bytes of address 0x0000_0008
        memAddress = 32'h0000_0008;
        memWriteData = 32'hAABBCCDD;
        byteMask = 4'b1111;
        memWrite = 1;
        #10;
        memWrite = 0;
        
        // Wait one clock cycle for the write to propagate
        #10;

        // Test 6: Read back the word from address 0x0000_0008
        memAddress = 32'h0000_0008;
        #10; // Wait for the read data to be captured
        $display("Test 6 - Read Data: %h (Expected: AABBCCDD)", memReadData);

        // Test 4: Read back the word from address 0x0000_0004
        memAddress = 32'h0000_0004;
        #10; // Wait for the read data to be captured
        $display("Test 4 - Read Data: %h (Expected: 000000FF)", memReadData);

        // Test 5: Write to all bytes of address 0x0000_0008
        memAddress = 32'h0000_07CC;
        memWriteData = 32'hAABBCCDD;
        byteMask = 4'b1111;
        memWrite = 1;
        #10;
        memWrite = 0;
        
        // Wait one clock cycle for the write to propagate
        #10;

        // Test 6: Read back the word from address 0x0000_0008
        memAddress = 32'h0000_0804;
        #10; // Wait for the read data to be captured
        $display("Test 6 - Read Data: %h (Expected: AABBCCDD)", memReadData);

        // End simulation
        #10;
        $finish;
    end

endmodule
