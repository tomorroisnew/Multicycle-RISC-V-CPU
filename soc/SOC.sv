module SOC (
    input logic reset
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
    defparam clkclk.CLKHF_DIV = "0b11";

    // Main memory Decoder
    // 

endmodule