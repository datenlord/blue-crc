import logging
import os
import random
from queue import Queue
import crc


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame
from cocotbext.axi.stream import define_stream

CrcStreamBus, CrcStreamTransation, CrcStreamSource, CrcStreamSink, CrcStreamMonitor = define_stream(
    "CrcStream", signals=["valid", "ready", "data"]
)

class CrcAxiStreamTester:
    def __init__(self, dut, cases_num:int, case_max_size:int, pause_rate:float, ref_model:crc.Calculator):
        assert pause_rate < 1, "Pause rate is out of range"
        self.dut = dut
        
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.WARNING)
        
        self.cases_num = cases_num
        self.case_max_size = case_max_size
        self.pause_rate = pause_rate
        self.ref_rawdata_buf  = Queue(maxsize = self.cases_num)
        self.ref_checksum_buf = Queue(maxsize = self.cases_num)
        self.ref_model = ref_model

        self.axi_stream_src = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axi_stream"), dut.clk, dut.reset_n, False)
        self.crc_stream_sink = CrcStreamSink(CrcStreamBus.from_prefix(dut, "m_crc_stream"), dut.clk, dut.reset_n, False)
        
        self.axi_stream_src.log.setLevel(logging.WARNING)
        self.crc_stream_sink.log.addHandler(logging.WARNING)

        
    async def random_pause(self):
        self.log.info("Start random pause successfully")
        while True:
            src_rand = random.random()
            sink_rand = random.random()
            self.axi_stream_src.pause = src_rand < self.pause_rate
            self.crc_stream_sink.pause = sink_rand < self.pause_rate
            await RisingEdge(self.dut.clk) 
        
    async def clock(self):
        await cocotb.start(Clock(self.dut.clk, 10, 'ns').start())
        self.log.info("Start dut clock")
        
    async def reset(self):
        self.dut.reset_n.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.reset_n.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.log.info("Complete reset dut")
    
    def gen_random_test_case(self):
        data_size = random.randint(1, self.case_max_size)
        raw_data = random.randbytes(data_size)
        check_sum = self.ref_model.checksum(raw_data)
        return (raw_data, check_sum)
    
    async def drive_dut_input(self):
        for case_idx in range(self.cases_num):
            raw_data, check_sum = self.gen_random_test_case()
            frame = AxiStreamFrame(tdata=raw_data)
            await self.axi_stream_src.send(frame)
            self.ref_rawdata_buf.put(raw_data)
            self.ref_checksum_buf.put(check_sum)
            raw_data = raw_data.hex('-')
            self.log.info(f"Drive dut {case_idx} case: rawdata={raw_data} checksum={check_sum}")
    
    async def check_dut_output(self):
        for case_idx in range(self.cases_num):
           dut_crc = await self.crc_stream_sink.recv()
           dut_crc = int(dut_crc.data)
           ref_crc = self.ref_checksum_buf.get()
           ref_raw = self.ref_rawdata_buf.get()
           self.log.info(f"Recv dut {case_idx} case:\ndut_crc = {dut_crc}\nref_crc = {ref_crc}")
           assert dut_crc == ref_crc, "The results of dut and ref are inconsistent"
           
    async def runCrcAxiStreamTester(self):
        await self.clock()
        await self.reset()
        drive_thread = cocotb.start_soon(self.drive_dut_input())
        check_thread = cocotb.start_soon(self.check_dut_output())
        await cocotb.start(self.random_pause())
        self.log.info("Start testing!")
        await check_thread
        self.log.info(f"Pass all {self.cases_num} successfully")

