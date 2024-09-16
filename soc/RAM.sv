// Combine SB_SPRAM256KA to make a 32 bit ram 
module RAM #(
    parameter logic [31:0] BASE_MEMORY = 32'h0000_0800,
    parameter logic [31:0] TOP_MEMORY  = 32'h0000_07ff // 2048 bytes
) (
    input logic [31:0] memAddress,
    input logic [31:0] memWriteData,
    input logic memWrite,
    input logic [3:0] byteMask,
    output logic [31:0] memReadData,
    input logic reset, clk
);
    logic [3:0] MASKWREN1, MASKWREN2;
    logic [31:0] readDataOut1, readDataOut2;

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
            default: begin
                MASKWREN1 = 4'b1111;
                MASKWREN2 = 4'b1111;
            end
        endcase
    end

    // Select which of the rams to use
    // If address is less than or equal to 14b’11111111111111, we can use the first ram, enable its Chipselect
    // If address is greater than 14b’11111111111111, use the second ram, enable its Chipselect
    // Total of 268435456 addressable, 32 bits each locations or 1024 MB
    logic chipSelect1, chipSelect2;

    always_comb begin
        if (baseAddress <= 14'b11111111111111) begin
            chipSelect1 = 1'b1;
            chipSelect2 = 1'b0;
            memReadData = readDataOut1;
        end else begin
            chipSelect1 = 1'b0;
            chipSelect2 = 1'b1;
            memReadData = readDataOut2;
        end
    end

    // First 2 SB_SPRAM256KA combined to make a 32 bit RAM
    // Upper 16 bit
    SB_SPRAM256KA SPRAM00 (
        .ADDRESS(baseAddress[13:0]),
        .DATAIN(memWriteData[31:16]),
        .MASKWREN(MASKWREN1),
        .WREN(memWrite),
        .CHIPSELECT(chipSelect1),
        .CLOCK(clk),
        .DATAOUT(readDataOut1[31:16])
    );

    // Lower 16 bit
    SB_SPRAM256KA SPRAM01 (
        .ADDRESS(baseAddress[13:0]),
        .DATAIN(memWriteData[15:0]),
        .MASKWREN(MASKWREN2),
        .WREN(memWrite),
        .CHIPSELECT(chipSelect1),
        .CLOCK(clk),
        .DATAOUT(readDataOut1[15:0])
    );

    // Second 2 SB_SPRAM256KA combined to make a 32 bit RAM
    // Adress for second ram is baseAddress - 14'b11111111111111
    logic [31:0] baseAddress2;
    always_comb begin
        baseAddress2 = baseAddress - 14'b11111111111111;
    end
    SB_SPRAM256KA SPRAM10 (
        .ADDRESS(baseAddress2[13:0]),
        .DATAIN(memWriteData[31:16]),
        .MASKWREN(MASKWREN1),
        .WREN(memWrite),
        .CHIPSELECT(chipSelect2),
        .CLOCK(clk),
        .DATAOUT(readDataOut2[31:16])
    );

    // Lower 16 bit
    SB_SPRAM256KA SPRAM11 (
        .ADDRESS(baseAddress2[13:0]),
        .DATAIN(memWriteData[15:0]),
        .MASKWREN(MASKWREN2),
        .WREN(memWrite),
        .CHIPSELECT(chipSelect2),
        .CLOCK(clk),
        .DATAOUT(readDataOut2[15:0])
    );

endmodule