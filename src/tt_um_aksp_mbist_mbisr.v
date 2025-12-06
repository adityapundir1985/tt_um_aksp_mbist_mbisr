/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/*
  TinyTapeout wrapper: tt_um_aksp_mbist_mbisr
  Maps TinyTapeout standard pins to the user's top module.
  - ui_in[0] -> start
  - uo_out[0] -> done
  - uo_out[1] -> fail
  - rst = ~rst_n
  - ena is not used by user's top but accepted by interface
  - uio left as inputs (high-Z)
*/

/* verilator lint_off UNUSEDSIGNAL */
module tt_um_aksp_mbist_mbisr (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
/* verilator lint_on UNUSEDSIGNAL */

    // translate reset and start
    wire rst = ~rst_n;
    wire start = ui_in[0];

    wire done;
    wire fail;

    // instantiate user's top (keeps original logic)
    top u_top (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .fail(fail)
    );

    // map outputs
    assign uo_out[0] = done;
    assign uo_out[1] = fail;
    assign uo_out[7:2] = 6'b0;

    // leave uio as inputs (high-Z)
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;  // All uio pins as inputs (0=input mode)

    // List all unused inputs to prevent warnings
    wire [7:0] _unused_ui_in = ui_in[7:1];
    wire [7:0] _unused_uio_in = uio_in;
    wire _unused_ena = ena;
    wire _unused_clk = clk;
    wire _unused_rst_n = rst_n;

endmodule