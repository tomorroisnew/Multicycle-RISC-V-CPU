module GPIO_MMIO #(
    parameter logic [31:0] BASE_MEMORY = 32'hFFFF_FFF0,
    parameter logic [31:0] TOP_MEMORY  = 32'hFFFF_FFF3  // Adjusted to cover 4 bytes (32 bits)
)(
    input  logic        clk,
    input  logic [31:0] memAddress,
    input  logic [31:0] memWriteData,
    input  logic        memWrite,
    input  logic [3:0]  byteMask,
    output logic [31:0] memReadData,
    output logic ledr_n, ledg_n
);

    // 32-bit memory register byte addressable
    logic [7:0] memory [3:0];

    // Read data register
    logic [31:0] dataout;

    // Assign LEDs, first 4 bits
    assign {ledr_n, ledg_n} = memory[0][1:0];

    // Output the read data
    assign memReadData = dataout;

    logic [31:0] byteIndex;
    assign byteIndex = memAddress - BASE_MEMORY;

    // Read and Write operation
    always_ff @(posedge clk) begin
        if (memAddress >= BASE_MEMORY && memAddress <= TOP_MEMORY) begin
            // Read operation: Read the entire 32-bit memory
            dataout <= {memory[byteIndex], memory[byteIndex+1], memory[byteIndex+2], memory[byteIndex+3]};

            // Write operation: Byte-enable logic using byteMask
            if (memWrite) begin
                if (memWrite) begin
                    if (byteMask[0]) memory[byteIndex] <= memWriteData[7:0];
                    if (byteMask[1]) memory[byteIndex+1] <= memWriteData[15:8];
                    if (byteMask[2]) memory[byteIndex+2] <= memWriteData[23:16];
                    if (byteMask[3]) memory[byteIndex+3] <= memWriteData[31:24];
                end
            end
        end else begin
            dataout <= 32'hZZZZ_ZZZZ;  // Undefined if address is out of range
        end
    end

endmodule
