# Makefile for MBIST+MBISR simulation
# Run from project root directory

# Tools
IVERILOG := iverilog
VVP := vvp

# Directories
SRC_DIR := ../src
TEST_DIR := .

# Source files
SRC_FILES := $(SRC_DIR)/tt_um_aksp_mbist_mbisr.v \
             $(SRC_DIR)/top.v \
             $(SRC_DIR)/mbist_marchc_controller.v \
             $(SRC_DIR)/mbisr_controller.v \
             $(SRC_DIR)/memory.v

TEST_FILE := $(TEST_DIR)/tt_um_aksp_mbist_mbisr_tb.v

# Output files
SIM_OUT := sim.out
WAVE_OUT := wave.vcd

# Default target
all: compile run

# Compile the design
compile:
	@echo "Compiling Verilog files..."
	$(IVERILOG) -o $(SIM_OUT) -I$(SRC_DIR) $(SRC_FILES) $(TEST_FILE)
	@echo "Compilation complete."

# Run simulation
run:
	@echo "Running simulation..."
	$(VVP) $(SIM_OUT)
	@echo "Simulation complete."

# Generate waveform
wave: compile
	@echo "Running simulation with waveform generation..."
	$(VVP) $(SIM_OUT) +dump
	@echo "Waveform generated: $(WAVE_OUT)"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f $(SIM_OUT) $(WAVE_OUT)
	@echo "Clean complete."

# Help target
help:
	@echo "Available targets:"
	@echo "  make all     - Compile and run simulation (default)"
	@echo "  make compile - Compile Verilog files only"
	@echo "  make run     - Run simulation (requires compiled files)"
	@echo "  make wave    - Compile and run with waveform generation"
	@echo "  make clean   - Remove generated files"
	@echo "  make help    - Show this help message"

.PHONY: all compile run wave clean help