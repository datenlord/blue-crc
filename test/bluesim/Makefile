include ../../Makefile.base

FILE ?= TestCrc32AxiStream256.bsv
TOP ?= mkTestCrc32AxiStream256

SIMEXE = $(BUILDDIR)/$(TOP).exe

compile: table
	mkdir -p $(BUILDDIR)
#	bsc -elab -sim -verbose $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)
	bsc -elab -sim $(BLUESIMFLAGS) $(DEBUGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -g $(TOP) $(FILE)

link: compile
	bsc -sim $(BLUESIMFLAGS) $(DIRFLAGS) $(RECOMPILEFLAGS) $(SCHEDFLAGS) $(TRANSFLAGS) -e $(TOP) -o $(SIMEXE)

simulate: link
	python3 ../../src/gen_crc_tab.py
	$(SIMEXE)

clean:
	rm -rf $(BUILDDIR)
	rm *.dat

.PHONY: compile link simulate clean table
.DEFAULT_GOAL := simulate

