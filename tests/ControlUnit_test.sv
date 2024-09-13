module CPU_tb;

    // Testbench signals
    logic [31:0] memReadData;
    logic clk;
    logic reset;
    logic [31:0] memAddress, memWriteData;
    logic memWrite;

    // Simple memory model
    logic [31:0] memory [0:255];

    // Instantiate the CPU
    CPU uut (
        .memReadData(memReadData),
        .clk(clk),
        .reset(reset),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    #// Reset generation
    #initial begin
        reset = 1;
        #15 reset = 0; // Release reset after 15ns
    end

    // Initialize memory with instructions
    initial begin
        // Example instructions
        memory[0] = 32'h00a58513; // addi x10, x11, 10
        memory[1] = 32'h00000093; // ADDI x1, x0, 0
        memory[2] = 32'h00100113; // ADDI x2, x0, 1
        memory[3] = 32'h00208193; // ADDI x3, x1, 2
        // Add more instructions as needed
    end

    // Memory read logic
    always_comb begin
        memReadData = memory[memAddress>>2];
    end

    // Test sequence
    initial begin
        // Wait for reset deassertion
        @(negedge reset);

        // Run the CPU for a certain number of cycles
        repeat (100) @(posedge clk);

        // Finish simulation
        $display("Simulation finished.");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | memAddress=%h | memWriteData=%h | memWrite=%b", $time, memAddress, memWriteData, memWrite);
    end

endmodule