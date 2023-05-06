include ../../Makefile.base

CRC_WIDTH ?= 8
AXI_WIDTH ?= 64

FILE = Crc$(CRC_WIDTH)AxiStream.bsv
TOP = mkCrc$(CRC_WIDTH)AxiStream$(AXI_WIDTH)
FILE_PATH = ../../src/
VLOGDIR = ./verilog/generated
TARGET_FILE = $(VLOGDIR)/$(TOP).v

verilog:
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE_PATH)/$(FILE)
	mkdir -p $(VLOGDIR)
	echo "" > $(TARGET_FILE)
	bluetcl listVlogFiles.tcl -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cat {} >> $(TARGET_FILE)

clean:
	rm -rf $(BUILDDIR)
	rm -rf $(VLOGDIR)
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf logs
	rm -f *.dat

.PHONY: verilog clean
.DEFAULT_GOAL := verilog

