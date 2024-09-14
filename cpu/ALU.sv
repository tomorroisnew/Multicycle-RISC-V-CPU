module ALU (
    input logic [31:0] ALUA, ALUB,
    input logic [3:0] ALUControlSignal,
    output logic [31:0] ALUResult,
    output logic Zero 
);
    logic [4:0] fiveBitImmediate;
    assign fiveBitImmediate = ALUB[4:0];

    always_comb begin
        case (ALUControlSignal)
            4'b0000: ALUResult = ALUA + ALUB;
            4'b0001: ALUResult = ALUA - ALUB;
            4'b0010: ALUResult = ALUA & ALUB;
            4'b0011: ALUResult = ALUA | ALUB;
            4'b0100: ALUResult = ALUA ^ ALUB;
            4'b0101: ALUResult = ALUA << ALUB;
            4'b0110: ALUResult = ALUA >> ALUB;
            4'b0111: ALUResult = $signed(ALUA) >>> ALUB;
            4'b1000: ALUResult = (ALUA < ALUB) ? 32'b1 : 32'b0; // Unsigned
            4'b1001: ALUResult = (ALUA >= ALUB) ? 32'b1 : 32'b0; // Unsigned
            4'b1010: ALUResult = ALUA << fiveBitImmediate;
            4'b1011: ALUResult = ALUA >> fiveBitImmediate;
            4'b1100: ALUResult = $signed(ALUA) >>> fiveBitImmediate;
            4'b1101: ALUResult = $signed(ALUA) < $signed(ALUB) ? 32'b1 : 32'b0; // Signed
            4'b1110: ALUResult = $signed(ALUA) >= $signed(ALUB) ? 32'b1 : 32'b0; // Signed
            default: ALUResult = 32'b0;
        endcase
        Zero = (ALUResult == 32'b0);
    end
endmodule