import CRCAxiStream :: *;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///
/// Implementation of the CRC-8-CCITT standard (x^8 + x^2 + x^1 + 1)
///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef CRCAxiStream#(CRC8_WIDTH, AXIS64_KEEP_WIDTH, AXIS64_WIDTH) CRC8AxiStream64;
(* synthesize *)
module mkCRC8AxiStream64(CRC8AxiStream64);
    CrcConfig#(CRC8_WIDTH) conf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    CRC8AxiStream64 crc8 <- mkCRCAxiStream(conf);
    return crc8;
endmodule


typedef CRCAxiStream#(CRC8_WIDTH, AXIS128_KEEP_WIDTH, AXIS128_WIDTH) CRC8AxiStream128;
(* synthesize *)
module mkCRC8AxiStream128(CRC8AxiStream128);
    CrcConfig#(CRC8_WIDTH) conf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    CRC8AxiStream128 crc8 <- mkCRCAxiStream(conf);
    return crc8;
endmodule


typedef CRCAxiStream#(CRC8_WIDTH, AXIS256_KEEP_WIDTH, AXIS256_WIDTH) CRC8AxiStream256;
(* synthesize *)
module mkCRC8AxiStream256(CRC8AxiStream256);
    CrcConfig#(CRC8_WIDTH) conf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    CRC8AxiStream256 crc8 <- mkCRCAxiStream(conf);
    return crc8;
endmodule


typedef CRCAxiStream#(CRC8_WIDTH, AXIS512_KEEP_WIDTH, AXIS512_WIDTH) CRC8AxiStream512;
(* synthesize *)
module mkCRC8AxiStream512(CRC8AxiStream512);
    CrcConfig#(CRC8_WIDTH) conf = CrcConfig {
        polynominal: 'h07,
        initVal    : 'h00,
        finalXor   : 'h00,
        reflectData: False,
        reflectRemainder: False
    };

    CRC8AxiStream512 crc8 <- mkCRCAxiStream(conf);
    return crc8;
endmodule
