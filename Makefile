SRC=rtl/lib/* rtl/top/* 
TB=tb/tb_ledCounter.sv
 
SIM?=icarus
 
ifeq ($(SIM),verilator)
	$(error Verilator sim not yet implemented)
else
	LINT_CMD=iverilog -g2012 -t null -Wall $(SRC) $(TB) 
	ELAB_CMD=iverilog -g2012 -o build/elab.vvp $(SRC) $(TB)
	SIM_CMD=vvp elab.vvp
	VIEW_CMD=gtkwave build/dump.vcd
endif
 
.DEFAULT_GOAL := sim
.DELETE_ON_ERROR:
 
lint: $(SRC) $(TB)
	$(LINT_CMD)
 
build:
	mkdir -p $@
 
build/elab.vvp: $(SRC) $(TB) | build
	$(ELAB_CMD)
 
sim: build/elab.vvp
	cd build && $(SIM_CMD)
 
wave: sim
	$(VIEW_CMD)
 
clean:
	rm -rf build
 
.PHONY: lint sim wave clean
 
