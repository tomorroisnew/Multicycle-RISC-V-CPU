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

    // Reset generation
    initial begin
        reset = 1;
        #15 reset = 0; // Release reset after 15ns
    end

    // Initialize memory with instructions
    initial begin
        // Example instructions
        memory[0] = 32'h00a58513; // addi x10, x11, 10
        memory[1] = 32'h00a58593; // addi x11, x11, 10
        memory[2] = 32'h00a58633; // add x12, x11, x10
        memory[3] = 32'h07802683; // lw x13, 120(x0)
        memory[4] = 32'h06d02c23; // sw x13, 120(x0)
        memory[5] = 32'hfec5c8e3; // blt x11, x12, -16

        // Some data in memory
        memory[30] = 32'hffffffff; // ADDI x1, x0, 0
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

    initial begin
        $dumpfile("CPU_tb.vcd"); // Specify the name of the dump file
        $dumpvars(0, CPU_tb);    // Dump all variables in the testbench hierarchy
        $dumpvars(1, CPU_tb.uut.RegFile[0]);
        $dumpvars(1, CPU_tb.uut.RegFile[1]);
        $dumpvars(1, CPU_tb.uut.RegFile[2]);
        $dumpvars(1, CPU_tb.uut.RegFile[3]);
        $dumpvars(1, CPU_tb.uut.RegFile[4]);
        $dumpvars(1, CPU_tb.uut.RegFile[5]);
        $dumpvars(1, CPU_tb.uut.RegFile[6]);
        $dumpvars(1, CPU_tb.uut.RegFile[7]);
        $dumpvars(1, CPU_tb.uut.RegFile[8]);
        $dumpvars(1, CPU_tb.uut.RegFile[9]);
        $dumpvars(1, CPU_tb.uut.RegFile[10]);
        $dumpvars(1, CPU_tb.uut.RegFile[11]);
        $dumpvars(1, CPU_tb.uut.RegFile[12]);
        $dumpvars(1, CPU_tb.uut.RegFile[13]);
        $dumpvars(1, CPU_tb.uut.RegFile[14]);
        $dumpvars(1, CPU_tb.uut.RegFile[15]);
        $dumpvars(1, CPU_tb.uut.RegFile[16]);
        $dumpvars(1, CPU_tb.uut.RegFile[17]);
        $dumpvars(1, CPU_tb.uut.RegFile[18]);
        $dumpvars(1, CPU_tb.uut.RegFile[19]);
        $dumpvars(1, CPU_tb.uut.RegFile[20]);
        $dumpvars(1, CPU_tb.uut.RegFile[21]);
        $dumpvars(1, CPU_tb.uut.RegFile[22]);
        $dumpvars(1, CPU_tb.uut.RegFile[23]);
        $dumpvars(1, CPU_tb.uut.RegFile[24]);
        $dumpvars(1, CPU_tb.uut.RegFile[25]);
        $dumpvars(1, CPU_tb.uut.RegFile[26]);
        $dumpvars(1, CPU_tb.uut.RegFile[27]);
        $dumpvars(1, CPU_tb.uut.RegFile[28]);
        $dumpvars(1, CPU_tb.uut.RegFile[29]);
        $dumpvars(1, CPU_tb.uut.RegFile[30]);
        $dumpvars(1, CPU_tb.uut.RegFile[31]);
    end


endmodule