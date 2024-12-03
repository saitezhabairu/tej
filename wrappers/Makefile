# Makefile for cocotb testing with Icarus Verilog

# Set simulation tool to Icarus Verilog (you can change it to 'vcs', 'modelsim', etc. if needed)
SIM ?= icarus

# Set the top-level language to Verilog
TOPLEVEL_LANG ?= verilog

# Include Verilog source files
VERILOG_SOURCES += $(PWD)/../hdl/xor_gate.v  # Path to the XOR gate Verilog file
VERILOG_SOURCES += $(PWD)/../wrappers/wrapper.v  # Path to the wrapper file that instantiates the XOR gate

# Target to run the simulation
gate:
	$(MAKE) sim MODULE=xor_test TOPLEVEL=wrapper

# Include cocotb's makefile to handle simulation and testing
include $(shell cocotb-config --makefiles)/Makefile.sim

