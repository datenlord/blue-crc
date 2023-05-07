include ../../scripts/Makefile.base

CRC_WIDTH ?= 8
AXI_WIDTH ?= 64

FILE = Crc$(CRC_WIDTH)AxiStream.bsv
TOP = mkCrc$(CRC_WIDTH)AxiStream$(AXI_WIDTH)
FILE_PATH = ../../src/
VLOGDIR = ./verilog/generated
TARGET_FILE = $(VLOGDIR)/$(TOP).v
LIST_VERILOG_TCL = ../../scripts/listVlogFiles.tcl
verilog:
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE_PATH)/$(FILE)
	mkdir -p $(VLOGDIR)
	echo "" > $(TARGET_FILE)
	bluetcl $(LIST_VERILOG_TCL) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cat {} >> $(TARGET_FILE)

cocotb: verilog
	python3 ../../src/gen_crc_tab.py $(CRC_WIDTH) $(AXI_WIDTH)
	python3 testCrcAxiStream.py $(CRC_WIDTH) $(AXI_WIDTH)

clean:
	rm -rf $(BUILDDIR)
	rm -rf $(VLOGDIR)
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf logs
	rm -f *.mem

.PHONY: verilog clean
.DEFAULT_GOAL := verilog

