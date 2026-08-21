SRC_counter8bit=rtl/lib/counter8bit.sv
SRC_prescaler=rtl/lib/prescaler.sv
SRC_ledCounter=rtl/lib/counter8bit.sv rtl/lib/prescaler.sv rtl/top/ledCounter.sv 

SIM?=icarus
PROJ?=ledCounter
SRC=$(SRC_$(PROJ))
TB=tb/tb_$(PROJ).sv 
 
ifeq ($(SIM),verilator)
	$(error Verilator sim not yet implemented)
else
	LINT_CMD=iverilog -g2012 -t null -Wall $(SRC) $(TB) 
	ELAB_CMD=iverilog -g2012 -o build/$(PROJ).vvp $(SRC) $(TB)
	SIM_CMD=vvp $(PROJ).vvp
	VIEW_CMD=gtkwave build/$(PROJ).vcd
endif
 
.DEFAULT_GOAL := sim
.DELETE_ON_ERROR:
 
lint: $(SRC) $(TB)
	$(LINT_CMD)
 
build:
	mkdir -p $@
 
build/$(PROJ).vvp: $(SRC) $(TB) | build
	$(ELAB_CMD)
 
sim: build/$(PROJ).vvp
	cd build && $(SIM_CMD)
 
wave: sim
	$(VIEW_CMD)
 
clean:
	rm -rf build

// CI 
PROJECTS := $(patsubst tb/tb_%.sv,%,$(wildcard tb/tb_*.sv))
sim-all: $(addprefix sim-,$(PROJECTS))

lint-all: $(addprefix lint-,$(PROJECTS))

sim-%:
	$(MAKE) sim PROJ=$*

lint-%:
	$(MAKE) sim PROJ=$*
 
.PHONY: lint sim wave clean sim-all lint-all
 
