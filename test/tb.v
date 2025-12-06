`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a FST file
  initial begin
     // FST format (efficient)
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    
    // VCD format (compatible)
    //$dumpfile("tb.vcd");
    //$dumpvars(0, tb);
    #1;
  end

  // Test signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Clock generation
  always #5 clk = ~clk;

  // DUT instantiation
  tt_um_aksp_mbist_mbisr dut (
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  // Your test sequence here (from tt_um_aksp_mbist_mbisr_tb.v)
  initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    ena = 1;
    ui_in = 8'h00;
    uio_in = 8'h00;
    
    // Release reset
    #100 rst_n = 1;
    
    // Wait
    #1000;
    
    // Start MBIST
    $display("[%0t] Starting MBIST...", $time);
    ui_in[0] = 1'b1;
    #100 ui_in[0] = 1'b0;
    
    // Monitor with timeout
    fork
      begin
        wait (uo_out[0] === 1'b1);
        $display("[%0t] MBIST completed", $time);
        if (uo_out[1] === 1'b1) begin
          $display("[%0t] FAIL: Memory faults", $time);
        end else begin
          $display("[%0t] PASS: Memory OK", $time);
        end
        #100;
        $finish;
      end
      
      begin
        #5000000;
        $display("[%0t] TIMEOUT: done=%b, fail=%b", $time, uo_out[0], uo_out[1]);
        $finish;
      end
    join
  end

endmodule