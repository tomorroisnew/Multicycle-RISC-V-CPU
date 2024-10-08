module SOC (
    input logic reset,
    input logic start,  // Add start signal
    //GPIO
    output logic red_led, green_led, led4grn, led3grn, led5grn, led_1red,
    //UART
    output logic uart_tx,
    input logic uart_rx
);
    // BUS
    logic [31:0] TomemReadData, memAddress, memWriteData;
    logic [31:0] bramReadData, gpioReadData, uartReadData;
    logic [3:0] byteMask;
    logic memWrite;

    logic clk, clk_12mhz;
    logic resetn;
    logic start_toggle;
    logic start_prev;

        // Clock generation
    SB_HFOSC OSC (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk_12mhz)
    );
    defparam OSC.CLKHF_DIV = "0b10";

    //logic clk_11mhz;

    // Instantiate the PLL to generate an 9.00 MHz clock from the 12 MHz input
    SB_PLL40_CORE pll_inst (
        .REFERENCECLK(clk_12mhz),  // Connect the 12 MHz HFOSC output
        .PLLOUTGLOBAL(clk),        // Output the 11 MHz clock
        .RESETB(1'b1),             // Active low reset for the PLL
        .BYPASS(1'b0)              // Do not bypass the PLL
    );

    // PLL Parameters
    defparam pll_inst.DIVR = 4'b0000;         // Reference divider: Divide by 1
    defparam pll_inst.DIVF = 7'b0101111;      // Feedback divider: Multiply by 48 (updated to 47)
    defparam pll_inst.DIVQ = 3'b110;          // Output divider: Divide by 32
    defparam pll_inst.FILTER_RANGE = 3'b001;  // PLL filter range

    //Clockworks #(
    //    .SLOW(10) // Divide clock frequency by 2^10
    //) CW (
    //    .CLK(clk),
    //    .RESET(reset),
    //    .clk(slowed_clk),
    //    .resetn(resetn)
    //);

    //assign red_led = ~slowed_clk;


    // Instantiate CPU
    CPU cpu (
        .TomemReadData(TomemReadData),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .byteMask(byteMask),
        .memWrite(memWrite),
        .reset(reset),
        .clk(clk)  // Use gated clock
    );

    // Memory decoder for the mmio.
    // 32'h0000_0000 - 32'h0000_07ff BRAM // Change to flash spi soon
    // 32'hFFFF_FFF0 - 32'hFFFF_FFF3 GPIO
    BRAM_MMIO # (
        .BASE_MEMORY(32'h0000_0000),
        .TOP_MEMORY(32'h0000_07ff)
    ) bram_mmio (
        .clk(clk),  // Use gated clock
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .memReadData(bramReadData), .byteMask(byteMask)
    );
    GPIO_MMIO # (
        .BASE_MEMORY(32'hFFFF_FFF0),
        .TOP_MEMORY(32'hFFFF_FFF3)
    ) gpio_mmio (
        .clk(clk),  // Use gated clock
        .reset(reset),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(gpioReadData),
        .led1(led_1red), .led3(led4grn), .led4(led3grn), .led5(led5grn)
    );
    UART_MMIO # (
        .BASE_MEMORY(32'hFFFF_FFF4),
        .TOP_MEMORY(32'hFFFF_FFF7),
        .BAUD_DIVIDER(9600)
    ) uart_mmio (
        .clk(clk),  // Use gated clock
        .reset(reset),
        .memAddress(memAddress),
        .memWriteData(memWriteData),
        .memWrite(memWrite),
        .byteMask(byteMask),
        .memReadData(uartReadData),
        .uart_tx(uart_tx), .uart_rx(uart_rx)
    );

    // Introduce a 1-cycle delay for the memory address since one memory access is its own state
    // Memory accesses are sequential, but we compare the address combinational, so it result in a mismatch
    // Since the data is only available in the next cycle but by then the address has changed
    // So we save the original address used to access the memory and use that to compare the data
    logic [31:0] delayedMemAddress;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            delayedMemAddress <= 32'h0000_0000;  // Reset condition
        end else begin
            delayedMemAddress <= memAddress;     // Capture the address each cycle
        end
    end

    // Multiplexer for memReadData
    always_comb begin
        // BRAM
        if (delayedMemAddress >= 32'h0000_0000 && delayedMemAddress <= 32'h0000_07ff) begin
            TomemReadData = bramReadData;
        end else if (delayedMemAddress >= 32'hFFFF_FFF0 && delayedMemAddress <= 32'hFFFF_FFF3) begin
            TomemReadData = gpioReadData;
        end else if (delayedMemAddress >= 32'hFFFF_FFF4 && delayedMemAddress <= 32'hFFFF_FFF7) begin
            TomemReadData = uartReadData;
        end else begin
            TomemReadData = 32'h0000_0000;
        end
    end

endmodule


//module Clockworks 
//(
//   input  CLK,   // clock pin of the board
//   input  RESET, // reset pin of the board
//   output clk,   // (optionally divided) clock for the design.
//   output resetn // (optionally timed) negative reset for the design (more on this later)
//);
//   parameter SLOW = 10;
//   reg [SLOW:0] slow_CLK = 0;
//   always @(posedge CLK or posedge RESET) begin
//      if (RESET) begin
//         slow_CLK <= 0;
//      end else begin
//         slow_CLK <= slow_CLK + 1;
//      end
//   end
//   assign clk = slow_CLK[SLOW];
//   assign resetn = ~RESET;
//endmodule