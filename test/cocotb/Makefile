SCRIPTS_PATH = ../../scripts

include $(SCRIPTS_PATH)/GenVerilog.mk

CRC_WIDTH = 32
AXI_WIDTH = 256
FILE = Crc$(CRC_WIDTH)AxiStream.bsv
TOP = mkCrc$(CRC_WIDTH)RawAxiStream$(AXI_WIDTH)
FILE_PATH = ../../src
VLOGDIR = ./generated
TABDIR = .

table:
	python3 $(FILE_PATH)/gen_crc_tab.py $(CRC_WIDTH) $(AXI_WIDTH) $(TABDIR)

cocotb: verilog table
	python3 testCrcAxiStream.py $(CRC_WIDTH) $(AXI_WIDTH)

clean:
	rm -rf $(BUILDDIR)
	rm -rf $(VLOGDIR)
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf logs
	rm -f *.mem

.PHONY: verilog clean
.DEFAULT_GOAL := cocotb

