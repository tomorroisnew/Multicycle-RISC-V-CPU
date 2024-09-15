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
        $dumpvars(1, test_SOC.cpu.RegFile[9]);
        $dumpvars(1, test_SOC.cpu.RegFile[10]);
        $dumpvars(1, test_SOC.cpu.RegFile[11]);
    end

    // BUS
    logic [31:0] memReadData, memAddress, memWriteData;
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
    end

    // Waveform dump
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, test_SOC);
    end

    // Instantiate CPU
    CPU cpu (
        .memReadData(memReadData),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .byteMask(byteMask),
        .memWrite(memWrite),
        .reset(reset),
        .clk(clk)
    );

    // Memory decoder for the mmio.
    // 32'h0000_0000 - 32'h0000_01FF BRAM // Change to flash spi soon
    // 32'hFFFF_FFF0 - 32'hFFFF_FFF3 GPIO
    BRAM_MMIO bram_mmio (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .memReadData(bramReadData)
    );
    GPIO_MMIO led_mmio (
        .clk(clk),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(gpioReadData),
        .ledr_n(ledr_n), .ledg_n(ledg_n)
    );

    // Multiplexer for memReadData
    always_comb begin
        if (memAddress >= 32'h0000_0000 && memAddress <= 32'h0000_01FF) begin
            memReadData = bramReadData;
        end else if (memAddress >= 32'hFFFF_FFF0 && memAddress <= 32'hFFFF_FFF3) begin
            memReadData = gpioReadData;
        end else begin
            memReadData = 32'h0000_0000;
        end
    end

endmodule
