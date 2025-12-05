/*
  memory.v - Simple synchronous memory module
  Supports read/write operations with configurable size
*/
module memory #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE = 256
)(
    input wire clk,
    input wire rst,
    input wire mem_we,
    input wire mem_en,
    input wire [ADDR_WIDTH-1:0] mem_addr,
    input wire [DATA_WIDTH-1:0] mem_wdata,
    output reg [DATA_WIDTH-1:0] mem_rdata
);
    
    // Memory array declaration
    reg [DATA_WIDTH-1:0] mem_array [0:MEM_SIZE-1];
    
    // Memory initialization (optional)
    integer i;
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem_array[i] = {DATA_WIDTH{1'b0}};
        end
    end
    
    // Reset logic
    always @(posedge clk) begin
        if (rst) begin
            // Initialize memory to zero on reset
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                mem_array[i] <= {DATA_WIDTH{1'b0}};
            end
            mem_rdata <= {DATA_WIDTH{1'b0}};
        end
    end
    
    // Memory write operation
    always @(posedge clk) begin
        if (mem_en && mem_we && !rst) begin
            if ($unsigned(mem_addr) < MEM_SIZE) begin
                mem_array[mem_addr] <= mem_wdata;
            end
        end
    end
    
    // Memory read operation (synchronous)
    always @(posedge clk) begin
        if (rst) begin
            mem_rdata <= {DATA_WIDTH{1'b0}};
        end else if (mem_en && !mem_we) begin
            if ($unsigned(mem_addr) < MEM_SIZE) begin
                mem_rdata <= mem_array[mem_addr];
            end else begin
                mem_rdata <= {DATA_WIDTH{1'b0}};
            end
        end
    end
    
endmodule
