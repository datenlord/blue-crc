import CrcDefines :: *;
import CrcAxiStream :: *;

typedef CrcAxiStream#(`CRC_WIDTH, `AXI_KEEP_WIDTH) CrcAxiStreamCustom;
(* synthesize *)
module mkCrcAxiStreamCustom(CrcAxiStreamCustom);
    CrcConfig#(`CRC_WIDTH) conf = CrcConfig {
        polynominal: `POLY,
        initVal: `INIT_VAL,
        finalXor: `FINAL_XOR,
        revInput: `REV_INPUT,
        revOutput: `REV_OUTPUT,
        memFilePrefix: `MEM_FILE_PREFIX,
        crcMode: `CRC_MODE
    };

    CrcAxiStreamCustom crc <- mkCrcAxiStream(conf);
    return crc;
endmodule


typedef CrcRawAxiStream#(`CRC_WIDTH, `AXI_KEEP_WIDTH) CrcRawAxiStreamCustom;
(* synthesize *)
module mkCrcRawAxiStreamCustom(CrcRawAxiStreamCustom);
    CrcConfig#(`CRC_WIDTH) conf = CrcConfig {
        polynominal: `POLY,
        initVal: `INIT_VAL,
        finalXor: `FINAL_XOR,
        revInput: `REV_INPUT,
        revOutput: `REV_OUTPUT,
        memFilePrefix: `MEM_FILE_PREFIX,
        crcMode: `CRC_MODE
    };

    CrcRawAxiStreamCustom crc <- mkCrcRawAxiStream(conf);
    return crc;
endmodule

