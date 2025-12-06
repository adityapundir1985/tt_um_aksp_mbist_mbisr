# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_mbist_basic(dut):
    dut._log.info("Running MBIST basic test")

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(100, unit="ns")

    dut.rst_n.value = 1
    await Timer(100, unit="ns")

    # ✅ ACTUALLY START MBIST
    dut.ui_in.value = 0x01   # ui_in[0] = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0x00

    # ✅ Wait for DONE
    for i in range(20000):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x01:
            dut._log.info("MBIST DONE")
            return

    assert False, "Timeout waiting for DONE"
