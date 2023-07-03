import CrcAxiStream :: *;
import CrcRawAxiStream :: *;

import AxiStreamTypes :: *;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of the CRC-32 (IEEE 802.3) standard
/// (x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1)
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef CrcAxiStream#(CRC32_WIDTH, AXIS64_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32AxiStream64;
(* synthesize *)
module mkCrc32AxiStream64(Crc32AxiStream64);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32AxiStream64 crc32 <- mkCrcAxiStream(conf);
    return crc32;
endmodule

typedef CrcRawAxiStream#(CRC32_WIDTH, AXIS64_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32RawAxiStream64;
(* synthesize *)
module mkCrc32RawAxiStream64(Crc32RawAxiStream64);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32RawAxiStream64 crc32 <- mkCrcRawAxiStream(conf);
    return crc32;
endmodule


typedef CrcAxiStream#(CRC32_WIDTH, AXIS128_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32AxiStream128;
(* synthesize *)
module mkCrc32AxiStream128(Crc32AxiStream128);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32AxiStream128 crc32 <- mkCrcAxiStream(conf);
    return crc32;
endmodule

typedef CrcRawAxiStream#(CRC32_WIDTH, AXIS128_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32RawAxiStream128;
(* synthesize *)
module mkCrc32RawAxiStream128(Crc32RawAxiStream128);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32RawAxiStream128 crc32 <- mkCrcRawAxiStream(conf);
    return crc32;
endmodule


typedef CrcAxiStream#(CRC32_WIDTH, AXIS256_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32AxiStream256;
(* synthesize *)
module mkCrc32AxiStream256(Crc32AxiStream256);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32AxiStream256 crc32 <- mkCrcAxiStream(conf);
    return crc32;
endmodule

typedef CrcRawAxiStream#(CRC32_WIDTH, AXIS256_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32RawAxiStream256;
(* synthesize *)
module mkCrc32RawAxiStream256(Crc32RawAxiStream256);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32RawAxiStream256 crc32 <- mkCrcRawAxiStream(conf);
    return crc32;
endmodule


typedef CrcAxiStream#(CRC32_WIDTH, AXIS512_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32AxiStream512;
(* synthesize *)
module mkCrc32AxiStream512(Crc32AxiStream512);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32AxiStream512 crc32 <- mkCrcAxiStream(conf);
    return crc32;
endmodule

typedef CrcRawAxiStream#(CRC32_WIDTH, AXIS512_KEEP_WIDTH, AXIS_USER_WIDTH) Crc32RawAxiStream512;
(* synthesize *)
module mkCrc32RawAxiStream512(Crc32RawAxiStream512);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC32_IEEE_POLY)),
        initVal    : fromInteger(valueOf(CRC32_IEEE_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC32_IEEE_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc32RawAxiStream512 crc32 <- mkCrcRawAxiStream(conf);
    return crc32;
endmodule
