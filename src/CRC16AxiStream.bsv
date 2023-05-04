import CRCAxiStream :: *;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of the CRC-16-ANSI standard (x^16 + x^15 + x^2 + 1)
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef CRCAxiStream#(CRC16_WIDTH, AXIS64_KEEP_WIDTH, AXIS64_WIDTH) CRC16AxiStream64;
(* synthesize *)
module mkCRC16AxiStream64(CRC16AxiStream64);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    CRC16AxiStream64 crc16 <- mkCRCAxiStream(conf);
    return crc16;
endmodule


typedef CRCAxiStream#(CRC16_WIDTH, AXIS128_KEEP_WIDTH, AXIS128_WIDTH) CRC16AxiStream128;
(* synthesize *)
module mkCRC16AxiStream128(CRC16AxiStream128);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    CRC16AxiStream128 crc16 <- mkCRCAxiStream(conf);
    return crc16;
endmodule


typedef CRCAxiStream#(CRC16_WIDTH, AXIS256_KEEP_WIDTH, AXIS256_WIDTH) CRC16AxiStream256;
(* synthesize *)
module mkCRC16AxiStream256(CRC16AxiStream256);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    CRC16AxiStream256 crc16 <- mkCRCAxiStream(conf);
    return crc16;
endmodule


typedef CRCAxiStream#(CRC16_WIDTH, AXIS512_KEEP_WIDTH, AXIS512_WIDTH) CRC16AxiStream512;
(* synthesize *)
module mkCRC16AxiStream512(CRC16AxiStream512);
    CrcConfig#(CRC16_WIDTH) conf = CrcConfig {
        polynominal: 'h8005,
        initVal    : 'h0000,
        finalXor   : 'h0000,
        reflectData: True,
        reflectRemainder: True
    };

    CRC16AxiStream512 crc16 <- mkCRCAxiStream(conf);
    return crc16;
endmodule
