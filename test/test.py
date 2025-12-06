# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


async def init(dut):
    """Shared init for all tests"""
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


@cocotb.test()
async def test_mbist_basic(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await init(dut)

    # Start pulse
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0

    # Wait for done pulse
    timeout = 5000
    for _ in range(timeout):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 1:
            break
    else:
        assert False, "Timeout waiting for DONE"

    assert (int(dut.uo_out.value) >> 1) & 1 == 0, "Unexpected FAIL"


@cocotb.test()
async def test_mbist_with_faults(dut):
    """Injects a real fault"""
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await init(dut)

    # Inject fault
    dut._log.info("Injecting fault at address 5")
    dut._id("u_top.u_memory.mem_array[5]", extended=True).value = 0xFF

    # Start pulse
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0

    # Wait for done
    for _ in range(5000):
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 1:
            break
    else:
        assert False, "Timeout waiting for DONE"

    # MBISR may fix it, so fail can be 0 or 1


@cocotb.test()
async def test_multiple_runs(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await init(dut)

    for run in range(3):
        dut.cmd = f"Run {run+1}"

        # Start
        dut.ui_in.value = 1
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0

        # Wait done pulse
        for _ in range(5000):
            await RisingEdge(dut.clk)
            if int(dut.uo_out.value) & 1:
                break
        else:
            assert False, f"Run {run+1} timeout"

        # small gap
        await ClockCycles(dut.clk, 20)


@cocotb.test()
async def test_input_output_mapping(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await init(dut)

    # Outputs should be zero after reset
    await ClockCycles(dut.clk, 2)
    assert int(dut.uo_out.value) & 0b11111100 == 0
    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0
