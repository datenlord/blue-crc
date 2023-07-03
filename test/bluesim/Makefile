ROOT_DIR = $(abspath ../../)
SCRIPTS_DIR = $(ROOT_DIR)/scripts
include $(SCRIPTS_DIR)/Makefile.base
LOCALSRCDIR = $(ROOT_DIR)/src
LIBSRCDIR = $(ROOT_DIR)/lib/blue-wrapper/src

CRC_WIDTH = 8
AXI_WIDTH = 512
FILE ?= TestCrc$(CRC_WIDTH)AxiStream.bsv
TOP ?= mkTestCrc$(CRC_WIDTH)AxiStream$(AXI_WIDTH)

SIMEXE = $(BUILDDIR)/$(TOP).exe
CRC_TAB_SCRIPTS = $(LOCALSRCDIR)/gen_crc_tab.py

compile: table
	mkdir -p $(BUILDDIR)
#	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)
	bsc -elab -sim $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)

link: compile
	bsc -sim $(BLUESIMFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -e $(TOP) -o $(SIMEXE)

simulate: link
	python3 $(CRC_TAB_SCRIPTS) $(CRC_WIDTH) $(AXI_WIDTH)
	$(SIMEXE)

clean:
	rm -rf $(BUILDDIR) logs
	rm *.mem

.PHONY: compile link simulate clean table
.DEFAULT_GOAL := simulate

