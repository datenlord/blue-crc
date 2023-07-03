import CrcAxiStream :: *;
import CrcRawAxiStream :: *;

typedef CrcRawAxiStream#(`CRC_WIDTH, `KEEP_WIDTH, `DATA_WIDTH) CrcRawAxiStreamCustom;
(* synthesize *)
module mkCrcRawAxiStreamCustom(CrcRawAxiStreamCustom);
    CrcConfig#(`CRC_WIDTH) conf = CrcConfig {
        polynominal: `POLY,
        initVal    : `INIT_VAL,
        finalXor   : `FINAL_XOR,
        reflectData: `REFLECT_IN,
        reflectRemainder: `REFLECT_OUT
    };

    CrcRawAxiStreamCustom crc <- mkCrcRawAxiStream(conf);
    return crc;
endmodule

