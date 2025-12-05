/*
 mbist_marchc_controller.v
 Verilog-2001: March C- variant (simplified) MBIST controller
 Reports per-address failure via fail_valid & fail_addr
*/
module mbist_marchc_controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input start,
    output reg busy,
    output reg done,
    output reg fail,
    output reg fail_valid,
    output reg [ADDR_WIDTH-1:0] fail_addr,

    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_wdata,
    input [DATA_WIDTH-1:0] mem_rdata
);
    
    // State definitions
    localparam STATE_IDLE    = 3'd0;
    localparam STATE_WR0_ASC = 3'd1;
    localparam STATE_R0W1_ASC = 3'd2;
    localparam STATE_R1W0_DESC = 3'd3;
    localparam STATE_R0_ASC   = 3'd4;
    localparam STATE_DONE     = 3'd5;
    
    reg [2:0] state;
    reg [ADDR_WIDTH-1:0] addr;
    
    // Maximum address value
    localparam MAX_ADDR = {(ADDR_WIDTH){1'b1}};
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            addr <= {ADDR_WIDTH{1'b0}};
            busy <= 1'b0;
            done <= 1'b0;
            fail <= 1'b0;
            fail_valid <= 1'b0;
            mem_we <= 1'b0;
            mem_addr <= {ADDR_WIDTH{1'b0}};
            mem_wdata <= {DATA_WIDTH{1'b0}};
        end else begin
            fail_valid <= 1'b0;  // Pulse for one cycle
            
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                    busy <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        addr <= {ADDR_WIDTH{1'b0}};
                        state <= STATE_WR0_ASC;
                        fail <= 1'b0;
                    end
                end
                
                STATE_WR0_ASC: begin
                    // Write 0 ascending
                    mem_we <= 1'b1;
                    mem_addr <= addr;
                    mem_wdata <= {DATA_WIDTH{1'b0}};
                    
                    if (addr == MAX_ADDR) begin
                        addr <= MAX_ADDR;
                        state <= STATE_R0W1_ASC;
                    end else begin
                        addr <= addr + 1;
                    end
                end
                
                STATE_R0W1_ASC: begin
                    // Read 0, then write 1 ascending
                    mem_we <= 1'b0;
                    mem_addr <= addr;
                    
                    // Check for failure
                    if (mem_rdata !== {DATA_WIDTH{1'b0}}) begin
                        fail <= 1'b1;
                        fail_valid <= 1'b1;
                        fail_addr <= addr;
                    end
                    
                    // Write 1 at same address
                    mem_we <= 1'b1;
                    mem_addr <= addr;
                    mem_wdata <= {DATA_WIDTH{1'b1}};
                    
                    if (addr == {ADDR_WIDTH{1'b0}}) begin
                        addr <= {ADDR_WIDTH{1'b0}};
                        state <= STATE_R1W0_DESC;
                    end else begin
                        addr <= addr - 1;
                    end
                end
                
                STATE_R1W0_DESC: begin
                    // Read 1, then write 0 descending
                    mem_we <= 1'b0;
                    mem_addr <= addr;
                    
                    // Check for failure
                    if (mem_rdata !== {DATA_WIDTH{1'b1}}) begin
                        fail <= 1'b1;
                        fail_valid <= 1'b1;
                        fail_addr <= addr;
                    end
                    
                    // Write 0
                    mem_we <= 1'b1;
                    mem_addr <= addr;
                    mem_wdata <= {DATA_WIDTH{1'b0}};
                    
                    if (addr == {ADDR_WIDTH{1'b0}}) begin
                        addr <= {ADDR_WIDTH{1'b0}};
                        state <= STATE_R0_ASC;
                    end else begin
                        addr <= addr - 1;
                    end
                end
                
                STATE_R0_ASC: begin
                    // Final read 0 ascending verification
                    mem_we <= 1'b0;
                    mem_addr <= addr;
                    
                    // Check for failure
                    if (mem_rdata !== {DATA_WIDTH{1'b0}}) begin
                        fail <= 1'b1;
                        fail_valid <= 1'b1;
                        fail_addr <= addr;
                    end
                    
                    if (addr == MAX_ADDR) begin
                        state <= STATE_DONE;
                    end else begin
                        addr <= addr + 1;
                    end
                end
                
                STATE_DONE: begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= STATE_IDLE;
                end
                
                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule