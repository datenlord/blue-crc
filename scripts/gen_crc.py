import os
import sys
import json
from functools import reduce


def gen_verilog(conf_file_path, verilog_dir, table_dir):
    with open(conf_file_path) as json_file:
        crc_config = json.load(json_file)

    crc_width = crc_config["crc_width"]
    axi_keep_width = crc_config["axi_keep_width"]
    polynomial = int(crc_config["polynomial"], 16)
    init_value = int(crc_config["init_value"], 16)
    final_xor = int(crc_config["final_xor"], 16)
    reverse_input = crc_config["reverse_input"]

    if reverse_input:
        reverse_input = "BIT_ORDER_REVERSE"
    else:
        reverse_input = "BIT_ORDER_NOT_REVERSE"

    reverse_output = crc_config["reverse_output"]
    if reverse_output:
        reverse_output = "BIT_ORDER_REVERSE"
    else:
        reverse_output = "BIT_ORDER_NOT_REVERSE"

    mem_file_prefix = crc_config["mem_file_prefix"]
    crc_mode = crc_config["crc_mode"]

    root_dir = os.path.abspath(".")

    macros = [f"JSON_CONF_FILE={conf_file_path}"]
    macros.append(f"CRC_WIDTH={crc_width}")
    macros.append(f"AXI_KEEP_WIDTH={axi_keep_width}")
    macros.append(f"POLY={polynomial}")
    macros.append(f"INIT_VAL={init_value}")
    macros.append(f"FINAL_XOR={final_xor}")
    macros.append(f"REV_INPUT={reverse_input}")
    macros.append(f"REV_OUTPUT={reverse_output}")
    macros.append(f"MEM_FILE_PREFIX={mem_file_prefix}")
    macros.append(f"CRC_MODE={crc_mode}")
    macros.append(f"ROOT_DIR={root_dir}")
    macros.append(f"VLOGDIR={verilog_dir}")
    macros.append(f"TABDIR={table_dir}")

    make_args = reduce(lambda x, y: x + " " + y, macros)
    makefile_path = f"{root_dir}/test/cocotb/Makefile"
    os.system(f"rm -rf {verilog_dir} {table_dir}")
    result = os.system(f"make verilog -f {makefile_path} {make_args}")
    os.system(f"rm -rf build")
    return result


if __name__ == "__main__":
    assert (
        len(sys.argv) >= 2
    ), "Usage: python3 gen_crc.py JSON_CONFIG_FILE [VLOGDIR] [TABDIR]"
    arg = sys.argv
    json_file_path = arg[1]
    verilog_dir = "verilog"
    table_dir = "verilog"
    if len(sys.argv) > 2:
        verilog_dir = arg[2]
    if len(sys.argv) > 3:
        table_dir = arg[3]
    result = gen_verilog(json_file_path, verilog_dir, table_dir)
    assert result == 0, "The generation of CRC hardware failed."
