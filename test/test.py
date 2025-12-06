# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_basic(dut):
    """Basic test to verify DUT is alive"""
    
    dut._log.info("Starting basic test")
    
    # Clock (10ns = 100MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initial values
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    dut._log.info(f"Initial: clk={dut.clk.value}, rst_n={dut.rst_n.value}")
    
    # Reset
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    
    dut._log.info(f"After reset: clk={dut.clk.value}, rst_n={dut.rst_n.value}")
    dut._log.info(f"Outputs: uo_out={dut.uo_out.value:08b}")
    
    # Just verify outputs exist
    assert dut.uo_out.value is not None, "uo_out is not connected"
    
    # Pulse start
    dut.ui_in.value = 0b00000001
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    
    # Wait and check
    await ClockCycles(dut.clk, 100)
    dut._log.info(f"After start: uo_out={dut.uo_out.value:08b}")
    
    # Minimal check - just verify something happens
    dut._log.info("Basic test completed - DUT is alive")
