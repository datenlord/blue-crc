include ../../Makefile.base

CRC_WIDTH = 8
AXI_WIDTH = 512
FILE ?= TestCrc$(CRC_WIDTH)AxiStream.bsv
TOP ?= mkTestCrc$(CRC_WIDTH)AxiStream$(AXI_WIDTH)

SIMEXE = $(BUILDDIR)/$(TOP).exe

compile: table
	mkdir -p $(BUILDDIR)
#	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)
	bsc -elab -sim $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)

link: compile
	bsc -sim $(BLUESIMFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -e $(TOP) -o $(SIMEXE)

simulate: link
	python3 ../../src/gen_crc_tab.py $(CRC_WIDTH) $(AXI_WIDTH)
	$(SIMEXE)

clean:
	rm -rf $(BUILDDIR) logs
	rm *.dat

.PHONY: compile link simulate clean table
.DEFAULT_GOAL := simulate

