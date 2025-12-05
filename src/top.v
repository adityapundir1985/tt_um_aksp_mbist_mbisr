/*
  top.v - MBIST with MBISR Integration
  Main module that integrates MBIST controller, MBISR controller, and memory
*/
module top(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    output wire        done,
    output wire        fail
);
    
    // ========== Parameter Declarations ==========
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter MEM_SIZE = 256;
    parameter MAX_REPAIRS = 16;
    parameter SPARE_BASE = 8'hF0;  // Spare region starts at 0xF0
    
    // ========== Wire Declarations ==========
    
    // MBIST controller signals
    wire                bist_busy;
    wire                bist_done;
    wire                bist_fail;
    wire                bist_fail_valid;
    wire [ADDR_WIDTH-1:0] bist_fail_addr;
    wire                bist_mem_we;
    wire [ADDR_WIDTH-1:0] bist_mem_addr;
    wire [DATA_WIDTH-1:0] bist_mem_wdata;
    wire [DATA_WIDTH-1:0] bist_mem_rdata;
    
    // MBISR controller signals
    wire [ADDR_WIDTH-1:0] mbisr_mem_addr;
    wire [DATA_WIDTH-1:0] mbisr_mem_wdata;
    wire                mbisr_mem_we;
    wire                mbisr_mem_en;
    wire [DATA_WIDTH-1:0] mbisr_mem_rdata;
    wire [DATA_WIDTH-1:0] user_rdata;  // Not used, but required by interface
    
    // Memory interface signals
    wire                mem_we;
    wire                mem_en;
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    
    // ========== Controller Instantiations ==========
    
    // MBIST Controller - March C- algorithm
    mbist_marchc_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mbist (
        .clk(clk),
        .rst(rst),
        .start(start),
        .busy(bist_busy),
        .done(bist_done),
        .fail(bist_fail),
        .fail_valid(bist_fail_valid),
        .fail_addr(bist_fail_addr),
        .mem_we(bist_mem_we),
        .mem_addr(bist_mem_addr),
        .mem_wdata(bist_mem_wdata),
        .mem_rdata(bist_mem_rdata)
    );
    
    // MBISR Controller - Memory repair logic
    mbisr_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_REPAIRS(MAX_REPAIRS),
        .SPARE_BASE(SPARE_BASE)
    ) u_mbisr (
        .clk(clk),
        .rst(rst),
        .bist_fail_valid(bist_fail_valid),
        .bist_fail_addr(bist_fail_addr),
        .user_addr(bist_mem_addr),
        .user_wdata(bist_mem_wdata),
        .user_we(bist_mem_we),
        .user_en(1'b1),  // Always enabled during BIST
        .user_rdata(user_rdata),  // Connected but not used
        .mem_addr(mbisr_mem_addr),
        .mem_wdata(mbisr_mem_wdata),
        .mem_we(mbisr_mem_we),
        .mem_en(mbisr_mem_en),
        .mem_rdata(mbisr_mem_rdata)
    );
    
    // Memory Module - Main memory array
    memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) u_memory (
        .clk(clk),
        .rst(rst),
        .mem_we(mbisr_mem_we),
        .mem_en(mbisr_mem_en),
        .mem_addr(mbisr_mem_addr),
        .mem_wdata(mbisr_mem_wdata),
        .mem_rdata(mbisr_mem_rdata)
    );
    
    // Connect MBIST memory read data
    assign bist_mem_rdata = mbisr_mem_rdata;
    
    // ========== Output Assignment ==========
    assign done = bist_done;
    assign fail = bist_fail;
    
endmodule
