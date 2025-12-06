/*
 mbisr_controller.v - Verilog-2001 CAM-style multiple repair entries.
 Remaps user_addr -> spare region when match detected.
*/
module mbisr_controller #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 8,
    parameter MAX_REPAIRS = 2,
    parameter SPARE_BASE = 5'h1E
)(
    input clk,
    input rst,
    input bist_fail_valid,
    input [ADDR_WIDTH-1:0] bist_fail_addr,
    input [ADDR_WIDTH-1:0] user_addr,
    input [DATA_WIDTH-1:0] user_wdata,
    input user_we,
    input user_en,
    output [DATA_WIDTH-1:0] user_rdata,
    output [ADDR_WIDTH-1:0] mem_addr,
    output [DATA_WIDTH-1:0] mem_wdata,
    output mem_we,
    output mem_en,
    input [DATA_WIDTH-1:0] mem_rdata
);
    reg [ADDR_WIDTH-1:0] repair_table [0:MAX_REPAIRS-1];
    reg repair_valid [0:MAX_REPAIRS-1];
    integer i, j;
    initial begin
        for (i=0;i<MAX_REPAIRS;i=i+1) begin
            repair_table[i] = {ADDR_WIDTH{1'b1}};
            repair_valid[i] = 1'b0;
        end
    end

    reg inserted;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<MAX_REPAIRS;i=i+1) begin
                repair_table[i] <= {ADDR_WIDTH{1'b1}};
                repair_valid[i] <= 1'b0;
            end
            inserted <= 1'b0;
        end else begin
            if (bist_fail_valid) begin
                inserted <= 1'b0;
                for (j=0;j<MAX_REPAIRS;j=j+1) begin
                    if (repair_valid[j] && repair_table[j] == bist_fail_addr) begin
                        inserted <= 1'b1;
                    end
                end
                if (!inserted) begin
                    for (j=0;j<MAX_REPAIRS;j=j+1) begin
                        if (!repair_valid[j] && !inserted) begin
                            repair_table[j] <= bist_fail_addr;
                            repair_valid[j] <= 1'b1;
                            inserted <= 1'b1;
                        end
                    end
                end
            end
        end
    end

    reg [ADDR_WIDTH-1:0] remap_addr;
    integer k;
    always @(*) begin
        remap_addr = user_addr;
        for (k=0;k<MAX_REPAIRS;k=k+1) begin
            if (repair_valid[k] && repair_table[k] == user_addr) begin
                remap_addr = SPARE_BASE + k[ADDR_WIDTH-1:0];
            end
        end
    end

    assign mem_addr = remap_addr;
    assign mem_wdata = user_wdata;
    assign mem_we = user_we;
    assign mem_en = user_en;
    assign user_rdata = mem_rdata;

endmodule
