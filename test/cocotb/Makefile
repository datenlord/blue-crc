ROOT_DIR = $(abspath ../../)
SCRIPTS_DIR = $(ROOT_DIR)/scripts
include $(SCRIPTS_DIR)/Makefile.base
LOCALSRCDIR = $(ROOT_DIR)/src
LIBSRCDIR = $(ROOT_DIR)/lib/blue-wrapper/src


FILE = CrcAxiStreamCustom.bsv
TOP = mkCrcRawAxiStreamCustom
VLOGDIR = verilog
TABDIR = $(BUILDDIR)
VLOGFILE = $(VLOGDIR)/$(TOP).v
LIST_VERILOG_TCL = $(SCRIPTS_DIR)/listVlogFiles.tcl

# CRC Configurations
JSON_CONF_FILE = $(SCRIPTS_DIR)/config/crc_32_256_recv.json
CRC_WIDTH = 32
AXI_KEEP_WIDTH = 32
POLY = 79764919
INIT_VAL = 4294967295
FINAL_XOR = 4294967295
REV_INPUT = BIT_ORDER_REVERSE
REV_OUTPUT = BIT_ORDER_REVERSE
MEM_FILE_PREFIX = crc_tab
CRC_MODE = CRC_MODE_RECV

MACROFLAGS = -D CRC_WIDTH=$(CRC_WIDTH) \
			 -D AXI_KEEP_WIDTH=$(AXI_KEEP_WIDTH) \
			 -D POLY=$(POLY) \
			 -D INIT_VAL=$(INIT_VAL) \
			 -D FINAL_XOR=$(FINAL_XOR) \
			 -D REV_INPUT=$(REV_INPUT) \
			 -D REV_OUTPUT=$(REV_OUTPUT) \
			 -D MEM_FILE_PREFIX="\"$(MEM_FILE_PREFIX)\"" \
			 -D CRC_MODE=$(CRC_MODE)

table:
	mkdir -p $(TABDIR)
	python3 $(SCRIPTS_DIR)/gen_crc_tab.py $(JSON_CONF_FILE) $(TABDIR)

verilog: table
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) $(MACROFLAGS) -g $(TOP) $(LOCALSRCDIR)/$(FILE)
	mkdir -p $(VLOGDIR)
	echo "" > $(VLOGFILE)
	bluetcl $(LIST_VERILOG_TCL) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cat {} >> $(VLOGFILE)

cocotb: verilog
	python3 TestCrcAxiStream.py $(JSON_CONF_FILE)

clean:
	rm -rf $(BUILDDIR) $(VLOGDIR) $(TABDIR) __pycache__ .pytest_cache logs *.mem

.PHONY: verilog table cocotb clean
.DEFAULT_GOAL := cocotb

