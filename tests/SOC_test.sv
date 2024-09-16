module test_SOC;

    // Inputs
    logic reset;
    logic clk;

    // Outputs
    logic ledr_n, ledg_n;

    // Waveform dump
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, test_SOC);
        $dumpvars(1, test_SOC.bram_mmio.ram0[0]);
        $dumpvars(1, test_SOC.bram_mmio.ram1[0]);
        $dumpvars(1, test_SOC.bram_mmio.ram2[0]);
        $dumpvars(1, test_SOC.bram_mmio.ram3[0]);
        $dumpvars(1, test_SOC.bram_mmio.ram0[1]);
        $dumpvars(1, test_SOC.bram_mmio.ram1[1]);
        $dumpvars(1, test_SOC.bram_mmio.ram2[1]);
        $dumpvars(1, test_SOC.bram_mmio.ram3[1]);
        $dumpvars(1, test_SOC.cpu.RegFile[1]);
        $dumpvars(1, test_SOC.cpu.RegFile[2]);
        $dumpvars(1, test_SOC.cpu.RegFile[10]);
        $dumpvars(1, test_SOC.cpu.RegFile[11]);
        $dumpvars(1, test_SOC.cpu.RegFile[14]);
        $dumpvars(1, test_SOC.cpu.RegFile[15]);
    end

    // BUS
    logic [31:0] TomemReadData, memAddress, memWriteData;
    logic [31:0] bramReadData, gpioReadData;
    logic [3:0] byteMask;
    logic memWrite;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Generate clock signal with period 10 time units
    end

    // Test reset signal
    initial begin
        reset = 1;
        #10;
        reset = 0;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, reset = %0b, ledr_n = %0b, ledg_n = %0b", $time, reset, ledr_n, ledg_n);
        $monitor("At time %t, reset = %0b, ledr_n = %0b, ledg_n = %0b, PC = %h, Instruction = %h, memAddress = %h, memReadData = %h", 
             $time, reset, ledr_n, ledg_n, cpu.PC, cpu.InstructionRegister, memAddress, TomemReadData);
    end

    // Waveform dump
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, test_SOC);
    end

    // Instantiate CPU
    CPU cpu (
        .TomemReadData(TomemReadData),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .byteMask(byteMask),
        .memWrite(memWrite),
        .reset(reset),
        .clk(clk)
    );

    // Memory decoder for the mmio.
    // 32'h0000_0000 - 32'h0000_07ff BRAM // Change to flash spi soon
    // 32'hFFFF_FFF0 - 32'hFFFF_FFF3 GPIO
    BRAM_MMIO bram_mmio (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .memReadData(bramReadData), .byteMask(byteMask)
    );
    GPIO_MMIO gpio_mmio (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(gpioReadData),
        .ledr_n(ledr_n), .ledg_n(ledg_n)
    );
    logic test, test2;
    assign test = memAddress >= 32'h0000_0000 && memAddress <= 32'h0000_01FF;
    assign test2 = memAddress >= 32'hFFFF_FFF0 && memAddress <= 32'hFFFF_FFF3;

    // Introduce a 1-cycle delay for the memory address since one memory access is its own state
    // Memory accesses are sequential, but we compare the address combinational, so it result in a mismatch
    // Since the data is only available in the next cycle but by then the address has changed
    // So we save the original address used to access the memory and use that to compare the data
    logic [31:0] delayedMemAddress;
    always_ff @(posedge clk) begin
        if (reset) begin
            delayedMemAddress <= 32'h0000_0000;  // Reset condition
        end else begin
            delayedMemAddress <= memAddress;     // Capture the address each cycle
        end
    end

    // Multiplexer for memReadData
    always_comb begin
        // BRAM
        if (delayedMemAddress >= bram_mmio.BASE_MEMORY && delayedMemAddress <= bram_mmio.TOP_MEMORY) begin
            TomemReadData = bramReadData;
        end else if (delayedMemAddress >= gpio_mmio.BASE_MEMORY && delayedMemAddress <= gpio_mmio.TOP_MEMORY) begin
            TomemReadData = gpioReadData;
        end else begin
            TomemReadData = 32'h0000_0000;
        end
    end

endmodule
