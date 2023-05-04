import CRCAxiStream :: *;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of the CRC-32 (IEEE 802.3) standard
/// (x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1)
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef CRCAxiStream#(CRC32_WIDTH, AXIS64_KEEP_WIDTH, AXIS64_WIDTH) CRC32AxiStream64;
(* synthesize *)
module mkCRC32AxiStream64(CRC32AxiStream64);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: 'h04C11DB7,
        initVal    : 'hFFFFFFFF,
        finalXor   : 'hFFFFFFFF,
        reflectData: True,
        reflectRemainder: True
    };

    CRC32AxiStream64 crc32 <- mkCRCAxiStream(conf);
    return crc32;
endmodule


typedef CRCAxiStream#(CRC32_WIDTH, AXIS128_KEEP_WIDTH, AXIS128_WIDTH) CRC32AxiStream128;
(* synthesize *)
module mkCRC32AxiStream128(CRC32AxiStream128);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: 'h04C11DB7,
        initVal    : 'hFFFFFFFF,
        finalXor   : 'hFFFFFFFF,
        reflectData: True,
        reflectRemainder: True
    };

    CRC32AxiStream128 crc32 <- mkCRCAxiStream(conf);
    return crc32;
endmodule


typedef CRCAxiStream#(CRC32_WIDTH, AXIS256_KEEP_WIDTH, AXIS256_WIDTH) CRC32AxiStream256;
(* synthesize *)
module mkCRC32AxiStream256(CRC32AxiStream256);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: 'h04C11DB7,
        initVal    : 'hFFFFFFFF,
        finalXor   : 'hFFFFFFFF,
        reflectData: True,
        reflectRemainder: True
    };

    CRC32AxiStream256 crc32 <- mkCRCAxiStream(conf);
    return crc32;
endmodule


typedef CRCAxiStream#(CRC32_WIDTH, AXIS512_KEEP_WIDTH, AXIS512_WIDTH) CRC32AxiStream512;
(* synthesize *)
module mkCRC32AxiStream512(CRC32AxiStream512);
    CrcConfig#(CRC32_WIDTH) conf = CrcConfig {
        polynominal: 'h04C11DB7,
        initVal    : 'hFFFFFFFF,
        finalXor   : 'hFFFFFFFF,
        reflectData: True,
        reflectRemainder: True
    };

    CRC32AxiStream512 crc32 <- mkCRCAxiStream(conf);
    return crc32;
endmodule
