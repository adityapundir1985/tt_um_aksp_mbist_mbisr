`timescale 1ns/1ps

module tb;
    reg clk = 0;
    reg rst_n = 0;
    reg ena = 1;
    reg [7:0] ui_in = 0;
    reg [7:0] uio_in = 0;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

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

    always #5 clk = ~clk;  // 100 MHz

    wire done = uo_out[0];
    wire fail = uo_out[1];

    integer cycle = 0;

    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (cycle < 500) begin
            $display("[CYCLE %0d] done=%b, fail=%b, ui_in=%b",
                     cycle, done, fail, ui_in);
        end
    end

    initial begin
        // Dump waveforms
        $dumpfile("tb.fst");
        $dumpvars(0, tb);

        $display("=== STARTING MBIST/MBISR TEST ===");

        // Reset
        #100;
        rst_n = 1;
        #200;

        // Start MBIST
        $display("\n=== Starting MBIST ===");
        ui_in[0] = 1'b1;
        @(posedge clk);
        ui_in[0] = 1'b0;

        // Let cocotb decide when to finish
        #10_000_000;
    end

endmodule
