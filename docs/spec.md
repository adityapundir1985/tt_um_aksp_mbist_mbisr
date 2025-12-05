# MBIST with MBISR - Memory Built-In Self-Test with Built-In Self-Repair

## Project Overview
**Title:** MBIST with MBISR  
**Author:** Dr. Aditya Kumar Singh Pundir, Dr. Pallavi Singh 
**Description:** Memory Built-In Self-Test (March C-) with Built-In Self-Repair (CAM-based address remapping) for TinyTapeout.

## How It Works
1. **MBIST Controller:** Implements March C- algorithm for memory testing
2. **MBISR Controller:** CAM-style repair table for fault address remapping
3. **Memory Module:** 256×8 synchronous memory with spare region (0xF0-0xFF)
4. **Test Flow:** Write 0 → Read 0/Write 1 → Read 1/Write 0 → Read 0 verification

## How To Test
1. Apply reset (`rst_n = 0` then `1`)
2. Pulse `ui_in[0]` high to start test
3. Monitor `uo_out[0]` for completion
4. Check `uo_out[1]` for pass/fail status


## Features
- March C- memory test algorithm
- Up to 16 address repairs
- Automatic fault detection and remapping
- 256-byte memory with spare region

## Pin Mapping
| Pin | Direction | Description |
|-----|-----------|-------------|
| `clk` | Input | System clock |
| `rst_n` | Input | Active-low reset |
| `ena` | Input | Chip enable |
| `ui_in[0]` | Input | Start test pulse |
| `uo_out[0]` | Output | Test complete |
| `uo_out[1]` | Output | Test failure |

## Technical Specifications
- **Language:** Verilog-2001
- **Memory Size:** 256 bytes
- **Repair Capacity:** 16 addresses
- **Spare Region:** 0xF0-0xFF
- **Clock Frequency:** 10 MHz

## References
- Pundir, A.K.S. et al. "Modelling, Simulation, and FPGA Implementation..." J Electron Test (2025)
- March C- Algorithm Specification
- TinyTapeout Submission Guidelines
