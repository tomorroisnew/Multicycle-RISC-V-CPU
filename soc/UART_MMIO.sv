module UART_MMIO #(
    parameter logic [31:0] BASE_MEMORY = 32'hFFFF_FFF4,
    parameter logic [31:0] TOP_MEMORY  = 32'hFFFF_FFF7, // 2048 bytes
    parameter int BAUD_DIVIDER = 3 // Example divider for 9600 baud rate with a 1 MHz clock
) (
    input  logic        clk,
    input  logic        reset,         // Added reset input
    input  logic [31:0] memAddress,
    input  logic [31:0] memWriteData,
    input  logic        memWrite,
    input  logic [3:0]  byteMask,
    output logic [31:0] memReadData,
    output logic uart_tx,
    input  logic uart_rx
);
////////////////////////////////////////////////// MEMORY STUFF ///////////////////////////////////////////////
    //hFFFF_FFF4 - Control
    //hFFFF_FFF5 - WriteData
    //hFFFF_FFF6 - ReadData
    //hFFFF_FFF7 - Status
    // Status = unused, unused, unused, unused, unused, unused, unused, tx_busy
    // Control = unused, unused, unused, unused, 3{clock divider} , write
    logic [7:0] control, writeData, readData, status;

    // Register for reading. Since this is sequential
    logic [31:0] readDataOut;

    assign memReadData = readDataOut;

    // Combined sequential write and read to the registers
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            control <= 8'h00;
            writeData <= 8'h00;
            readData <= 8'h00;
            status <= 8'h00;
            readDataOut <= 32'h0000_0000;
        end else begin
            if (memAddress >= BASE_MEMORY && memAddress <= TOP_MEMORY) begin
                if (memWrite) begin
                    //if (byteMask[0]) status <= memWriteData[7:0];       // Read only
                    //if (byteMask[1]) readData <= memWriteData[15:8];    // Read only
                    if (byteMask[2]) writeData <= memWriteData[23:16]; 
                    if (byteMask[3]) control <= memWriteData[31:24];   // We store information left to right
                end
                readDataOut[7:0]   <= status;
                readDataOut[15:8]  <= readData;
                readDataOut[23:16] <= writeData;
                readDataOut[31:24] <= control;
            end else begin
                readDataOut <= 32'hzzzz_zzzz; // Default value if address is out of range
            end
            //// UART STUFF ////
            // Also update control back to zero, after starting transmitting
            // We can only update it again if idle, while not, keep on making it 0
            if (current_state != IDLE) begin
                control <= 8'b00000000;
            end
            // Update status. tx_busy if not idle
            if (current_state == IDLE) begin
                status <= 8'b00000000; // tx_busy
            end else begin
                status <= 8'b11111111; // tx_busy
            end
        end
    end

////////////////////////////////////////////// UART STUFF ///////////////////////////////////////////////
    // Clock divider
    logic [15:0] clk_div_counter;
    logic baud_clk;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div_counter <= 0;
            baud_clk <= 0;
        end else begin
            if (clk_div_counter == BAUD_DIVIDER - 1) begin
                clk_div_counter <= 0;
                baud_clk <= ~baud_clk;
            end else begin
                clk_div_counter <= clk_div_counter + 1;
            end
        end
    end

    // Transmitter
    // States
    typedef enum logic [3:0] {
        IDLE = 4'b0000,
        START = 4'b0001,
        D1 = 4'b0010,
        D2 = 4'b0011,
        D3 = 4'b0100,
        D4 = 4'b0101,
        D5 = 4'b0110,
        D6 = 4'b0111,
        D7 = 4'b1000,
        D8 = 4'b1001,
        STOP = 4'b1010
    } state_t;

    state_t current_state, next_state;

    //// Update State Registers
    //always_ff @(posedge clk or posedge reset) begin
    //    // Update status. tx_busy if not idle
    //    if (current_state == IDLE) begin
    //        status <= 8'b00000000; // tx_busy
    //    end else begin
    //        status <= 8'b11111111; // tx_busy
    //    end
    //end

    // Update State Registers
    always_ff @(posedge baud_clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    logic start;
    assign start = control[0];
    always_comb begin 
        case (current_state)
            IDLE: begin
                if (start) begin // First bit indicates if we want to send data
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end
            START: next_state = D1;
            D1: next_state = D2;
            D2: next_state = D3;
            D3: next_state = D4;
            D4: next_state = D5;
            D5: next_state = D6;
            D6: next_state = D7;
            D7: next_state = D8;
            D8: next_state = STOP;
            STOP: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    logic first_bit, second_bit, third_bit, fourth_bit, fifth_bit, sixth_bit, seventh_bit, eighth_bit; // For the simulator
    assign {first_bit, second_bit, third_bit, fourth_bit, fifth_bit, sixth_bit, seventh_bit, eighth_bit} = writeData;
    always_comb begin
        case (current_state)
            IDLE: uart_tx = 1'b1;
            START: uart_tx = 1'b0;
            D1: uart_tx = first_bit;
            D2: uart_tx = second_bit;
            D3: uart_tx = third_bit;
            D4: uart_tx = fourth_bit;
            D5: uart_tx = fifth_bit;
            D6: uart_tx = sixth_bit;
            D7: uart_tx = seventh_bit;
            D8: uart_tx = eighth_bit;
            STOP: uart_tx = 1'b1;
            default: uart_tx = 1'b1;
        endcase
    end
    
endmodule