import FIFOF :: *;
import Randomizable :: *;
import CRC :: *;
import Vector :: *;
import GetPut :: *;
import Connectable :: *;

import CRCAxiStream :: *;
import CRC8AxiStream :: *;
import TestCRCAxiStream :: *;
import TestUtils :: *;

typedef 16 CYCLE_COUNT_WIDTH;
typedef 50000 MAX_CYCLE;
typedef 32 CASE_NUM;
typedef 8 CASE_COUNT_WIDTH;
typedef 133 CASE_BYTE_WIDTH;

(* synthesize *)
module mkTestCRC8AxiStream64 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS64_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC8AxiStream128 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS128_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC8AxiStream256 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS256_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCRC8AxiStream512 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    TestCRCAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS512_KEEP_WIDTH
    ) testConfig = TestCRCAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCRCAxiStream(testConfig);
endmodule