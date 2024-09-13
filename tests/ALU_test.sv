module cpu_tb;

    // Inputs
    logic [31:0] data;
    logic clk, reset;

    // Outputs
    logic [31:0] address;

    // Instantiate the CPU module
    cpu uut (
        .data(data),
        .clk(clk),
        .reset(reset),
        .address(address)
    );

    // Test clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Generate clock signal with period 10 time units
    end

    // Test memory
    logic [31:0] memory [0:255];  // A small memory array for testing

    // Initialize memory and test instructions
    initial begin
        // Initialize test memory with some instructions (simplified for demo)
        memory[0] = 32'h00000293; // ADDI x5, x0, 0 (x5 = 0)
        memory[1] = 32'h00100313; // ADDI x6, x0, 1 (x6 = 1)
        memory[2] = 32'h00530333; // ADD x6, x6, x5 (x6 = x6 + x5)
        memory[3] = 32'h0000006F; // JAL 0 (Jump to itself, loop)

        // Initialize data input from memory
        data = memory[0];  // Load the first instruction initially

        // Apply reset at the beginning
        reset = 1'b0;  // Assert reset (active low)
        #10;
        reset = 1'b1;  // Deassert reset

        // Simulate memory reading as the CPU fetches the next instructions
        @(posedge clk) data = memory[1];  // Load the next instruction
        @(posedge clk) data = memory[2];  // Load the next instruction
        @(posedge clk) data = memory[3];  // Load the jump instruction (loop)

        // Continue simulation for a few more cycles
        #100;  // Simulate for 100 more time units

        $stop;  // End the simulation
    end

    // Monitor output and state transitions
initial begin
    // Monitor output and state transitions
    $monitor("Time: %0t | PC Address: %h | Data: %h | Address Output: %h", $time, uut.PC, data, address);
end


endmodule
