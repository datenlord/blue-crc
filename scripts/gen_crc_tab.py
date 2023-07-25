import os
import sys
import json


def bits_reverse(val: int, width: int):
    result = 0
    for i in range(width):
        result <<= 1
        result |= val & 1
        val >>= 1
    return result


def bits_left_shift(val: int, width: int, amt: int):
    mask = (1 << width) - 1
    return (val << amt) & mask


def bits_msb(val: int, width: int):
    return val >> (width - 1)


class CrcCalculator:
    def __init__(
        self,
        width: int,
        polynomial: int,
        init_value: int,
        final_xor_value: int,
        reverse_input: bool,
        reverse_output: bool,
    ):
        self.width = width
        self.byte_width = 8
        self.byte_num = int(width / self.byte_width)
        assert (
            width % self.byte_width == 0
        ), f"The width of {width}-bits is not supported"
        self.max_crc_value = pow(2, width)

        self.polynomial = polynomial
        self.init_value = init_value
        self.final_xor_value = final_xor_value
        self.reverse_input = reverse_input
        self.reverse_output = reverse_output
        assert (
            polynomial < self.max_crc_value
        ), "The value of polynominal is out of bound"
        assert (
            init_value < self.max_crc_value
        ), "The value of init_value is out of bound"
        assert (
            final_xor_value < self.max_crc_value
        ), "The value of final_xor_value is out of bound"

    def add_one_byte(self, byte_int: int):
        if self.reverse_input:
            byte_int = bits_reverse(byte_int, self.byte_width)

        byte_int = byte_int << (self.width - self.byte_width)
        crc_result = self.crc_result
        crc_result = crc_result ^ byte_int

        for i in range(self.byte_width):
            if bits_msb(crc_result, self.width):
                crc_result = bits_left_shift(crc_result, self.width, 1)
                crc_result = crc_result ^ self.polynomial
            else:
                crc_result = bits_left_shift(crc_result, self.width, 1)

        self.crc_result = crc_result

    def get_crc_result(self, raw_data: bytes):
        self.crc_result = self.init_value

        for byte in raw_data:
            self.add_one_byte(byte)

        if self.reverse_output:
            self.crc_result = bits_reverse(self.crc_result, self.width)

        self.crc_result = self.crc_result ^ self.final_xor_value
        return self.crc_result


class CrcLookUpTabGenerator:
    def __init__(
        self,
        crc_width: int,
        polynomial: int,
        max_byte_offset: int,
        file_path: str,
        file_prefix: str,
    ):
        self.crc_width = crc_width
        self.byte_width = 8
        self.crc_byte_num = int(crc_width / self.byte_width)
        self.max_byte_offset = max_byte_offset
        self.file_path = file_path
        self.file_prefix = file_prefix
        self.crc_calculator = CrcCalculator(
            width=crc_width,
            polynomial=polynomial,
            init_value=0,
            final_xor_value=0,
            reverse_input=False,
            reverse_output=False,
        )

    def gen_crc_tab_for_one_byte(self, byte_offset: int):
        crc_tab = []
        for i in range(pow(2, self.byte_width)):
            if byte_offset < self.crc_byte_num:
                crc_result = i << (self.byte_width * byte_offset)
            else:
                shift_amt = byte_offset - self.crc_byte_num
                raw_data = i << (self.byte_width * (shift_amt))
                raw_data = raw_data.to_bytes(shift_amt + 1, "big")
                crc_result = self.crc_calculator.get_crc_result(raw_data)

            crc_tab.append(crc_result)

        return crc_tab

    def gen_crc_tab_files(self):
        for i in range(self.max_byte_offset):
            file_name = os.path.join(self.file_path, self.file_prefix)
            file_name = file_name + f"_{i}.mem"
            file = open(file_name, "w")
            crc_tab = self.gen_crc_tab_for_one_byte(i)
            for crc in crc_tab:
                file.write(hex(crc)[2:] + "\n")
            file.close()


if __name__ == "__main__":
    assert (
        len(sys.argv) == 3
    ), "Usage: python3 gen_crc_tab.py JSON_CONFIG_FILE TARGET_DIR"

    arg = sys.argv
    json_file_path = arg[1]
    output_path = arg[2]

    with open(json_file_path) as json_file:
        crc_config = json.load(json_file)

    crc_width = crc_config["crc_width"]
    polynomial = int(crc_config["polynomial"], 16)
    axi_keep_width = crc_config["axi_keep_width"]
    max_byte_offset = axi_keep_width + 4
    file_prefix = crc_config["mem_file_prefix"]

    tab_generator = CrcLookUpTabGenerator(
        crc_width, polynomial, max_byte_offset, output_path, file_prefix
    )

    tab_generator.gen_crc_tab_files()
