Testbench for MBIST + MBISR Project

This document describes the simulation and verification flow for the MBIST (Memory Built-In Self-Test) and MBISR (Memory Built-In Self-Repair) system integrated inside the TinyTapeout wrapper.

Project Overview

The design implements:

March C- memory test algorithm

256×8 embedded SRAM with spare address region

CAM-based repair table supporting up to 16 faulty addresses

Automatic faulty address remapping to spare memory (0xF0–0xFF)

The testbench verifies:

MBIST state machine execution

Memory read/write correctness

Fault detection and reporting

MBISR repair remapping

Wrapper I/O mapping (start, done, fail)

File Structure

Location: test/

File	Description
tt_um_aksp_mbist_mbisr_tb.v	Main Verilog testbench
Makefile	Simulation automation (RTL, gate-level)
test.py	cocotb test suite (optional)

Verilog Source Files Included in Simulation

src/mbist_marchc_controller.v

src/mbisr_controller.v

src/memory.v

src/top.v

src/tt_um_aksp_mbist_mbisr.v

Running Simulations
RTL Simulation (default)
cd test
make -B


This generates waveform: tb.fst.

Gate-Level Simulation (after GDS synthesis)

Ensure the GDS workflow has produced the gate-level netlist.

cd test
make -B GATES=yes

Optional: Generate VCD Waveform Instead of FST

Edit tb.v:

$dumpfile("tb.vcd");


Then run:

cd test
make -B FST=

Test Scenarios

The cocotb file test.py supports:

Basic MBIST test — no faults injected

MBIST with faults — validates MBISR repair

Multiple test runs — verifies persistent repair mapping

I/O mapping test — checks wrapper pin assignments

Viewing Waveforms
GTKWave
gtkwave tb.fst

Surfer
surfer tb.fst

Important Signals to Monitor
MBIST Controller

u_top.u_mbist.state

u_top.u_mbist.mem_addr

u_top.u_mbist.mem_rdata

u_top.u_mbist.mem_wdata

u_top.u_mbist.mem_we

MBISR Repair Logic

u_top.u_mbisr.remap_addr

CAM table contents (if exposed)

Wrapper Outputs

uo_out[0] → done

uo_out[1] → fail

Expected Test Duration

March C- on a 256-depth memory performs:

Step	Description	Operations
1	Write 0 (ascending)	256
2	Read 0 → Write 1 (ascending)	512
3	Read 1 → Write 0 (descending)	512
4	Read 0 (ascending)	256
Total		1536 operations

At a 10 ns clock period (100 MHz) → approx. 15.36 µs total test time.

Debug Tips

If simulation fails:

1. Reset timing

Ensure rst_n remains low long enough.

2. Memory initialization

Verify memory contents are zero after reset.

3. FSM behavior

Monitor u_top.u_mbist.state to ensure transitions are correct.

4. First read mismatch

Unexpected values indicate prior write or reset logic issues.

5. MBISR not repairing

Check CAM table entries and remap address output.

References
TinyTapeout Documentation: https://tinytapeout.com

MBIST March Algorithms: https://en.wikipedia.org/wiki/March_test

Memory BIST Basics: https://www.edn.com/memory-bist-basics/

cocotb Documentation: https://docs.cocotb.org/en/stable/

Verilog HDL Reference Guide: https://www.sutherland-hdl.com/papers/1996-CUG-presentation_Verilog-Quick-Reference.pdf

Icarus Verilog: http://iverilog.icarus.com