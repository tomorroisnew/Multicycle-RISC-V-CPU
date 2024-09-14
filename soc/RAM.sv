// Combine SB_SPRAM256KA to make a 32 bit ram 
module RAM (
    input logic [31:0] memAddress,
    input logic [31:0] memWriteData,
    input logic memWrite,
    input logic [3:0] byteMask,
    output logic [31:0] memReadData,
    input logic reset, clk
);
    logic [3:0] MASKWREN1, MASKWREN2;

    always_comb begin
        case (byteMask)
            4'b0001: begin
                MASKWREN1 = 4'b0000;
                MASKWREN2 = 4'b0011;
            end
            4'b0011: begin
                MASKWREN1 = 4'b0000;
                MASKWREN2 = 4'b1111;
            end
            4'b1111: begin
                MASKWREN1 = 4'b1111;
                MASKWREN2 = 4'b1111;
            end
            default: 
        endcase
    end

    // Upper 16 bit
    SB_SPRAM256KA SPRAM1 (
        .ADDRESS(memAddress),
        .DATAIN(memWriteData),
        .MASKWREN(MASKWREN1),
        .WREN(memWrite),
        .CHIPSELECT(1'b1),
        .CLOCK(clk),
        .DATAOUT(memReadData)
    );

    // Lower 16 bit
    SB_SPRAM256KA SPRAM1 (
        .ADDRESS(memAddress),
        .DATAIN(memWriteData),
        .MASKWREN(MASKWREN2),
        .WREN(memWrite),
        .CHIPSELECT(1'b1),
        .CLOCK(clk),
        .DATAOUT(memReadData)
    );
endmodule