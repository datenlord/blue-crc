import FIFOF :: *;
import Randomizable :: *;
import CRC :: *;
import Vector :: *;
import GetPut :: *;
import Connectable :: *;

import CRCAxiStream :: *;
import CRC16AxiStream :: *;
import TestCRCAxiStream :: *;
import TestUtils :: *;

typedef 16 CYCLE_COUNT_WIDTH;
typedef 50000 MAX_CYCLE;
typedef 32 CASE_NUM;
typedef 8 CASE_COUNT_WIDTH;
typedef 133 CASE_BYTE_WIDTH;

(* synthesize *)
module mkTestCRC16AxiStream64 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS64_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC16AxiStream128 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS128_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC16AxiStream256 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS256_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC16AxiStream512 (Empty);

    CrcConfig#(CRC16_WIDTH) crcConf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC16_WIDTH,
        AXIS512_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule