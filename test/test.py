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

    # ✅ Correct signal path
    dut.dut.rst_n.value = 0
    dut.dut.ui_in.value = 0
    await Timer(100, unit="ns")

    dut.dut.rst_n.value = 1
    await Timer(100, unit="ns")

    # ✅ Start MBIST correctly
    dut.dut.ui_in.value = 0x01
    await RisingEdge(dut.clk)
    dut.dut.ui_in.value = 0x00

    # ✅ Wait for DONE
    for i in range(50000):
        await RisingEdge(dut.clk)
        if int(dut.dut.uo_out.value) & 0x01:
            dut._log.info("MBIST DONE")
            return

    assert False, "Timeout waiting for DONE"

