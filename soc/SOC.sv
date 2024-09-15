module SOC (
    input logic reset,
    output logic ledr_n, ledg_n
);
    // BUS
    logic [31:0] memReadData, memAddress, memWriteData;
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
    CPU cpu_inst (
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