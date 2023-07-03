ROOT_DIR = $(abspath ../../)
SCRIPTS_DIR = $(ROOT_DIR)/scripts
include $(SCRIPTS_DIR)/Makefile.base
LOCALSRCDIR = $(ROOT_DIR)/src
LIBSRCDIR = $(ROOT_DIR)/lib/blue-wrapper/src

CRC_WIDTH = 32
AXI_WIDTH = 256
FILE = Crc$(CRC_WIDTH)AxiStream.bsv
TOP = mkCrc$(CRC_WIDTH)RawAxiStream$(AXI_WIDTH)
LIST_VERILOG_TCL = $(SCRIPTS_DIR)/listVlogFiles.tcl
VLOGDIR = verilog
VLOGFILE = $(VLOGDIR)/$(TOP).v
TABDIR = .

MACROFLAGS ?=

verilog:
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) $(MACROFLAGS) -g $(TOP) $(LOCALSRCDIR)/$(FILE)
	mkdir -p $(VLOGDIR)
	echo "" > $(VLOGFILE)
	bluetcl $(LIST_VERILOG_TCL) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cat {} >> $(VLOGFILE)
	
table:
	python3 $(LOCALSRCDIR)/gen_crc_tab.py $(CRC_WIDTH) $(AXI_WIDTH) $(TABDIR)

cocotb: verilog table
	python3 testCrcAxiStream.py $(CRC_WIDTH) $(AXI_WIDTH)

clean:
	rm -rf $(BUILDDIR)
	rm -rf $(VLOGDIR)
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf logs
	rm -f *.mem

.PHONY: verilog table cocotb clean
.DEFAULT_GOAL := cocotb

