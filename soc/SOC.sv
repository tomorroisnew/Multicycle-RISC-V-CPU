module SOC (
    input logic reset,
    output logic ledr_n, ledg_n
);
    // BUS
    logic [31:0] TomemReadData, memAddress, memWriteData;
    logic [3:0] byteMask;
    logic memWrite;

    logic clk;

    // Clock
    SB_HFOSC OSC (
        .CLKHFEN(1'b1),
        .CLKHFPU(1'b1),
        .CLKHF(clk)
    );
    defparam OSC.CLKHF_DIV = "0b11";

    // Instantiate RAM
    //RAM ram_inst (
    //    .memAddress(memAddress),
    //    .memWriteData(memWriteData),
    //    .memWrite(memWrite),
    //    .byteMask(byteMask),
    //    .memReadData(memReadData),
    //    .reset(reset),
    //    .clk(clk)
    //);

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