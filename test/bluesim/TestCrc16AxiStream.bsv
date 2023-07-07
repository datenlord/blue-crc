import FIFOF :: *;
import Randomizable :: *;
import CRC :: *;
import Vector :: *;
import GetPut :: *;
import Connectable :: *;

import CrcAxiStream :: *;
import Crc16AxiStream :: *;
import TestCrcAxiStream :: *;
import TestUtils :: *;

typedef 16 CYCLE_COUNT_WIDTH;
typedef 50000 MAX_CYCLE;
typedef 32 CASE_NUM;
typedef 8 CASE_COUNT_WIDTH;
typedef 133 CASE_BYTE_WIDTH;

(* synthesize *)
module mkTestCrc16AxiStream64 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS64_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc16AxiStream128 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS128_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc16AxiStream256 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS256_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc16AxiStream512 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS512_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule