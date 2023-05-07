PWD = $(shell pwd)
BUILDDIR = build
SRCDIR = ../../src
VLOGDIR = generated
OUTPUTDIR = output
ONLYSYNTH = 0
CLK = main_clock
GEN_TAB = $(SRCDIR)/gen_crc_tab.py
LIST_VLOG = ../../scripts/listVlogFiles.tcl

CRC_WIDTH ?= 8
AXI_WIDTH ?= 64
TARGET = Crc$(CRC_WIDTH)AxiStream$(AXI_WIDTH)
TARGETFILE = $(SRCDIR)/Crc$(CRC_WIDTH)AxiStream.bsv
TOPMODULE = mk$(TARGET)

SUB_VLOGDIR = $(VLOGDIR)/$(TARGET)
SUB_OUTPUTDIR = $(OUTPUTDIR)/$(TARGET)

export TOP = $(TOPMODULE)
export RTL = $(SUB_VLOGDIR)
export XDC = $(PWD)
export OUTPUT = $(SUB_OUTPUTDIR)
export SYNTHONLY = $(ONLYSYNTH)
export CLOCKS = $(CLK)

TRANSFLAGS = -aggressive-conditions # -lift -split-if
RECOMPILEFLAGS = -u -show-compiles
SCHEDFLAGS = -show-schedule -sched-dot # -show-rule-rel dMemInit_request_put doExecute
#	-show-elab-progress
DEBUGFLAGS = -check-assert \
	-continue-after-errors \
	-keep-fires \
	-keep-inlined-boundaries \
	-show-method-bvi \
	-show-method-conf \
	-show-module-use \
	-show-range-conflict \
	-show-stats \
	-warn-action-shadowing \
	-warn-method-urgency \
#	-promote-warnings ALL
VERILOGFLAGS = -verilog -remove-dollar -remove-unused-modules # -use-dpi -verilog-filter cmd
BLUESIMFLAGS = -parallel-sim-link 16 # -systemc
OUTDIR = -bdir $(BUILDDIR) -info-dir $(BUILDDIR) -simdir $(BUILDDIR) -vdir $(BUILDDIR)
WORKDIR = -fdir $(abspath .)
BSVSRCDIR = -p +:$(abspath $(SRCDIR))
DIRFLAGS = $(BSVSRCDIR) $(OUTDIR) $(WORKDIR)
MISCFLAGS = -print-flags -show-timestamps -show-version # -steps 1000000000000000 -D macro
RUNTIMEFLAGS = +RTS -K256M -RTS
SIMEXE = $(BUILDDIR)/out

compile:
	mkdir -p $(BUILDDIR)
	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOPMODULE) $(TARGETFILE)

link: compile
	bsc -sim $(BLUESIMFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -e $(TOPMODULE) -o $(SIMEXE)


verilog: link
	bsc $(VERILOGFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(TRANSFLAGS) -g $(TOPMODULE) $(TARGETFILE)
	mkdir -p $(SUB_VLOGDIR)
	bluetcl $(LIST_VLOG) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOPMODULE) $(TOPMODULE) | grep -i '\.v' | xargs -I {} cp {} $(SUB_VLOGDIR)
	python3 $(GEN_TAB) $(CRC_WIDTH) $(AXI_WIDTH)

vivado: verilog
	vivado -mode batch -source non_project_build.tcl 2>&1 | tee ./run.log

clean:
	rm -rf $(BUILDDIR) $(VLOGDIR) $(OUTPUTDIR) .Xil *.jou *.log *.mem

.PHONY: compile link clean vivado
.DEFAULT_GOAL := vivado