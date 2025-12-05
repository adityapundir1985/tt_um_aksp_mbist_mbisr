# tt_um_aksp_mbist_mbisr

TinyTapeout IHP-compatible Verilog project implementing MBIST (March C-) and MBISR controllers.

## Top-level mapping (TinyTapeout wrapper)
- `clk`   : input clock
- `rst_n` : active-low reset (inverted inside wrapper)
- `ena`   : optional enable (not used)
- `ui_in[7:0]` : user inputs (ui_in[0] used as `start`)
- `uo_out[7:0]` : user outputs (uo_out[0]=`done`, uo_out[1]=`fail`)
- `uio[7:0]` : bidirectional (unused, left high-Z)

## Building & Simulation (local)
From repository root:
```
iverilog -o sim.out src/*.v test/tt_um_aksp_mbist_mbisr_tb.v
vvp sim.out
gtkwave wave.vcd
```

## Files
- `src/` : Verilog RTL including wrapper `tt_um_aksp_mbist_mbisr.v`
- `test/` : testbench and Makefile
- `.github/workflows/` : CI placeholders
- `info.yaml` : TinyTapeout project metadata
