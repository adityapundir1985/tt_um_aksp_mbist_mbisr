module mbist_marchc_controller #(
    parameter ADDR_WIDTH = 5,
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
    output reg mem_en,           // FIXED: mem_en output properly declared
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_wdata,
    input [DATA_WIDTH-1:0] mem_rdata
);
    
    // States for March C- algorithm with extra states for final writes
    localparam STATE_IDLE         = 4'd0;
    localparam STATE_WR0          = 4'd1;  // Write 0s to all addresses
    localparam STATE_WR0_FINAL    = 4'd2;  // Extra cycle for last write
    localparam STATE_R0_W1        = 4'd3;  // Read 0, Write 1 (ascending)
    localparam STATE_R0_W1_FINAL  = 4'd4;  // Extra cycle for last write
    localparam STATE_R1_W0        = 4'd5;  // Read 1, Write 0 (descending)
    localparam STATE_R1_W0_FINAL  = 4'd6;  // Extra cycle for last write
    localparam STATE_R0F          = 4'd7;  // Final read 0 (ascending)
    localparam STATE_DONE         = 4'd8;
    
    reg [3:0] state;
    reg [ADDR_WIDTH-1:0] addr;
    reg read_phase;
    reg [ADDR_WIDTH-1:0] read_addr;
    
    localparam MAX_ADDR = {(ADDR_WIDTH){1'b1}};
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            addr <= 0;
            busy <= 0;
            done <= 0;
            fail <= 0;
            fail_valid <= 0;
            mem_we <= 0;
            mem_en <= 0;           // FIXED: Initialize mem_en
            mem_addr <= 0;
            mem_wdata <= 0;
            read_phase <= 0;
            read_addr <= 0;
        end else begin
            fail_valid <= 0;
            mem_en <= 1;           // FIXED: Keep mem_en enabled during operation
            
            case (state)
                STATE_IDLE: begin
                    done <= 0;
                    busy <= 0;
                    mem_en <= 0;   // FIXED: Disable mem_en in idle
                    if (start) begin
                        state <= STATE_WR0;
                        addr <= 0;
                        busy <= 1;
                        mem_en <= 1;  // FIXED: Enable mem_en when starting
                        mem_we <= 1;
                        mem_wdata <= 0;
                    end
                end
                
                STATE_WR0: begin
                    mem_we <= 1;
                    mem_addr <= addr;
                    mem_wdata <= 0;
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    
                    if (addr == MAX_ADDR) begin
                        state <= STATE_WR0_FINAL;
                    end else begin
                        addr <= addr + 1;
                    end
                end
                
                STATE_WR0_FINAL: begin
                    // One more cycle to ensure write to address 31 completes
                    mem_we <= 1;
                    mem_addr <= MAX_ADDR;
                    mem_wdata <= 0;
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    
                    addr <= 0;
                    state <= STATE_R0_W1;
                    mem_we <= 0;
                    read_phase <= 0;
                    read_addr <= 0;
                end
                
                STATE_R0_W1: begin
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    if (read_phase == 0) begin
                        // Setup read
                        mem_we <= 0;
                        mem_addr <= addr;
                        read_addr <= addr;
                        read_phase <= 1;
                    end else begin
                        // Check read result
                        if (mem_rdata !== 0) begin
                            fail <= 1;
                            fail_valid <= 1;
                            fail_addr <= read_addr;
                        end
                        
                        // Write 1 to current address
                        mem_we <= 1;
                        mem_addr <= addr;
                        mem_wdata <= {DATA_WIDTH{1'b1}};
                        read_phase <= 0;
                        
                        if (addr == MAX_ADDR) begin
                            state <= STATE_R0_W1_FINAL;
                        end else begin
                            addr <= addr + 1;
                        end
                    end
                end
                
                STATE_R0_W1_FINAL: begin
                    // One more cycle to ensure write to address 31 completes
                    mem_we <= 1;
                    mem_addr <= MAX_ADDR;
                    mem_wdata <= {DATA_WIDTH{1'b1}};
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    
                    addr <= MAX_ADDR;
                    state <= STATE_R1_W0;
                    mem_we <= 0;
                    read_phase <= 0;
                    read_addr <= MAX_ADDR;
                end
                
                STATE_R1_W0: begin
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    if (read_phase == 0) begin
                        // Setup read
                        mem_we <= 0;
                        mem_addr <= addr;
                        read_addr <= addr;
                        read_phase <= 1;
                    end else begin
                        // Check read result
                        if (mem_rdata !== {DATA_WIDTH{1'b1}}) begin
                            fail <= 1;
                            fail_valid <= 1;
                            fail_addr <= read_addr;
                        end
                        
                        // Write 0 to current address
                        mem_we <= 1;
                        mem_addr <= addr;
                        mem_wdata <= 0;
                        read_phase <= 0;
                        
                        if (addr == 0) begin
                            state <= STATE_R1_W0_FINAL;
                        end else begin
                            addr <= addr - 1;
                        end
                    end
                end
                
                STATE_R1_W0_FINAL: begin
                    // One more cycle to ensure write to address 0 completes
                    mem_we <= 1;
                    mem_addr <= 0;
                    mem_wdata <= 0;
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    
                    addr <= 0;
                    state <= STATE_R0F;
                    mem_we <= 0;
                    read_phase <= 0;
                    read_addr <= 0;
                end
                
                STATE_R0F: begin
                    mem_en <= 1;   // FIXED: Ensure mem_en is active
                    if (read_phase == 0) begin
                        // Setup read
                        mem_we <= 0;
                        mem_addr <= addr;
                        read_addr <= addr;
                        read_phase <= 1;
                    end else begin
                        // Check final read
                        if (mem_rdata !== 0) begin
                            fail <= 1;
                            fail_valid <= 1;
                            fail_addr <= read_addr;
                        end
                        read_phase <= 0;
                        
                        if (addr == MAX_ADDR) begin
                            state <= STATE_DONE;
                            mem_en <= 0;  // FIXED: Disable mem_en when done
                        end else begin
                            addr <= addr + 1;
                        end
                    end
                end
                
                STATE_DONE: begin
                    done <= 1;
                    busy <= 0;
                    mem_en <= 0;   // FIXED: Ensure mem_en is disabled
                    
                    if (!start) begin
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end
endmodule