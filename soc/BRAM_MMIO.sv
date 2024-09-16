module BRAM_MMIO #(
    parameter logic [31:0] BASE_MEMORY = 32'h0000_0000,
    parameter logic [31:0] TOP_MEMORY  = 32'h0000_07ff // 2048 bytes
) (
    input  logic        clk,
    input  logic [31:0] memAddress,
    input  logic [31:0] memWriteData,
    input  logic        memWrite,
    input  logic [3:0]  byteMask,
    output logic [31:0] memReadData
);

logic [31:0] baseaddress;
assign baseaddress = memAddress - BASE_MEMORY;

// Register for reading. Since this is sequential
logic [31:0] readDataOut;

assign memReadData = readDataOut;

// Four 512x8 RAM blocks
logic [7:0] ram0 [0:511];  // Lower byte
logic [7:0] ram1 [0:511];  // Second byte
logic [7:0] ram2 [0:511];  // Third byte
logic [7:0] ram3 [0:511];  // Upper byte

// Combined sequential write and read
always_ff @(posedge clk) begin
    if (memAddress >= BASE_MEMORY && memAddress <= TOP_MEMORY) begin
        if (memWrite) begin
            if (byteMask[0]) ram0[baseaddress[10:2]] <= memWriteData[7:0];
            if (byteMask[1]) ram1[baseaddress[10:2]] <= memWriteData[15:8];
            if (byteMask[2]) ram2[baseaddress[10:2]] <= memWriteData[23:16];
            if (byteMask[3]) ram3[baseaddress[10:2]] <= memWriteData[31:24];
        end
        readDataOut[7:0]   <= ram0[baseaddress[10:2]];
        readDataOut[15:8]  <= ram1[baseaddress[10:2]];
        readDataOut[23:16] <= ram2[baseaddress[10:2]];
        readDataOut[31:24] <= ram3[baseaddress[10:2]];
    end else begin
        readDataOut <= 32'hzzzz_zzzz; // Default value if address is out of range
    end
end

initial begin
    $readmemh("riscv-code/bram_data/firstbyte.txt", ram3);
    $readmemh("riscv-code/bram_data/secondbyte.txt", ram2);
    $readmemh("riscv-code/bram_data/thirdbyte.txt", ram1);
    $readmemh("riscv-code/bram_data/fourthbyte.txt", ram0);
end

endmodule