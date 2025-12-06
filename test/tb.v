`timescale 1ns/1ps

module tb;
    // Test signals
    reg clk = 0;
    reg rst_n = 0;          // Active low reset
    reg ena = 1;
    reg [7:0] ui_in = 0;
    reg [7:0] uio_in = 0;
    
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // DUT instantiation
    tt_um_aksp_mbist_mbisr dut (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)
    );

    // Clock generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    // Debug aliases
    wire done = uo_out[0];
    wire fail = uo_out[1];

    integer cycle = 0;

    // Debug display
    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (cycle < 500) begin
            $display("[CYCLE %0d] done=%b, fail=%b, ui_in=%b",
                     cycle, done, fail, ui_in);
        end
    end

    initial begin
        // Waveform dump
        $dumpfile("tb.fst");
        $dumpvars(0, tb);

        $display("=== STARTING MBIST/MBISR TEST ===");

        // Apply reset
        #100;
        rst_n = 1;      // Release reset
        #200;

        $display("\n=== Starting MBIST ===");
        ui_in[0] = 1'b1;    // Pulse start
        @(posedge clk);
        ui_in[0] = 1'b0;

        // IMPORTANT:
        // Let cocotb control the end of simulation.
        // Do NOT call $finish here.
        #5_000_000;
    end

endmodule
