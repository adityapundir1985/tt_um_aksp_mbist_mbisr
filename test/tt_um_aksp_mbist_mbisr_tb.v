`timescale 1ns/1ps

module tt_um_aksp_mbist_mbisr_tb;
    
    // Testbench signals - match actual module interface
    reg clk = 0;
    always #5 clk = ~clk;  // 100 MHz clock
    
    reg rst_n = 0;
    reg ena = 1;
    
    // Individual pins (not buses)
    reg ui0, ui1, ui2, ui3, ui4, ui5, ui6, ui7;
    wire uo0, uo1, uo2, uo3, uo4, uo5, uo6, uo7;
    wire uio0, uio1, uio2, uio3, uio4, uio5, uio6, uio7;
    
    // Instantiate DUT with correct interface
    tt_um_aksp_mbist_mbisr dut (
        // Individual UI pins
        .ui0(ui0),
        .ui1(ui1),
        .ui2(ui2),
        .ui3(ui3),
        .ui4(ui4),
        .ui5(ui5),
        .ui6(ui6),
        .ui7(ui7),
        
        // Individual UO pins
        .uo0(uo0),
        .uo1(uo1),
        .uo2(uo2),
        .uo3(uo3),
        .uo4(uo4),
        .uo5(uo5),
        .uo6(uo6),
        .uo7(uo7),
        
        // Individual UIO pins
        .uio0(uio0),
        .uio1(uio1),
        .uio2(uio2),
        .uio3(uio3),
        .uio4(uio4),
        .uio5(uio5),
        .uio6(uio6),
        .uio7(uio7),
        
        // Control signals
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
        ui0 = 0;  // start signal
        ui1 = 0; ui2 = 0; ui3 = 0; ui4 = 0; ui5 = 0; ui6 = 0; ui7 = 0;
        
        // Release reset after 20ns
        #20 rst_n = 1;
        
        // Wait a bit
        #50;
        
        // Start MBIST by pulsing ui0
        $display("[%0t] Starting MBIST test...", $time);
        #20 ui0 = 1'b1;  // Pulse start
        #20 ui0 = 1'b0;
        
        // Monitor progress
        while (uo0 === 1'b0) begin
            #100;
            $display("[%0t] MBIST running... done=%b fail=%b", $time, uo0, uo1);
        end
        
        // Test complete
        #20;
        $display("[%0t] Test Complete: done=%b fail=%b", $time, uo0, uo1);
        
        if (uo1 === 1'b1) begin
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
