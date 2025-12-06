# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_mbist_basic(dut):
    dut._log.info("Running MBIST basic test")

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await Timer(100, units="ns")
    dut.rst_n.value = 1

    # Start test
    await Timer(100, units="ns")
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0

    # Wait for DONE
    for _ in range(1000):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 0x01:
            break
    else:
        assert False, "Timeout waiting for DONE"

    fail = (int(dut.uo_out.value) >> 1) & 1
    assert fail == 0, "Fail flag was set"


@cocotb.test()
async def test_io_mapping(dut):
    dut._log.info("Checking wrapper mapping")

    assert len(dut.ui_in) == 8
    assert len(dut.uo_out) == 8
    assert len(dut.uio_in) == 8


@cocotb.test()
async def test_multiple_runs(dut):
    dut._log.info("Running multiple MBIST runs")

    for _ in range(2):
        dut.ui_in.value = 1
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0

        for _ in range(2000):
            await RisingEdge(dut.clk)
            if int(dut.uo_out.value) & 1:
                break
        else:
            assert False, "Timeout waiting for DONE"

        fail = (int(dut.uo_out.value) >> 1) & 1
        assert fail == 0
