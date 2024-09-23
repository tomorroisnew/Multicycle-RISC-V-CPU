module PLIC #(
    parameter logic [31:0] BASE_MEMORY = 32'h0000_0000,
    parameter logic [31:0] TOP_MEMORY  = 32'h003FFFFFC 
)(
    input  logic        clk,
    input  logic        reset,         // Added reset input
    input  logic [31:0] memAddress,
    input  logic [31:0] memWriteData,
    input  logic        memWrite,
    input  logic [3:0]  byteMask,
    output logic [31:0] memReadData,
    // PLIC specific signals
    input logic signal1, signal2, // Interrupt signals from gateways of the peripherals
    output logic interruptComplete1, interruptComplete2, // Signal gateways that interrupt is complete and ready to send a new interruupt
    output logic EIP // Interrupt pending
);
    // Registers
    // base + 0x000004: Interrupt source 1 priority
    logic [31:0] interruptSource1Priority;
    //base + 0x000008: Interrupt source 2 priority
    logic [31:0] interruptSource2Priority;
    // base + 0x002000: Enable bits for sources 0-31 on context 0
    logic [31:0] interruptEnableContext0;
    // base + 0x001000: Interrupt Pending bit 0-31
    logic [31:0] interruptPending;
    // base + 0x200000: Priority threshold for context 0
    logic [31:0] interruptPriorityThresholdContext0;
    // base + 0x200004: Claim/complete for context 0
    logic [31:0] interruptClaimCompleteContext0;

    // Interrupt pending bits
    logic EIP1, EIP2;

    logic [31:0] readDataOut;
    assign memReadData = readDataOut;

    logic [31:0] baseaddress;
    assign baseaddress = memAddress - BASE_MEMORY;

    // Combined sequential write and read
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            interruptSource1Priority <= 32'h00;
            interruptSource2Priority <= 32'h00;
            interruptEnableContext0 <= 32'h00;
            interruptPriorityThresholdContext0 <= 32'h00;
            interruptClaimCompleteContext0 <= 32'h00;
            readDataOut <= 32'h0000_0000;
        end else begin
            // Basic Memio operations
            if (memAddress >= BASE_MEMORY && memAddress <= TOP_MEMORY) begin
                if (memWrite) begin
                    case(baseaddress)
                        32'h0000_0004: interruptSource1Priority <= memWriteData;
                        32'h0000_0008: interruptSource2Priority <= memWriteData;
                        //32'h0000_1000: interruptPending <= memWriteData;
                        32'h0000_2000: interruptEnableContext0 <= memWriteData;
                        32'h0020_0000: interruptPriorityThresholdContext0 <= memWriteData;
                        //32'h0000_2008: interruptClaimCompleteContext0 <= memWriteData; // Read only
                    endcase
                    //if (byteMask[0]) ram0 <= memWriteData[7:0];
                    //if (byteMask[1]) ram1 <= memWriteData[15:8];
                    //if (byteMask[2]) ram2 <= memWriteData[23:16];
                    //if (byteMask[3]) ram3 <= memWriteData[31:24];
                end

                case(baseaddress)
                    32'h0000_0000: readDataOut <= interruptSource1Priority;
                    32'h0000_0004: readDataOut <= interruptSource2Priority;
                    32'h0000_1000: readDataOut <= interruptPending;
                    32'h0000_2000: readDataOut <= interruptEnableContext0;
                    32'h0000_2004: readDataOut <= interruptPriorityThresholdContext0;
                endcase
                //readDataOut[7:0]   <= ram0;
                //readDataOut[15:8]  <= ram1;
                //readDataOut[23:16] <= ram2;
                //readDataOut[31:24] <= ram3;
            end else begin
                readDataOut <= 32'hzzzz_zzzz; // Default value if address is out of range
            end
        end

        // PLIC Logic
        EIP1 <= (EIP == 0) ? (interruptEnableContext0[1] && signal1 && interruptSource1Priority > interruptPriorityThresholdContext0) : EIP1;
        EIP2 <= (EIP == 0) ? (interruptEnableContext0[2] && signal2 && interruptSource2Priority > interruptPriorityThresholdContext0) : EIP2;
        EIP <= EIP1 || EIP2; // Sends the signal that an interrupt is pending

        interruptPending <= { 29'h0, EIP2, EIP1, 1'b0}; // Set the interrupt pending bits

        // Set interruptClaimCompleteContext0 to the ID of the active interrupt
        if (EIP1 && EIP2) begin
            // Both interrupts are pending, check priorities
            if (interruptSource1Priority > interruptSource2Priority) begin
                interruptClaimCompleteContext0 <= 32'h1; // ID for interrupt source 1
            end else if (interruptSource1Priority < interruptSource2Priority) begin
                interruptClaimCompleteContext0 <= 32'h2; // ID for interrupt source 2
            end else begin
                interruptClaimCompleteContext0 <= 32'h1; // Prioritized lower number if all have the same priority
            end
        end else if (EIP1) begin
            interruptClaimCompleteContext0 <= 32'h1; // ID for interrupt source 1
        end else if (EIP2) begin
            interruptClaimCompleteContext0 <= 32'h2; // ID for interrupt source 2
        end else begin
            interruptClaimCompleteContext0 <= 32'h0; // No active interrupt
        end

        // Handle logic for interrupt claim/complete
        if (baseaddress == 32'h0020_0004) begin
            readDataOut <= interruptClaimCompleteContext0;
            // Clear the EIP of the claimed interrupt
            if (interruptClaimCompleteContext0 == 32'h1) begin
                EIP1 <= 0;
            end else if (interruptClaimCompleteContext0 == 32'h2) begin
                EIP2 <= 0;
            end

            // Completion message
            if (memWrite) begin
                // Complete
                if(memWriteData == 32'h1 && !interruptComplete1) begin
                    interruptComplete1 <= 1;
                end else begin
                    interruptComplete1 <= 0;
                end
                if(memWriteData == 32'h2 && !interruptComplete2) begin
                    interruptComplete2 <= 1;
                end else begin
                    interruptComplete2 <= 0;
                end
            end else begin
                interruptComplete1 <= 0;
                interruptComplete2 <= 0;
            end
        end
    end
endmodule