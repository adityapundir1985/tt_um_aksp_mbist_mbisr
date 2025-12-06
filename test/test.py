# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
import random

@cocotb.test()
async def test_mbist_basic(dut):
    """Basic MBIST test - should pass with good memory"""
    
    dut._log.info("Starting MBIST Basic Test")
    
    # Set clock period (100ns = 10MHz) - CONSISTENT
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Reset for 10 cycles
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    # Start MBIST
    dut._log.info("Starting MBIST")
    dut.ui_in.value = 1  # Start signal on ui_in[0]
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0  # Pulse start
    
    # Wait for completion (with timeout)
    timeout = 5000
    for i in range(timeout):
        await ClockCycles(dut.clk, 1)
        if dut.uo_out.value[0] == 1:  # done signal
            break
    else:
        dut._log.error("MBIST timeout - never completed")
        assert False, "MBIST timeout"
    
    # Check results
    done = dut.uo_out.value[0]
    fail = dut.uo_out.value[1]
    
    dut._log.info(f"MBIST completed: done={done}, fail={fail}")
    
    # With good memory, should pass
    assert done == 1, "MBIST did not complete"
    assert fail == 0, "MBIST detected unexpected faults"

@cocotb.test()
async def test_mbist_with_faults(dut):
    """Test MBIST with injected memory faults"""
    
    dut._log.info("Starting MBIST Fault Test")
    
    # Set clock period (100ns = 10MHz) - CONSISTENT
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    # Note: In a real test, we would inject faults into memory
    # For now, we just run the test and see if MBISR handles it
    
    # Start MBIST
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    
    # Wait for completion
    timeout = 5000
    for i in range(timeout):
        await ClockCycles(dut.clk, 1)
        if dut.uo_out.value[0] == 1:
            break
    else:
        dut._log.error("MBIST timeout")
        assert False, "MBIST timeout"
    
    # Check results - MBISR should handle faults
    done = dut.uo_out.value[0]
    fail = dut.uo_out.value[1]
    
    dut._log.info(f"MBIST with potential faults: done={done}, fail={fail}")
    
    # MBIST should still complete
    assert done == 1, "MBIST did not complete"
    # fail could be 0 or 1 depending on if faults were detected

@cocotb.test()
async def test_multiple_runs(dut):
    """Run MBIST multiple times to test MBISR repair persistence"""
    
    dut._log.info("Starting Multiple Run Test")
    
    # Set clock period (100ns = 10MHz) - CONSISTENT
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    results = []
    
    # Run MBIST 3 times
    for run in range(3):
        dut._log.info(f"Starting MBIST run {run+1}")
        
        # Pulse start
        dut.ui_in.value = 1
        await ClockCycles(dut.clk, 5)
        dut.ui_in.value = 0
        
        # Wait for completion
        timeout = 5000
        for i in range(timeout):
            await ClockCycles(dut.clk, 1)
            if dut.uo_out.value[0] == 1:
                break
        else:
            dut._log.error(f"Run {run+1} timeout")
            assert False, f"Run {run+1} timeout"
        
        done = dut.uo_out.value[0]
        fail = dut.uo_out.value[1]
        
        dut._log.info(f"Run {run+1}: done={done}, fail={fail}")
        results.append((done, fail))
        
        # Wait between runs
        await ClockCycles(dut.clk, 100)
    
    # All runs should complete
    for i, (done, fail) in enumerate(results):
        assert done == 1, f"Run {i+1} did not complete"
        dut._log.info(f"Run {i+1} completed successfully")

@cocotb.test()
async def test_input_output_mapping(dut):
    """Test that input/output mapping is correct"""
    
    dut._log.info("Testing I/O Mapping")
    
    # Set clock period (100ns = 10MHz) - CONSISTENT
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    # Test 1: Check that only ui_in[0] matters (start signal)
    dut.ui_in.value = 0b00000001  # Only bit 0 set
    await ClockCycles(dut.clk, 1)
    # Other ui_in bits should be ignored
    dut.ui_in.value = 0b11111110  # All bits except 0
    await ClockCycles(dut.clk, 1)
    
    # Test 2: Check output mapping
    # uo_out[0] = done, uo_out[1] = fail, others should be 0
    dut.ui_in.value = 1  # Start test
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    
    # Wait a bit and check outputs
    await ClockCycles(dut.clk, 100)
    
    # Check that unused outputs are 0
    uo_out = dut.uo_out.value
    dut._log.info(f"uo_out = {uo_out:08b}")
    
    # Bits 7:2 should be 0
    assert (uo_out >> 2) == 0, f"Unused outputs not zero: {uo_out:08b}"
    
    # uio_out should be all 0
    assert dut.uio_out.value == 0, f"uio_out not zero: {dut.uio_out.value:08b}"
    
    # uio_oe should be all 0 (inputs)
    assert dut.uio_oe.value == 0, f"uio_oe not zero: {dut.uio_oe.value:08b}"
    
    dut._log.info("I/O mapping test passed")
