module test_SOC_new;

    // Inputs
    logic reset;
    logic clk;

    // Outputs
    logic ledr_n, ledg_n;

    // Instantiate the SOC module
    SOC uut (
        .reset(reset),
        .ledr_n(ledr_n),
        .ledg_n(ledg_n),
        .clk(clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;  // Generate clock signal with period 10 time units
        end
    end

    // Test reset signal
    initial begin
        reset = 1;
        #10;
       reset = 0;
    end

    // Monitor outputs
    initial begin
        $monitor("AtZ time %t, reset = %0b, ledr_n = %0b, ledg_n = %0b", $time, reset, ledr_n, ledg_n);
    end

    // Waveform dump
    initial begin
        $dumpfile("waveform_new.vcd");
        $dumpvars(0, test_SOC_new);
    end

endmodule