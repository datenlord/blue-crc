import os
import sys
import json
from functools import reduce


def run_vivado(conf_file_path):
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
    conf_file_prefix = os.path.basename(conf_file_path)
    conf_file_prefix = os.path.splitext(conf_file_prefix)[0]
    print(
        f"Run Vivado on: crc_width={crc_width} axi_keep_width={axi_keep_width} crc_mode={crc_mode}"
    )

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
    macros.append(f"SUB_OUTPUTDIR={conf_file_prefix}")

    make_args = reduce(lambda x, y: x + " " + y, macros)
    os.system("rm -rf build verilog *.mem")
    result = os.system(f"make {make_args}")
    return result


if __name__ == "__main__":
    if len(sys.argv) == 2:
        conf_file_path = sys.argv[1]
        conf_file_path = os.path.abspath(conf_file_path)
        run_vivado(conf_file_path)
    else:
        config_dir = os.path.abspath("../../scripts/config")
        for root, dirs, files in os.walk(config_dir):
            for file_name in files:
                conf_file_path = os.path.join(root, file_name)
                result = run_vivado(conf_file_path)
                info = f"Run Vivado Failed on the configuration of {file_name}."
                assert result == 0, info
