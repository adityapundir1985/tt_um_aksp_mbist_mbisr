/*
  TinyTapeout wrapper: tt_um_aksp_mbist_mbisr
  Maps TinyTapeout standard pins to the user's top module.
  - ui_in[0] -> start
  - uo_out[0] -> done
  - uo_out[1] -> fail
  - rst = ~rst_n
  - ena is not used by user's top but accepted by interface
  - uio left as high-Z
*/
module tt_um_aksp_mbist_mbisr (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    inout  wire [7:0]  uio
);

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

    // leave uio as high-Z
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : UIO_Z
            assign uio[i] = 1'bz;
        end
    endgenerate

endmodule
