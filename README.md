tt_um_aksp_mbist_mbisr
Memory Built-In Self-Test (MBIST) with Built-In Self-Repair (MBISR) for TinyTapeout

Overview
--------
This project implements a complete Memory Built-In Self-Test (MBIST) system with integrated Memory Built-In Self-Repair (MBISR).  
The MBIST uses the March C- algorithm to detect memory faults, and MBISR automatically remaps faulty addresses into a spare memory region.

Features
--------
- March C- algorithm memory testing
- Automatic repair of up to 16 faulty addresses
- 256-byte memory with spare region (0xF0–0xFF)
- Adjustable address/data widths and repair capacity
- Fully compatible with TinyTapeout interface

Pin Mapping
-----------
TinyTapeout Pin | Internal Signal | Description
clk             | clk             | System clock
rst_n           | rst             | Active-low reset
ena             | ena             | Enable
ui_in[0]        | start           | Start test pulse
uo_out[0]       | done            | Test complete
uo_out[1]       | fail            | Failure detected
uio[7:0]        | -               | High-Z

Operation Sequence
------------------
1. Apply active-low reset  
2. Pulse ui_in[0] high for 1+ clock cycles  
3. Hardware executes March C- algorithm  
4. Check uo_out[0] for completion  
5. Check uo_out[1] for pass/fail indication  

March C- Algorithm Steps
------------------------
1. Write 0 ascending  
2. Read 0, write 1 ascending  
3. Read 1, write 0 descending  
4. Read 0 ascending  

Repair Mechanism (MBISR)
------------------------
- CAM-like fault address table  
- Spare memory region: 0xF0–0xFF  
- Automatic remapping of faulty addresses  
- Supports up to 16 repairs  

File Structure

## File Structure

| Path / File | Description |
|-------------|-------------|
| `tt_um_aksp_mbist_mbisr/` | Project root directory |
| `src/` | Source Verilog files |
| `src/tt_um_aksp_mbist_mbisr.v` | TinyTapeout wrapper |
| `src/top.v` | Main integration module |
| `src/mbist_marchc_controller.v` | MBIST controller |
| `src/mbisr_controller.v` | MBISR repair controller |
| `src/memory.v` | 256×8 memory module |
| `test/` | Testbench and simulation files |
| `test/tt_um_aksp_mbist_mbisr_tb.v` | Testbench |
| `test/Makefile` | Simulation automation |
| `docs/` | Documentation folder |
| `docs/spec.md` | Detailed design specification |
| `.github/workflows/` | CI/CD pipeline directory |
| `.github/workflows/sim.yaml` | GitHub Actions simulation workflow |
| `config.json` | TinyTapeout configuration file |
| `info.yaml` | Project metadata |
| `README.txt` | Project documentation |




Simulation
----------
Run locally:

    cd test
    make all

Or manual:

    iverilog -o sim.out -I../src ../src/*.v tt_um_aksp_mbist_mbisr_tb.v
    vvp sim.out
    gtkwave wave.vcd

CI/CD
-----
Simulation runs automatically in GitHub Actions with waveform upload.

Configuration Parameters
------------------------
ADDR_WIDTH = 8  
DATA_WIDTH = 8  
MAX_REPAIRS = 16  
SPARE_BASE = 0xF0  
MEM_SIZE = 256  

Design Details
--------------
MBIST Controller:
- Implements March C-
- Reports failing addresses
- Provides done/fail outputs

MBISR Controller:
- CAM-style address table
- Dynamic address remapping
- Supports multiple repairs

Memory Module:
- 256×8 synchronous RAM
- Reset initializes to zero

License
-------
Apache License 2.0 - see [LICENSE](LICENSE) file for details.

Author
------
Dr Aditya Kumar Singh Pundir (adityapundir1985)

LinkedIn: https://www.linkedin.com/in/dradityapundir/

Acknowledgments
---------------
TinyTapeout, IHP Microelectronics, Open-source EDA community

References
----------

Academic Publications by the Author
1. Pundir, A.K.S., Singh, P., Kumar, R. et al. 
   "Modelling, Simulation, and FPGA Implementation of an Augmented Memory Built-in Self-Test Based Design for Bit-Oriented Memory."  
   Journal of Electronic Testing, 2025.  
   DOI: https://doi.org/10.1007/s10836-025-06193-3

2. Mathur, V., Singh, K., Pundir, A.S.  
   "IoT based memory fault diagnosis and repairing using PSO."  
   Facta Universitatis, 2025.  
   DOI: https://doi.org/10.2298/FUEE2502209M

3. Mathur, V., Pundir, A.K., Gupta, R.K., Singh, S.K.  
   "Recrudesce: IoT-Based Embedded Memories Algorithms and Self-healing Mechanism."  
   DOI: https://doi.org/10.1007/978-981-99-5180-2_10

4. Mathur, V., Pundir, A.K., Singh, S., Singh, S.K.  
   "Algorithms and Self Repair Mechanism for Embedded Memories Testing."  
   DOI: https://doi.org/10.1007/978-981-99-4795-9_48

5. Singh Pundir, A.K.  
   "Modified Memory Built In Self Repair (MMBISR) for SRAM."  
   IET Circuits, Devices & Systems, 2019.  
   DOI: https://doi.org/10.1049/iet-cds.2018.5218

Technical References

6. TinyTapeout Documentation  
   https://tinytapeout.com

7. March Test Algorithms (Wikipedia)  
   https://en.wikipedia.org/wiki/March_test

8. Memory BIST Fundamentals (EDN)  
   https://www.edn.com/memory-bist-basics/

9. Verilog HDL Quick Reference  
   https://www.sutherland-hdl.com/papers/1996-CUG-presentation_Verilog-Quick-Reference.pdf

10. Icarus Verilog  
    http://iverilog.icarus.com
