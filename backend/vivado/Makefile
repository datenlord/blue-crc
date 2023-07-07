ROOT_DIR = $(abspath ../../)
SCRIPTS_DIR = $(ROOT_DIR)/scripts
include $(SCRIPTS_DIR)/Makefile.base
LOCALSRCDIR = $(ROOT_DIR)/src
LIBSRCDIR = $(ROOT_DIR)/lib/blue-wrapper/src

PWD = $(shell pwd)
VLOGDIR = generated
OUTPUTDIR = output
ONLYSYNTH = 0
CLK = main_clock

CRC_WIDTH ?= 32
AXI_WIDTH ?= 256
TARGETFILE ?= $(LOCALSRCDIR)/Crc$(CRC_WIDTH)AxiStream.bsv
TOPMODULE ?= mkCrc$(CRC_WIDTH)RawAxiStream$(AXI_WIDTH)
SUB_VLOGDIR = $(VLOGDIR)/$(TOPMODULE)
SUB_OUTPUTDIR = $(OUTPUTDIR)/$(TOPMODULE)
TABDIR = .

export TOP = $(TOPMODULE)
export RTL = $(SUB_VLOGDIR)
export XDC = $(PWD)
export OUTPUT = $(SUB_OUTPUTDIR)
export SYNTHONLY = $(ONLYSYNTH)
export CLOCKS = $(CLK)

table:
	python3 $(LOCALSRCDIR)/gen_crc_tab.py $(CRC_WIDTH) $(AXI_WIDTH) $(TABDIR)

compile:
	mkdir -p $(BUILDDIR)
	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOPMODULE) $(TARGETFILE)

verilog: compile
	mkdir -p $(SUB_VLOGDIR)
	bsc $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) -g $(TOPMODULE) $(TARGETFILE)
	bluetcl $(SCRIPTS_DIR)/listVlogFiles.tcl -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOPMODULE) $(TOPMODULE) | grep -i '\.v' | xargs -I {} cp {} $(SUB_VLOGDIR)

vivado: verilog table
	vivado -mode batch -source non_project_build.tcl 2>&1 | tee ./run.log

clean:
	rm -rf $(BUILDDIR) $(VLOGDIR) $(OUTPUTDIR) .Xil *.jou *.log *.mem

.PHONY: table compile verilog clean vivado
.DEFAULT_GOAL := vivado
