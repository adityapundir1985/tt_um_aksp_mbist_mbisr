`timescale 1ns/1ps

module tb;

  reg clk = 0;
  reg rst_n = 0;
  reg ena = 1;

  reg [7:0] ui_in = 8'b0;
  reg [7:0] uio_in = 8'b0;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Clock
  always #5 clk = ~clk;

  // DUT
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

  // Waveform
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
  end

  // REMOVE automatic $finish
  initial begin
    rst_n = 0;
    #100;
    rst_n = 1;
  end

endmodule
