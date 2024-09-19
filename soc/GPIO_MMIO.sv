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
// All memories are big endian

    // Four 512x8 RAM blocks
    logic [7:0] ram0;  // Lower byte
    logic [7:0] ram1;  // Second byte
    logic [7:0] ram2;  // Third byte
    logic [7:0] ram3;  // Upper byte
    // Sequenced like these
    // ram3 - FFFF_FFF0
    // ram2 - FFFF_FFF1
    // ram1 - FFFF_FFF2
    // ram0 - FFFF_FFF3

    // Register for reading. Since this is sequential
    logic [31:0] readDataOut;

    // Assign LEDs, first 4 bits
    assign {ledr_n, ledg_n} = ram3[1:0];

    assign memReadData = readDataOut;

    logic [31:0] baseaddress;
    assign baseaddress = memAddress - BASE_MEMORY;

    // Combined sequential write and read
    always_ff @(posedge clk) begin
        if (memAddress >= BASE_MEMORY && memAddress <= TOP_MEMORY) begin
            if (memWrite) begin
                if (byteMask[0]) ram0 <= memWriteData[7:0];
                if (byteMask[1]) ram1 <= memWriteData[15:8];
                if (byteMask[2]) ram2 <= memWriteData[23:16];
                if (byteMask[3]) ram3 <= memWriteData[31:24];
            end
            readDataOut[7:0]   <= ram0;
            readDataOut[15:8]  <= ram1;
            readDataOut[23:16] <= ram2;
            readDataOut[31:24] <= ram3;
        end else begin
            readDataOut <= 32'hzzzz_zzzz; // Default value if address is out of range
        end
    end

endmodule
