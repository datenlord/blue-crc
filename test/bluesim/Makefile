ROOT_DIR = $(abspath ../../)
SCRIPTS_DIR = $(ROOT_DIR)/scripts
include $(SCRIPTS_DIR)/Makefile.base
LOCALSRCDIR = $(ROOT_DIR)/src
LIBSRCDIR = $(ROOT_DIR)/lib/blue-wrapper/src

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

MACROFLAGS = -D AXI_KEEP_WIDTH=$(CRC_WIDTH) \
             -D CRC_WIDTH=$(AXI_KEEP_WIDTH) \
			 -D POLY=$(POLY) \
			 -D INIT_VAL=$(INIT_VAL) \
			 -D FINAL_XOR=$(FINAL_XOR) \
			 -D REV_INPUT=$(REV_INPUT) \
			 -D REV_OUTPUT=$(REV_OUTPUT) \
			 -D MEM_FILE_PREFIX="\"$(MEM_FILE_PREFIX)\"" \
			 -D CRC_MODE=$(CRC_MODE)

FILE ?= TestCrcAxiStream.bsv
TOP ?= mkTestCrcAxiStream

SIMEXE = $(BUILDDIR)/$(TOP).exe
CRC_TAB_SCRIPTS = $(SCRIPTS_DIR)/gen_crc_tab.py
TABDIR = .

table:
	python3 $(CRC_TAB_SCRIPTS) $(JSON_CONF_FILE) $(TABDIR)

compile:
	mkdir -p $(BUILDDIR)
#	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)
	bsc -elab -sim $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) $(MACROFLAGS) -g $(TOP) $(FILE)

link: compile
	bsc -sim $(BLUESIMFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -e $(TOP) -o $(SIMEXE)

simulate: link table
	$(SIMEXE)

clean:
	rm -rf $(BUILDDIR) logs
	rm *.mem

.PHONY: compile link simulate clean table
.DEFAULT_GOAL := simulate

