import GetPut :: *;

import SemiFifo :: *;
import AxiStreamTypes :: *;

////////////////////////////////////////////////////////////////////////////////
////////// Definition of some common types
////////////////////////////////////////////////////////////////////////////////
typedef  8 BYTE_WIDTH;
typedef 16 WORD_WIDTH;
typedef Bit#(BYTE_WIDTH) Byte;
typedef Bit#(WORD_WIDTH) Word;

typedef Bit#(width) CrcResult#(numeric type width);

// Configuration of CRC hardware implementation
typedef enum {
    CRC_MODE_RECV,
    CRC_MODE_SEND
} CrcMode deriving(Eq, FShow);

typedef enum {
    BIT_ORDER_REVERSE,
    BIT_ORDER_NOT_REVERSE
} IsReverseBitOrder deriving(Eq, FShow);

typedef struct {
    Bit#(crcWidth) polynominal;
    Bit#(crcWidth) initVal;
    Bit#(crcWidth) finalXor;
    IsReverseBitOrder revInput;
    IsReverseBitOrder revOutput;
    String memFilePrefix;
    CrcMode crcMode;
} CrcConfig#(numeric type crcWidth) deriving(Eq, FShow);

typedef FifoOut#(CrcResult#(crcWidth)) CrcResultFifoOut#(numeric type crcWidth);
typedef FifoOut#(AxiStream#(keepWidth, AXIS_USER_WIDTH)) AxiStreamFifoOut#(numeric type keepWidth); 
typedef Get#(CrcResult#(crcWidth)) CrcResultGet#(numeric type crcWidth);
typedef Put#(AxiStream#(keepWidth, AXIS_USER_WIDTH)) AxiStreamPut#(numeric type keepWidth);


typedef  8 CRC8_WIDTH;
typedef 16 CRC16_WIDTH;
typedef 32 CRC32_WIDTH;

typedef   1 AXIS_USER_WIDTH;

typedef  8 AXIS64_KEEP_WIDTH;
typedef 16 AXIS128_KEEP_WIDTH;
typedef 32 AXIS256_KEEP_WIDTH;
typedef 64 AXIS512_KEEP_WIDTH;

typedef 8'h07        CRC8_CCITT_POLY;
typedef 16'h8005     CRC16_ANSI_POLY;
typedef 32'h04C11DB7 CRC32_IEEE_POLY;

typedef 8'h00        CRC8_CCITT_INIT_VAL;
typedef 16'h0000     CRC16_ANSI_INIT_VAL;
typedef 32'hFFFFFFFF CRC32_IEEE_INIT_VAL;

typedef 8'h00        CRC8_CCITT_FINAL_XOR;
typedef 16'h0000     CRC16_ANSI_FINAL_XOR;
typedef 32'hFFFFFFFF CRC32_IEEE_FINAL_XOR;
