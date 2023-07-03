import sys
import os
import crc
import cocotb_test.simulator
import cocotb

from CrcAxiStreamTester import CrcAxiStreamTester

CASES_NUM = 1000
CASE_MAX_SIZE = 512
PAUSE_RATE = 0.3

CRC8_WIDTH = 8
CRC16_WIDTH = 16
CRC32_WIDTH = 32

CRC8_CCITT_POLY = 0x07
CRC16_ANSI_POLY = 0x8005
CRC32_IEEE_POLY = 0x04C11DB7

CRC8_CCITT_INIT_VAL = 0x00
CRC16_ANSI_INIT_VAL = 0x0000
CRC32_IEEE_INIT_VAL = 0xFFFFFFFF

CRC8_CCITT_FINAL_XOR = 0x00
CRC16_ANSI_FINAL_XOR = 0x0000
CRC32_IEEE_FINAL_XOR = 0xFFFFFFFF


@cocotb.test(timeout_time=5000000, timeout_unit="ns")
async def testCrc8AxiStream(dut):
    crc_conf = crc.Configuration(
        width=CRC8_WIDTH,
        polynomial=CRC8_CCITT_POLY,
        init_value=CRC8_CCITT_INIT_VAL,
        final_xor_value=CRC8_CCITT_FINAL_XOR,
        reverse_input=False,
        reverse_output=False,
    )
    ref_model = crc.Calculator(crc_conf)
    tester = CrcAxiStreamTester(dut, CASES_NUM, CASE_MAX_SIZE, PAUSE_RATE, ref_model)
    await tester.runCrcAxiStreamTester()


@cocotb.test(timeout_time=5000000, timeout_unit="ns")
async def testCrc16AxiStream(dut):
    crc_conf = crc.Configuration(
        width=CRC16_WIDTH,
        polynomial=CRC16_ANSI_POLY,
        init_value=CRC16_ANSI_INIT_VAL,
        final_xor_value=CRC16_ANSI_FINAL_XOR,
        reverse_input=True,
        reverse_output=True,
    )
    ref_model = crc.Calculator(crc_conf)
    tester = CrcAxiStreamTester(dut, CASES_NUM, CASE_MAX_SIZE, PAUSE_RATE, ref_model)
    await tester.runCrcAxiStreamTester()


@cocotb.test(timeout_time=5000000, timeout_unit="ns")
async def testCrc32AxiStream(dut):
    crc_conf = crc.Configuration(
        width=CRC32_WIDTH,
        polynomial=CRC32_IEEE_POLY,
        init_value=CRC32_IEEE_INIT_VAL,
        final_xor_value=CRC32_IEEE_FINAL_XOR,
        reverse_input=True,
        reverse_output=True,
    )
    ref_model = crc.Calculator(crc_conf)
    tester = CrcAxiStreamTester(dut, CASES_NUM, CASE_MAX_SIZE, PAUSE_RATE, ref_model)
    await tester.runCrcAxiStreamTester()


def testCrcAxiStream():
    crc_width_opt = (CRC8_WIDTH, CRC16_WIDTH, CRC32_WIDTH)
    # Parse input arguments
    assert len(sys.argv) == 3, "The number of input arguments is incorrect."
    args = sys.argv
    crc_width = int(args[1])
    assert (
        crc_width in crc_width_opt
    ), f"Table generation of {crc_width}-bit hasn't been supported."
    axi_width = int(args[2])
    assert axi_width % 8 == 0, f"The width of input data must be multiples of 8 bits."
    axi_byte_num = int(axi_width / 8)

    # set parameters used to run tests
    toplevel = f"mkCrc{crc_width}RawAxiStream{axi_width}"
    test_func = f"testCrc{crc_width}AxiStream"
    module = os.path.splitext(os.path.basename(__file__))[0]
    test_dir = os.path.abspath(os.path.dirname(__file__))
    sim_build = os.path.join(test_dir, "build")
    v_top_file = os.path.join(test_dir, "generated", f"{toplevel}.v")
    verilog_sources = [v_top_file]

    cocotb_test.simulator.run(
        toplevel=toplevel,
        module=module,
        verilog_sources=verilog_sources,
        python_search=test_dir,
        sim_build=sim_build,
        timescale="1ns/1ps",
        testcase=test_func,
        work_dir=test_dir,
    )


if __name__ == "__main__":
    testCrcAxiStream()
