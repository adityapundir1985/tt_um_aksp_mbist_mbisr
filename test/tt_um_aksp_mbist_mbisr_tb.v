`timescale 1ns/1ps
module tt_um_aksp_mbist_mbisr_tb;
    
    // Testbench signals
    reg clk = 0;
    always #5 clk = ~clk;  // 100 MHz clock
    
    reg rst_n = 0;
    reg ena = 1;
    reg [7:0] ui_in = 8'h00;
    reg [7:0] uio_in = 8'h00;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Instantiate DUT with new interface
    tt_um_aksp_mbist_mbisr dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Waveform dump
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tt_um_aksp_mbist_mbisr_tb);
    end
    
    // Test sequence
    initial begin
        // Initial state
        rst_n = 0;
        ui_in = 8'h00;
        uio_in = 8'h00;
        
        // Release reset after 20ns
        #20 rst_n = 1;
        
        // Wait a bit
        #50;
        
        // Start MBIST by pulsing ui_in[0]
        $display("[%0t] Starting MBIST test...", $time);
        #20 ui_in[0] = 1'b1;
        #20 ui_in[0] = 1'b0;
        
        // Monitor progress
        while (uo_out[0] === 1'b0) begin
            #100;
            $display("[%0t] MBIST running... done=%b fail=%b", $time, uo_out[0], uo_out[1]);
        end
        
        // Test complete
        #20;
        $display("[%0t] Test Complete: done=%b fail=%b", $time, uo_out[0], uo_out[1]);
        
        if (uo_out[1] === 1'b1) begin
            $display("[%0t] FAIL: Memory test detected failures", $time);
        end else begin
            $display("[%0t] PASS: Memory test completed successfully", $time);
        end
        
        #100;
        $finish;
    end
    
    // Timeout protection
    initial begin
        #1000000;  // 1ms timeout
        $display("[%0t] ERROR: Test timeout!", $time);
        $finish;
    end
    
endmodule
