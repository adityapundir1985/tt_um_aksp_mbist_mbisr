/*
  memory.v - Simple synchronous memory module
  Synthesis-safe version
*/
module memory #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE = 32
)(
    input wire clk,
    input wire rst,
    input wire mem_we,
    input wire mem_en,
    input wire [ADDR_WIDTH-1:0] mem_addr,
    input wire [DATA_WIDTH-1:0] mem_wdata,
    output reg [DATA_WIDTH-1:0] mem_rdata
);
    
    // Memory array
    reg [DATA_WIDTH-1:0] mem_array [0:MEM_SIZE-1];
    
    // Synchronous operations
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset
            for (integer i = 0; i < MEM_SIZE; i = i + 1) begin
                mem_array[i] <= 0;
            end
            mem_rdata <= 0;
        end else if (mem_en) begin
            if (mem_we) begin
                // Write operation
                if (mem_addr < MEM_SIZE) begin
                    mem_array[mem_addr] <= mem_wdata;
                end
            end else begin
                // Read operation
                if (mem_addr < MEM_SIZE) begin
                    mem_rdata <= mem_array[mem_addr];
                end else begin
                    mem_rdata <= 0;
                end
            end
        end
    end
endmodule