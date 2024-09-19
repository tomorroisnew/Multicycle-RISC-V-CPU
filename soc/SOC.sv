module SOC (
    input logic reset,
    input logic start,  // Add start signal
    output logic ledr_n, ledg_n, led_r2
);
    // BUS
    logic [31:0] TomemReadData, memAddress, memWriteData;
    logic [3:0] byteMask;
    logic memWrite;

    logic clk, gated_clk;
    logic start_toggle;
    logic start_prev;

    // Clock generation
    SB_LFOSC OSC (
        .CLKLFPU(1'b1),
        .CLKLFEN(1'b1),
        .CLKLF(clk)
    );

    assign led_r2 = start_toggle;

    // Toggle logic for start signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            start_toggle <= 0;
            start_prev <= 0;
        end else begin
            if (start && !start_prev) begin
                start_toggle <= ~start_toggle;
            end
            start_prev <= start;
        end
    end

    // Gated clock logic
    always_comb begin
        if (start_toggle) begin
            gated_clk = clk;
        end else begin
            gated_clk = 0;
        end
    end

    // Instantiate CPU
    CPU cpu (
        .TomemReadData(TomemReadData),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .byteMask(byteMask),
        .memWrite(memWrite),
        .reset(reset),
        .clk(gated_clk)  // Use gated clock
    );

    // Memory decoder for the mmio.
    // 32'h0000_0000 - 32'h0000_01FF BRAM // Change to flash spi soon
    // 32'hFFFF_FFF0 - 32'hFFFF_FFF3 GPIO
    // 32'hFFFF_FFF4 - 32'hFFFF_FFF7 UART
    BRAM_MMIO bram_mmio (
        .clk(gated_clk),  // Use gated clock
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .memReadData(bramReadData), .byteMask(byteMask)
    );
    GPIO_MMIO gpio_mmio (
        .clk(gated_clk),  // Use gated clock
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
    always_ff @(posedge gated_clk or posedge reset) begin
        if (reset) begin
            delayedMemAddress <= 32'h0000_0000;  // Reset condition
        end else begin
            delayedMemAddress <= memAddress;     // Capture the address each cycle
        end
    end

    // Multiplexer for memReadData
    logic [31:0] bramReadData, gpioReadData;

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
