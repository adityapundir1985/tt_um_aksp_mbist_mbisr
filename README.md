# tt_um_aksp_mbist_mbisr

Memory Built-In Self-Test (MBIST) with Built-In Self-Repair (MBISR) for TinyTapeout

## Overview

This project implements a complete Memory Built-In Self-Test (MBIST) system with integrated Memory Built-In Self-Repair (MBISR).
The MBIST uses the March C- algorithm to detect memory faults, and MBISR automatically remaps faulty addresses into a spare memory region.

## Features

- March C- algorithm memory testing
- Automatic repair of up to 2 faulty addresses
- 32-byte memory (5-bit address, 8-bit data)
- 2 spare memory locations for repairs
- Fully compatible with TinyTapeout interface
- CAM-based faulty address remapping

## Specifications

Memory Size: 32 bytes (256 bits)  
Address Width: 5 bits (0–31)  
Data Width: 8 bits  
Max Repairs: 2 faulty addresses  
Spare Region: 0x1E–0x1F  
Clock Frequency: 50 MHz (20 ns period)  
Test Algorithm: March C-

## Pin Mapping

TinyTapeout Pin | Internal Signal | Description  
clk | clk | 50 MHz system clock  
rst_n | rst | Active-low reset  
ena | ena | Enable (always active)  
ui_in[0] | start | MBIST start pulse (active high)  
uo_out[0] | done | Test completion indicator  
uo_out[1] | fail | Fault detection indicator  
uio[7:0] | - | Unused (configured as inputs)

## Operation Sequence

1. Apply active-low reset (pulse rst_n low).
2. Pulse ui_in[0] high for at least 1 clock cycle to start the test.
3. Hardware executes the March C- algorithm automatically.
4. Monitor uo_out[0] – goes high when test completes.
5. Check uo_out[1] – low indicates pass, high indicates fault(s) detected.

## March C- Algorithm Steps

1. Write 0 to all addresses (ascending)
2. Read 0, write 1 (ascending)
3. Read 1, write 0 (descending)
4. Read 0 (ascending)

## Repair Mechanism (MBISR)

- CAM-style fault address table
- Spare memory region: addresses 30–31 (0x1E–0x1F)
- Automatic remapping of faulty addresses
- Supports up to 2 simultaneous repairs
- Persistent repair across test cycles

## File Structure

tt_um_aksp_mbist_mbisr/
src/
  tt_um_aksp_mbist_mbisr.v
  top.v
  mbist_marchc_controller.v
  mbisr_controller.v
  memory.v
test/
  tb.v
  test.py
  Makefile
.github/workflows/
info.yaml
config.json
README.md

## Simulation

Local Simulation:

cd test  
make clean  
make

Manual Simulation:

iverilog -o sim.out -I../src ../src/*.v tb.v  
vvp sim.out  
gtkwave tb.fst

## CI/CD

- Test Workflow: Runs on every push
- GDS Workflow: Generates layout and gate-level simulation
- Docs Workflow: Builds documentation
- FPGA Workflow: Generates FPGA bitstream (manual trigger)

## Design Details

MBIST Controller:
- Implements March C- algorithm
- Provides done/fail status outputs

MBISR Controller:
- CAM-style address remapping
- Supports 2 simultaneous repairs

Memory Module:
- 32×8 synchronous RAM
- Reset initializes memory to zero

## License

Apache License 2.0

## Authors

Dr. Aditya Kumar Singh Pundir  
LinkedIn: https://www.linkedin.com/in/dradityapundir/

Dr. Pallavi Singh  
LinkedIn: https://www.linkedin.com/in/dr-pallavi-singh-554a8826a/

## References

[1] A. K. S. Pundir, P. Singh, and R. Kumar, “Modelling, Simulation, and FPGA Implementation of an Augmented Memory Built-In Self-Test Based Design for Bit-Oriented Memory,” Journal of Electronic Testing, 2025, doi:10.1007/s10836-025-06193-3.

[2] V. Mathur, K. Singh, and A. S. Pundir, “IoT based memory fault diagnosis and repairing using PSO,” Facta Universitatis, 2025, doi:10.2298/FUEE2502209M.

[3] V. Mathur, A. K. Pundir, R. K. Gupta, and S. K. Singh, “Recrudesce: IoT-Based Embedded Memories Algorithms and Self-Healing Mechanism,” 2025, doi:10.1007/978-981-99-5180-2_10.

[4] V. Mathur, A. K. Pundir, S. Singh, and S. K. Singh, “Algorithms and Self Repair Mechanism for Embedded Memories Testing,” 2025, doi:10.1007/978-981-99-4795-9_48.

[5] A. K. Singh Pundir, “Modified Memory Built-In Self-Repair (MMBISR) for SRAM,” IET Circuits, Devices & Systems, 2019, doi:10.1049/iet-cds.2018.5218.

[6] TinyTapeout Documentation: https://tinytapeout.com  
[7] March Test (Wikipedia): https://en.wikipedia.org/wiki/March_test  
[8] Memory BIST Basics (EDN): https://www.edn.com/memory-bist-basics/  
[9] Verilog HDL Quick Reference: https://www.sutherland-hdl.com/papers/1996-CUG-presentation_Verilog-Quick-Reference.pdf  
[10] Icarus Verilog: http://iverilog.icarus.com

---

Version: 1.0  
Compatible with: TinyTapeout ttihp-verilog-template
