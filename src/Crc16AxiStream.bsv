import CrcAxiStream :: *;
import CrcRawAxiStream :: *;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of the CRC-16-ANSI standard (x^16 + x^15 + x^2 + 1)
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef CrcAxiStream#(CRC16_WIDTH, AXIS64_KEEP_WIDTH, AXIS64_WIDTH) Crc16AxiStream64;
(* synthesize *)
module mkCrc16AxiStream64(Crc16AxiStream64);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16AxiStream64 crc16 <- mkCrcAxiStream(conf);
    return crc16;
endmodule
typedef CrcRawAxiStream#(CRC16_WIDTH, AXIS64_KEEP_WIDTH, AXIS64_WIDTH) Crc16RawAxiStream64;
(* synthesize *)
module mkCrc16RawAxiStream64(Crc16RawAxiStream64);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16RawAxiStream64 crc16 <- mkCrcRawAxiStream(conf);
    return crc16;
endmodule


typedef CrcAxiStream#(CRC16_WIDTH, AXIS128_KEEP_WIDTH, AXIS128_WIDTH) Crc16AxiStream128;
(* synthesize *)
module mkCrc16AxiStream128(Crc16AxiStream128);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16AxiStream128 crc16 <- mkCrcAxiStream(conf);
    return crc16;
endmodule

typedef CrcRawAxiStream#(CRC16_WIDTH, AXIS128_KEEP_WIDTH, AXIS128_WIDTH) Crc16RawAxiStream128;
(* synthesize *)
module mkCrc16RawAxiStream128(Crc16RawAxiStream128);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16RawAxiStream128 crc16 <- mkCrcRawAxiStream(conf);
    return crc16;
endmodule


typedef CrcAxiStream#(CRC16_WIDTH, AXIS256_KEEP_WIDTH, AXIS256_WIDTH) Crc16AxiStream256;
(* synthesize *)
module mkCrc16AxiStream256(Crc16AxiStream256);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16AxiStream256 crc16 <- mkCrcAxiStream(conf);
    return crc16;
endmodule

typedef CrcRawAxiStream#(CRC16_WIDTH, AXIS256_KEEP_WIDTH, AXIS256_WIDTH) Crc16RawAxiStream256;
(* synthesize *)
module mkCrc16RawAxiStream256(Crc16RawAxiStream256);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16RawAxiStream256 crc16 <- mkCrcRawAxiStream(conf);
    return crc16;
endmodule


typedef CrcAxiStream#(CRC16_WIDTH, AXIS512_KEEP_WIDTH, AXIS512_WIDTH) Crc16AxiStream512;
(* synthesize *)
module mkCrc16AxiStream512(Crc16AxiStream512);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16AxiStream512 crc16 <- mkCrcAxiStream(conf);
    return crc16;
endmodule

typedef CrcRawAxiStream#(CRC16_WIDTH, AXIS512_KEEP_WIDTH, AXIS512_WIDTH) Crc16RawAxiStream512;
(* synthesize *)
module mkCrc16RawAxiStream512(Crc16RawAxiStream512);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: fromInteger(valueOf(CRC16_ANSI_POLY)),
        initVal    : fromInteger(valueOf(CRC16_ANSI_INIT_VAL)),
        finalXor   : fromInteger(valueOf(CRC16_ANSI_FINAL_XOR)),
        reflectData: True,
        reflectRemainder: True
    };

    Crc16RawAxiStream512 crc16 <- mkCrcRawAxiStream(conf);
    return crc16;
endmodule
