# MBIST with MBISR Specification

## Overview
Memory Built-In Self-Test (MBIST) with Built-In Self-Repair (MBISR) system.

## Features
- March C- memory test algorithm
- Up to 16 memory repair entries
- 256-byte memory with spare region
- Automatic failure detection and repair

## Interface
- `ui_in[0]`: Start test (active high pulse)
- `uo_out[0]`: Test done
- `uo_out[1]`: Test failed

## Operation
1. Pulse `ui_in[0]` to start test
2. Wait for `uo_out[0]` to go high
3. Check `uo_out[1]` for pass/fail status