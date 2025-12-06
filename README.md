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
- **Memory Size**: 32 bytes (256 bits)
- **Address Width**: 5 bits (0-31)
- **Data Width**: 8 bits
- **Max Repairs**: 2 faulty addresses
- **Spare Region**: Addresses 30-31 (0x1E-0x1F)
- **Clock Frequency**: 50 MHz (20ns period)
- **Test Algorithm**: March C-

## Pin Mapping
| TinyTapeout Pin | Internal Signal | Description |
|-----------------|-----------------|-------------|
| clk             | clk             | 50MHz system clock |
| rst_n           | rst             | Active-low reset |
| ena             | ena             | Enable (always active) |
| ui_in[0]        | start           | MBIST start pulse (active high) |
| uo_out[0]       | done            | Test completion indicator |
| uo_out[1]       | fail            | Fault detection indicator |
| uio[7:0]        | -               | Unused (configured as inputs) |

## Operation Sequence
1. Apply active-low reset (pulse rst_n low)
2. Pulse ui_in[0] high for 1+ clock cycles to start test
3. Hardware executes March C- algorithm automatically
4. Monitor uo_out[0] - goes high when test completes
5. Check uo_out[1] - low indicates pass, high indicates fault(s) detected

## March C- Algorithm Steps
1. Write 0 to all addresses (ascending)
2. Read 0, write 1 (ascending)
3. Read 1, write 0 (descending)
4. Read 0 (ascending)

## Repair Mechanism (MBISR)
- CAM-style fault address table
- Spare memory region: addresses 30-31 (0x1E-0x1F)
- Automatic remapping of faulty addresses
- Supports up to 2 simultaneous repairs
- Persistent repair across test cycles

## File Structure
tt_um_aksp_mbist_mbisr/
├── src/
│ ├── tt_um_aksp_mbist_mbisr.v # TinyTapeout wrapper
│ ├── top.v # Main integration module
│ ├── mbist_marchc_controller.v # MBIST controller (March C-)
│ ├── mbisr_controller.v # MBISR repair controller
│ └── memory.v # 32×8 synchronous memory
├── test/
│ ├── tb.v # Testbench
│ ├── test.py # Python cocotb tests
│ └── Makefile # Simulation makefile
├── .github/workflows/ # CI/CD workflows
├── info.yaml # Project metadata
├── config.json # PDK configuration
└── README.md # This file

text

## Simulation
### Local Simulation:
```bash
cd test
make clean
make
Manual Simulation:
bash
iverilog -o sim.out -I../src ../src/*.v tb.v
vvp sim.out
gtkwave tb.fst  # or tb.vcd
CI/CD
Test Workflow: Runs on every push, executes cocotb tests

GDS Workflow: Generates layout, runs gate-level simulation

Docs Workflow: Builds documentation

FPGA Workflow: Generates FPGA bitstream (manual trigger)

Design Details
MBIST Controller:
Implements March C- algorithm

Reports failing addresses with fail_valid signal

Provides done/fail status outputs

Handles read/write timing with 2-cycle operations

MBISR Controller:
Content-Addressable Memory (CAM) style address table

Dynamic address remapping to spare region

Supports 2 simultaneous repairs

Persistent fault tracking across resets

Memory Module:
32×8 synchronous RAM

Reset initializes all locations to zero

Single clock cycle read/write operations

License
Apache License 2.0 - see LICENSE file for details.

Authors
Dr Aditya Kumar Singh Pundir
LinkedIn | GitHub

Dr Pallavi Singh
LinkedIn

Acknowledgments
TinyTapeout team for the open-source silicon platform

IHP Microelectronics for the SG13G2 PDK

Open-source EDA tool developers

References
Academic Publications by the Authors
Pundir, A.K.S., Singh, P., Kumar, R. et al.
"Modelling, Simulation, and FPGA Implementation of an Augmented Memory Built-in Self-Test Based Design for Bit-Oriented Memory."
Journal of Electronic Testing, 2025.
DOI: https://doi.org/10.1007/s10836-025-06193-3

Mathur, V., Singh, K., Pundir, A.S.
"IoT based memory fault diagnosis and repairing using PSO."
Facta Universitatis, 2025.
DOI: https://doi.org/10.2298/FUEE2502209M

Mathur, V., Pundir, A.K., Gupta, R.K., Singh, S.K.
"Recrudesce: IoT-Based Embedded Memories Algorithms and Self-healing Mechanism."
DOI: https://doi.org/10.1007/978-981-99-5180-2_10

Mathur, V., Pundir, A.K., Singh, S., Singh, S.K.
"Algorithms and Self Repair Mechanism for Embedded Memories Testing."
DOI: https://doi.org/10.1007/978-981-99-4795-9_48

Singh Pundir, A.K.
"Modified Memory Built In Self Repair (MMBISR) for SRAM."
IET Circuits, Devices & Systems, 2019.
DOI: https://doi.org/10.1049/iet-cds.2018.5218

Technical References
TinyTapeout Documentation
https://tinytapeout.com

March Test Algorithms (Wikipedia)
https://en.wikipedia.org/wiki/March_test

Memory BIST Fundamentals
https://www.edn.com/memory-bist-basics/

Verilog HDL Quick Reference
https://www.sutherland-hdl.com/papers/1996-CUG-presentation_Verilog-Quick-Reference.pdf

Icarus Verilog
http://iverilog.icarus.com