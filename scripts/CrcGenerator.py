import os
import sys
from functools import reduce

sys.path.append("./src")
from gen_crc_tab import CrcLookUpTable

CRC_WIDTH = 32
INPUT_WIDTH = 256
POLYNOMINAL = 0x04C11DB7
INIT_VALUE = 0xFFFFFFFF
FINAL_XOR = 0xFFFFFFFF
REFLECT_INPUT = True
REFLECT_OUTPUT = True


class CrcAxiStreamConfig:
    def __init__(
        self,
        crc_width: int,
        input_width: int,
        poly: int,
        init_val: int,
        final_xor: int,
        reflect_in: bool,
        reflect_out: bool,
    ):
        assert crc_width % 8 == 0, "crc_width must be multiples of 8-bit"
        assert input_width % 8 == 0, "input_width must be multiples of 8-bit"
        assert (poly >= 0) & (poly < pow(2, crc_width)), "polynominal out of range"
        assert (init_val >= 0) & (
            init_val < pow(2, crc_width)
        ), "initial value out of range"
        assert (final_xor >= 0) & (
            final_xor < pow(2, crc_width)
        ), "final xor out of range"

        self.crc_width = crc_width
        self.crc_byte_width = int(crc_width / 8)
        self.input_width = input_width
        self.input_byte_width = int(input_width / 8)
        self.poly = poly
        self.init_val = init_val
        self.final_xor = final_xor
        self.reflect_in = reflect_in
        self.reflect_out = reflect_out

    def gen_table(self):
        root_path = test_dir = os.path.abspath(".")
        gen_path = os.path.join(root_path, "gen")
        file_prefix = os.path.join(gen_path, "crc_tab")

        tab_init_val = 0
        tab_final_xor = 0
        crc_tab = CrcLookUpTable(
            self.poly.to_bytes(self.crc_byte_width, "big"),
            tab_init_val.to_bytes(self.crc_byte_width, "big"),
            tab_final_xor.to_bytes(self.crc_byte_width, "big"),
            False,
            False,
        )

        os.system("mkdir -p gen")
        crc_tab.gen_crc_tab_file(file_prefix, range(self.input_byte_width))

    def gen_verilog(self):
        root_path = test_dir = os.path.abspath(".")
        gen_path = os.path.join(root_path, "gen")
        bsv_file = "CrcRawAxiStreamCustom.bsv"
        module = "mkCrcRawAxiStreamCustom"
        makefile = os.path.join(root_path, "test", "cocotb", "Makefile")

        macros = [f"CRC_WIDTH={self.crc_width}"]
        macros.append(f"KEEP_WIDTH={self.input_byte_width}")
        macros.append(f"POLY={self.poly}")
        macros.append(f"INIT_VAL={self.init_val}")
        macros.append(f"FINAL_XOR={self.final_xor}")
        macros.append(f"REFLECT_IN={self.reflect_in}")
        macros.append(f"REFLECT_OUT={self.reflect_out}")
        macro_args = list(map(lambda x: "-D " + x, macros))
        macro_args = reduce(lambda x, y: x + " " + y, macro_args)
        macro_args = '"' + macro_args + '"'

        make_args = []
        make_args.append(f"ROOT_DIR={root_path}")
        make_args.append(f"MACROFLAGS={macro_args}")
        make_args.append(f"FILE={bsv_file}")
        make_args.append(f"TOP={module}")
        make_args.append(f"VLOGDIR={gen_path}")
        make_args = reduce(lambda x, y: x + " " + y, make_args)

        os.system("mkdir -p gen")
        os.system(f"make -f {makefile} verilog {make_args}")
        os.system("rm -rf build")


if __name__ == "__main__":
    crcConf = CrcAxiStreamConfig(
        CRC_WIDTH,
        INPUT_WIDTH,
        POLYNOMINAL,
        INIT_VALUE,
        FINAL_XOR,
        REFLECT_INPUT,
        REFLECT_OUTPUT,
    )
    crcConf.gen_verilog()
    crcConf.gen_table()
