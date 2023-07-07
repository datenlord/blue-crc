import FIFOF :: *;
import Randomizable :: *;
import CRC :: *;
import Vector :: *;
import GetPut :: *;
import Connectable :: *;

import CrcAxiStream :: *;
import Crc8AxiStream :: *;
import TestCrcAxiStream :: *;
import TestUtils :: *;

typedef 16 CYCLE_COUNT_WIDTH;
typedef 10000 MAX_CYCLE;
typedef 32 CASE_NUM;
typedef 8 CASE_COUNT_WIDTH;
typedef 133 CASE_BYTE_WIDTH;

(* synthesize *)
module mkTestCrc8AxiStream64 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC8_CCITT_POLY)),
        initVal    : fromInteger(valueOf(CRC8_CCITT_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC8_CCITT_FINAL_XOR)),
        reflectData: False,
        reflectRemainder: False,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS64_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc8AxiStream128 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC8_CCITT_POLY)),
        initVal    : fromInteger(valueOf(CRC8_CCITT_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC8_CCITT_FINAL_XOR)),
        reflectData: False,
        reflectRemainder: False,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS128_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc8AxiStream256 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC8_CCITT_POLY)),
        initVal    : fromInteger(valueOf(CRC8_CCITT_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC8_CCITT_FINAL_XOR)),
        reflectData: False,
        reflectRemainder: False,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS256_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule

(* synthesize *)
module mkTestCrc8AxiStream512 (Empty);

    CrcConfig#(CRC8_WIDTH) crcConf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC8_CCITT_POLY)),
        initVal    : fromInteger(valueOf(CRC8_CCITT_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC8_CCITT_FINAL_XOR)),
        reflectData: False,
        reflectRemainder: False,
        memFilePrefix: "crc_gen_tab"
    };

    TestCrcAxiStreamConfig#(
        CYCLE_COUNT_WIDTH,
        CASE_COUNT_WIDTH,
        CASE_BYTE_WIDTH,
        CRC8_WIDTH,
        AXIS512_KEEP_WIDTH
    ) testConfig = TestCrcAxiStreamConfig {
        maxCycle: fromInteger(valueOf(MAX_CYCLE)),
        caseNum: fromInteger(valueOf(CASE_NUM)),
        crcConfig: crcConf
    };

    mkTestCrcAxiStream(testConfig);
endmodule