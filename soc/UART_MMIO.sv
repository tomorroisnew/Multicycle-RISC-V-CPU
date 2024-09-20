module UART_MMIO #(
    parameter logic [31:0] BASE_MEMORY = 32'hFFFF_FFF4,
    parameter logic [31:0] TOP_MEMORY  = 32'hFFFF_FFF7, // 2048 bytes
    parameter int BAUD_DIVIDER = 1200 // Example divider for 9600 baud rate with a 1 MHz clock
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
            if (current_state == STOP && control[0]) begin
                control <= 8'b00000000;  // Only clear the start bit after sending data
            end

            // Update status. tx_busy if not idle
            if (current_state != IDLE || control[0]) begin
                status <= 8'b11111111; // busy/starting to transmit
            end else begin
                status <= 8'b00000000; // tx_busy
            end
            //if (current_state == STOP && control[0]) begin
            //    control[0] <= 1'b0;  // Only clear the start bit after sending data
            //end
        end
    end

////////////////////////////////////////////// UART STUFF ///////////////////////////////////////////////
    // Clock divider
    logic baud_clk;

    //baud_rate_divider #(
    //    .SYSTEM_CLOCK_FREQ(6000000),  // 1 MHz
    //    .BAUD_RATE(1200)                // 9600 baud
    //) baud_rate_divider_inst (
    //    .clk(clk),
    //    .rst(reset),
    //    .baud_clk(baud_clk)
    //);

    // Instantiate baud rate generator with corrected parameters
    baud_rate_generator #(
        .SYS_CLK_FREQ(6000000), // For simulation: 10 Hz system clock
        .BAUD_RATE(1200)     // For simulation: 10 baud rate
    ) baud_gen (
        .clk(clk),         // Connect to the system clock
        .reset(reset),
        .baud_clk(baud_clk)
    );

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

    // Update State Registers
    //always_ff @(posedge baud_clk or posedge reset) begin
    //    if (reset) begin
    //        status <= 8'b00000000; // Reset status
    //    end else begin
    //        // Update status. tx_busy if not idle
    //        if (current_state == IDLE) begin
    //            status <= 8'b00000000; // tx_busy
    //        end else begin
    //            status <= 8'b11111111; // tx_busy
    //        end
    //        //if (current_state == STOP && control[0]) begin
    //        //    control[0] <= 1'b0;  // Only clear the start bit after sending data
    //        //end
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
    // LSB first
    assign {eighth_bit, seventh_bit, sixth_bit, fifth_bit, fourth_bit, third_bit, second_bit, first_bit} = writeData;
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

module baud_rate_divider #(
    parameter SYSTEM_CLOCK_FREQ = 6000000,    // System clock frequency: 6 MHz
    parameter BAUD_RATE = 1200                // Updated baud rate to 1200
)(
    input wire clk,        // System clock
    input wire rst,        // Reset signal
    output reg baud_clk    // Baud rate clock output
);

    // Calculate the number of system clock cycles needed to generate the baud rate
    localparam integer DIVISOR = SYSTEM_CLOCK_FREQ / (BAUD_RATE * 16);  // 16x oversampling
    
    reg [31:0] counter = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            baud_clk <= 0;
        end else if (counter >= DIVISOR - 1) begin
            counter <= 0;
            baud_clk <= ~baud_clk;  // Toggle the baud clock
        end else begin
            counter <= counter + 1;
        end
    end

endmodule

// Corrected baud_rate_generator Module
module baud_rate_generator #(
    parameter SYS_CLK_FREQ = 6000000, // System clock frequency in Hz (for simulation)
    parameter BAUD_RATE    = 1200  // Desired baud rate (for simulation)
)(
    input wire clk,            // System clock input
    input wire reset,          // Asynchronous reset
    output reg baud_clk        // Baud rate clock output
);

    // Calculate the number of system clock cycles per baud period
    localparam integer COUNT_MAX = SYS_CLK_FREQ / BAUD_RATE; // 10 / 10 = 1

    // Calculate the number of bits needed for the counter, ensuring at least 1 bit
    localparam integer COUNT_BITS = ($clog2(COUNT_MAX) > 0) ? $clog2(COUNT_MAX) : 1;

    // Counter to divide the system clock
    reg [COUNT_BITS-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter   <= 0;
            baud_clk  <= 0;
        end else begin
            if (COUNT_MAX > 1) begin
                if (counter >= (COUNT_MAX / 2 - 1)) begin
                    counter  <= 0;
                    baud_clk <= ~baud_clk; // Toggle baud clock
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                baud_clk <= ~baud_clk; // Toggle every clock cycle
            end
        end
    end

endmodule