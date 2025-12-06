`timescale 1ns/1ps

module tb;  // Changed from debug_all to tb
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    wire [7:0] uo_out;
    
    tt_um_aksp_mbist_mbisr dut (
        .ui_in({7'b0, start}),
        .uo_out(uo_out),
        .uio_in(8'b0),
        .ena(1'b1),
        .clk(clk),
        .rst_n(~rst)
    );
    
    always #5 clk = ~clk;
    
    wire done = uo_out[0];
    wire fail = uo_out[1];
    wire [2:0] mbist_state = dut.u_top.u_mbist.state;
    wire [4:0] mbist_addr = dut.u_top.u_mbist.addr;
    
    integer cycle = 0;
    
    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (cycle < 200) begin
            $display("[CYCLE %0d] state=%0d, addr=%0d, done=%b, fail=%b, rdata=%h",
                     cycle, mbist_state, mbist_addr, done, fail, dut.u_top.u_mbist.mem_rdata);
        end
    end
    
    initial begin
        // FST format (more efficient)
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
        
        // VCD format (compatible)
        // $dumpfile("tb.vcd");
        // $dumpvars(0, tb);  // Now matches module name
        
        $display("=== STARTING DEBUG TEST ===");
        
        // Release reset with proper timing
        #100 rst = 0;
        #200;
        
        $display("\n=== Starting MBIST ===");
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion with timeout
        fork
            begin
                wait (done == 1'b1);
                $display("\n✅ SUCCESS: MBIST completed!");
                $display("   Fail flag: %b", fail);
                if (fail) begin
                    $display("   Failure address: %0d", dut.u_top.u_mbist.fail_addr);
                    // Show memory at failure address
                    $display("   Memory[%0d] = %h", 
                            dut.u_top.u_mbist.fail_addr,
                            dut.u_top.u_memory.mem_array[dut.u_top.u_mbist.fail_addr]);
                end
                #100;
                $finish;
            end
            
            begin
                #500000;  // 500us timeout (very generous)
                $display("\n❌ TIMEOUT: MBIST stuck!");
                $display("   State: %0d", mbist_state);
                $display("   Address: %0d", mbist_addr);
                $display("   Done: %b, Fail: %b", done, fail);
                $finish;
            end
        join
    end
endmodule