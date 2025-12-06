`timescale 1ns/1ps

module tb;
    // Test signals
    reg clk = 0;
    reg rst_n = 0;          // Changed from 'rst' to 'rst_n' (active low)
    reg ena = 1;            // Added: enable signal
    reg [7:0] ui_in = 0;    // Changed: full 8-bit input
    reg [7:0] uio_in = 0;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // DUT instantiation - ALL SIGNALS INCLUDED
    tt_um_aksp_mbist_mbisr dut (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),      // MUST BE CONNECTED
        .clk     (clk),
        .rst_n   (rst_n)     // Active low reset
    );
    
    // Clock generation (10ns period = 100MHz)
    always #5 clk = ~clk;
    
    // Debug signals - FIXED: Use correct hierarchy
    wire done = uo_out[0];
    wire fail = uo_out[1];
    // Note: Direct hierarchical access may not work in all simulators
    // Remove these if they cause issues:
    // wire [2:0] mbist_state = dut.u_top.u_mbist.state;
    // wire [4:0] mbist_addr = dut.u_top.u_mbist.addr;
    
    integer cycle = 0;
    
    // Debug display
    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (cycle < 500) begin  // Increased to 500 cycles
            $display("[CYCLE %0d] done=%b, fail=%b, ui_in=%b",
                     cycle, done, fail, ui_in);
        end
    end
    
    initial begin
        // FST format (more efficient)
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        
        $display("=== STARTING MBIST/MBISR TEST ===");
        
        // Initial reset
        #100;
        rst_n = 1;          // Release reset (active low)
        #200;
        
        $display("\n=== Starting MBIST ===");
        ui_in[0] = 1'b1;    // Start signal on bit 0
        @(posedge clk);
        ui_in[0] = 1'b0;
        
        // Wait for completion with timeout
        fork
            begin: completion_wait
                wait (done == 1'b1);
                $display("\n✅ SUCCESS: MBIST completed!");
                $display("   Fail flag: %b", fail);
                #100;
                $finish;
            end
            
            begin: timeout_check
                #2000000;  // 2ms timeout (200,000 cycles at 100MHz)
                $display("\n❌ TIMEOUT: MBIST stuck!");
                $display("   Done: %b, Fail: %b", done, fail);
                $display("   Simulation time: %0d ns", $time);
                $finish;
            end
        join
    end
endmodule
