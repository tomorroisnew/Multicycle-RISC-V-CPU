module UART_MMIO #(
    parameter logic [31:0] BASE_MEMORY = 32'hFFFF_FFF4,
    parameter logic [31:0] TOP_MEMORY  = 32'hFFFF_FFF7 // 2048 bytes
) (
    input logic clk,
    input logic [31:0] memAddress, memWriteData, memWrite,
    input logic [3:0] byteMask,
    output logic [31:0] uartReadData,
    output logic uart_tx, uart_rx
);
    //hFFFF_FFF4 - 
endmodule