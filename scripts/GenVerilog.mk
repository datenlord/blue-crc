include $(SCRIPTS_PATH)/Makefile.base

SCRIPTS_PATH ?=
CRC_WIDTH ?=
AXI_WIDTH ?=
FILE ?=
TOP ?=
FILE_PATH ?=
VLOGDIR ?=
TABDIR ?=
TARGET_FILE = $(VLOGDIR)/$(TOP).v
LIST_VERILOG_TCL = $(SCRIPTS_PATH)/listVlogFiles.tcl


verilog:
	mkdir -p $(BUILDDIR)
	bsc -elab $(VERILOGFLAGS) $(DIRFLAGS) $(MISCFLAGS) $(RECOMPILEFLAGS) $(RUNTIMEFLAGS) $(TRANSFLAGS) $(MACROSAGS) -g $(TOP) $(FILE_PATH)/$(FILE)
	mkdir -p $(VLOGDIR)
	echo "" > $(TARGET_FILE)
	bluetcl $(LIST_VERILOG_TCL) -bdir $(BUILDDIR) -vdir $(BUILDDIR) $(TOP) $(TOP) | grep -i '\.v' | xargs -I {} cat {} >> $(TARGET_FILE)


.PHONY: verilog