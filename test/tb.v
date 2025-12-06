`timescale 1ns/1ps

module tb;

    // Clock and reset
    reg  clk;
    reg  rst_n;
    reg  ena;

    // TinyTapeout IOs
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    integer cycle;

    // Instantiate DUT (TinyTapeout wrapper)
    tt_um_aksp_mbist_mbisr dut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // 100MHz clock -> 10ns period
    always #5 clk = ~clk;

    initial begin
        // Waveforms
        $dumpfile("tb.fst");
        $dumpvars(0, tb);

        // Init
        clk    = 0;
        rst_n  = 0;
        ena    = 0;
        ui_in  = 8'b0;
        uio_in = 8'b0;
        cycle  = 0;

        $display("=== STARTING MBIST/MBISR TEST ===");

        // Hold reset
        repeat(5) @(posedge clk);

        // Enable design
        ena = 1;

        // Release reset
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Start pulse
        ui_in[0] = 1'b1;
        @(posedge clk);
        ui_in[0] = 1'b0;

        $display("=== Starting MBIST ===");

        // Wait for DONE or timeout
        while (uo_out[0] !== 1'b1 && cycle < 20000) begin
            @(posedge clk);
            cycle = cycle + 1;
            $display("[CYCLE %0d] done=%b, fail=%b, ui_in=%b",
                     cycle, uo_out[0], uo_out[1], ui_in);
        end

        if (uo_out[0] === 1'b1) begin
            $display("✅ SUCCESS: MBIST completed!");
            $display("   Fail flag: %b", uo_out[1]);
        end else begin
            $display("❌ ERROR: Timeout waiting for DONE");
        end

        #100;
        $finish;
    end

endmodule
