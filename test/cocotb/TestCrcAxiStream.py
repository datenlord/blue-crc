import os
import sys
import json
import random
import logging
from queue import Queue

import crc
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

import cocotb_test.simulator
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamFrame
from cocotbext.axi.stream import define_stream

(
    CrcStreamBus,
    CrcStreamTransation,
    CrcStreamSource,
    CrcStreamSink,
    CrcStreamMonitor,
) = define_stream("CrcStream", signals=["valid", "ready", "data"])


class CrcAxiStreamTester:
    def __init__(
        self,
        dut,
        cases_num: int,
        case_max_size: int,
        pause_rate: float,
        crc_conf: crc.Configuration,
        crc_mode: str,
    ):
        assert pause_rate < 1, "Pause rate is out of range"
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.WARNING)

        self.cases_num = cases_num
        self.case_max_size = case_max_size
        self.pause_rate = pause_rate
        self.ref_rawdata_buf = Queue(maxsize=self.cases_num)
        self.ref_checksum_buf = Queue(maxsize=self.cases_num)
        self.crc_conf = crc_conf
        self.ref_model = crc.Calculator(crc_conf)
        self.crc_mode = crc_mode

        self.clock = self.dut.CLK
        self.reset = self.dut.RST_N
        self.axi_stream_src = AxiStreamSource(
            AxiStreamBus.from_prefix(dut, "s_axis"), self.clock, self.reset, False
        )
        self.crc_stream_sink = CrcStreamSink(
            CrcStreamBus.from_prefix(dut, "m_crc_stream"), self.clock, self.reset, False
        )

        self.axi_stream_src.log.setLevel(logging.WARNING)
        self.crc_stream_sink.log.addHandler(logging.WARNING)

    async def random_pause(self):
        self.log.info("Start random pause successfully")
        while True:
            src_rand = random.random()
            sink_rand = random.random()
            self.axi_stream_src.pause = src_rand < self.pause_rate
            self.crc_stream_sink.pause = sink_rand < self.pause_rate
            await RisingEdge(self.clock)

    async def gen_clock(self):
        await cocotb.start(Clock(self.clock, 10, "ns").start())
        self.log.info("Start dut clock")

    async def gen_reset(self):
        self.reset.setimmediatevalue(0)
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        self.reset.value = 1
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        await RisingEdge(self.clock)
        self.log.info("Complete reset dut")

    def gen_random_test_case(self):
        data_size = random.randint(1, self.case_max_size)
        raw_data = random.randbytes(data_size)
        check_sum = self.ref_model.checksum(raw_data)
        if self.crc_mode == "CRC_MODE_RECV":
            crc_byte_num = int(self.crc_conf.width / 8)
            zero_bytes = crc_byte_num * b"\x00"
            raw_data = raw_data + zero_bytes
        return (raw_data, check_sum)

    async def drive_dut_input(self):
        for case_idx in range(self.cases_num):
            raw_data, check_sum = self.gen_random_test_case()
            frame = AxiStreamFrame(tdata=raw_data)
            await self.axi_stream_src.send(frame)
            self.ref_rawdata_buf.put(raw_data)
            self.ref_checksum_buf.put(check_sum)
            raw_data = raw_data.hex("-")
            self.log.info(
                f"Drive dut {case_idx} case: rawdata={raw_data} checksum={check_sum}"
            )

    async def check_dut_output(self):
        for case_idx in range(self.cases_num):
            dut_crc = await self.crc_stream_sink.recv()
            dut_crc = int(dut_crc.data)
            ref_crc = self.ref_checksum_buf.get()
            ref_raw = self.ref_rawdata_buf.get()
            self.log.info(
                f"Recv dut {case_idx} case:\ndut_crc = {dut_crc}\nref_crc = {ref_crc}"
            )
            assert dut_crc == ref_crc, "The results of dut and ref are inconsistent"

    async def runCrcAxiStreamTester(self):
        await self.gen_clock()
        await self.gen_reset()
        drive_thread = cocotb.start_soon(self.drive_dut_input())
        check_thread = cocotb.start_soon(self.check_dut_output())
        await cocotb.start(self.random_pause())
        self.log.info("Start testing!")
        await check_thread
        self.log.info(f"Pass all {self.cases_num} successfully")


@cocotb.test(timeout_time=5000000, timeout_unit="ns")
async def runCrcAxiStreamTester(dut):
    json_file_path = os.getenv("JSON_CONF_FILE")
    with open(json_file_path) as json_file:
        crc_config = json.load(json_file)

    crc_width = crc_config["crc_width"]
    polynomial = int(crc_config["polynomial"], 16)
    init_value = int(crc_config["init_value"], 16)
    final_xor = int(crc_config["final_xor"], 16)
    reverse_input = crc_config["reverse_input"]
    reverse_output = crc_config["reverse_output"]
    crc_mode = crc_config["crc_mode"]

    crc_conf = crc.Configuration(
        width=crc_width,
        polynomial=polynomial,
        init_value=init_value,
        final_xor_value=final_xor,
        reverse_input=reverse_input,
        reverse_output=reverse_output,
    )
    tester = CrcAxiStreamTester(
        dut=dut,
        cases_num=1000,
        case_max_size=1024,
        pause_rate=0.3,
        crc_conf=crc_conf,
        crc_mode=crc_mode,
    )
    await tester.runCrcAxiStreamTester()


def testCrcAxiStream():
    assert len(sys.argv) == 2
    json_file_path = sys.argv[1]

    # set parameters used to run tests
    toplevel = "mkCrcRawAxiStreamCustom"
    module = os.path.splitext(os.path.basename(__file__))[0]
    test_dir = os.path.abspath(os.path.dirname(__file__))
    sim_build = os.path.join(test_dir, "build")
    v_top_file = os.path.join(test_dir, "verilog", f"{toplevel}.v")
    verilog_sources = [v_top_file]
    extra_env = {"JSON_CONF_FILE": json_file_path}

    cocotb_test.simulator.run(
        toplevel=toplevel,
        module=module,
        verilog_sources=verilog_sources,
        python_search=test_dir,
        sim_build=sim_build,
        timescale="1ns/1ps",
        extra_env=extra_env,
    )


if __name__ == "__main__":
    testCrcAxiStream()
