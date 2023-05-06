import FIFOF :: *;
import RegFile :: *;
import Vector :: *;
import Printf :: *;
import GetPut :: *;

// Parameters that define a specific CRC calculator
// input data width (8b bit)
// crc width (8n bit)
// polynominal
// final xor
// reflect input data
// reflect remainder

////////////////////////////////////////////////////////////////////////////////
////////// Definition of some common types
////////////////////////////////////////////////////////////////////////////////
typedef 8 BYTE_WIDTH;
typedef Bit#(BYTE_WIDTH) Byte;

typedef Bit#(width) CrcResult#(numeric type width);

typedef struct {
    Bit#(dataWidth) tData;
    Bit#(keepWidth) tKeep;
    Bool tUser;
    Bool tLast;
} AxiStream#(numeric type keepWidth, numeric type dataWidth) deriving(Bits, Eq, FShow);

typedef struct {
    Bit#(width) polynominal;
    Bit#(width) initVal;
    Bit#(width) finalXor;
    Bool reflectData;
    Bool reflectRemainder;
} CrcConfig#(numeric type width) deriving(Bits, Eq, FShow);

typedef  8 CRC8_WIDTH;
typedef 16 CRC16_WIDTH;
typedef 32 CRC32_WIDTH;

typedef  64 AXIS64_WIDTH;
typedef 128 AXIS128_WIDTH;
typedef 256 AXIS256_WIDTH;
typedef 512 AXIS512_WIDTH;

typedef TDiv#(AXIS64_WIDTH,  BYTE_WIDTH)  AXIS64_KEEP_WIDTH;
typedef TDiv#(AXIS128_WIDTH, BYTE_WIDTH) AXIS128_KEEP_WIDTH;
typedef TDiv#(AXIS256_WIDTH, BYTE_WIDTH) AXIS256_KEEP_WIDTH;
typedef TDiv#(AXIS512_WIDTH, BYTE_WIDTH) AXIS512_KEEP_WIDTH;

typedef 8'h07        CRC8_CCITT_POLY;
typedef 16'h8005     CRC16_ANSI_POLY;
typedef 32'h04C11DB7 CRC32_IEEE_POLY;

typedef 8'h00        CRC8_CCITT_INIT_VAL;
typedef 16'h0000     CRC16_ANSI_INIT_VAL;
typedef 32'hFFFFFFFF CRC32_IEEE_INIT_VAL;

typedef 8'h00       CRC8_CCITT_FINAL_XOR;
typedef 16'h0000     CRC16_ANSI_FINAL_XOR;
typedef 32'hFFFFFFFF CRC32_IEEE_FINAL_XOR;


////////////////////////////////////////////////////////////////////////////////
////////// Implementation of utility functions used in the design
////////////////////////////////////////////////////////////////////////////////
module mkCrcRegFileTable#(Integer offset)(Integer idx, RegFile#(Byte, CrcResult#(width)) ifc);
    // $display("crc lookup tab offset: %d", offset);
    let initFile = sprintf("crc_tab_%d.dat", offset + idx);
    RegFile#(Byte, CrcResult#(width)) regFile <- mkRegFileFullLoad(initFile);
    return regFile;
endmodule

function CrcResult#(width) addCrc(CrcResult#(width) crc1, CrcResult#(width) crc2);
    return crc1 ^ crc2;
endfunction

function Bit#(width) swapEndian(Bit#(width) data) provisos(Mul#(BYTE_WIDTH, byteNum, width));
    Vector#(byteNum, Byte) dataVec = unpack(data);
    return pack(reverse(dataVec));
endfunction

function Bit#(width) reverseBitsOfEachByte(Bit#(width) data) provisos(Mul#(BYTE_WIDTH, byteNum, width));
    Vector#(byteNum, Byte) dataVec = unpack(data);
    Vector#(byteNum, Byte) revDataVec = map(reverseBits, dataVec);
    return pack(revDataVec);
endfunction

function Bit#(width) byteRightShift(Bit#(width) dataIn, Bit#(shiftAmtWidth) shiftAmt) 
    provisos(Mul#(BYTE_WIDTH, byteNum, width));
    Vector#(byteNum, Byte) dataInVec = unpack(dataIn);
    dataInVec = shiftOutFrom0(0, dataInVec, shiftAmt);
    return pack(dataInVec);
endfunction

function Bit#(width) byteLeftShift(Bit#(width) dataIn, Bit#(shiftAmtWidth) shiftAmt) 
    provisos(Mul#(BYTE_WIDTH, byteNum, width));
    
    Vector#(byteNum, Byte) dataInVec = unpack(dataIn);
    dataInVec = shiftOutFromN(0, dataInVec, shiftAmt);
    return pack(dataInVec);
endfunction

// function dType reduceBalancedTree(function dType func(dType a, dType b), Vector#(num, dType) vecIn) 
//     provisos(Add#(num, a__, 2), Log#(num, numLog));
//     // dType firstHalfRes;
//     // dType secondHalfRes;
//     // if (valueOf(firstHalf) >= 2) begin
//     //     Vector#(firstHalf, dType) firstHalfVec = take(vecIn);
//     //     firstHalfRes = reduceBalancedTree(func, firstHalfVec);
//     // end
//     // else begin
//     //     firstHalfRes = head(vecIn);
//     // end

//     // if (valueOf(secondHalf) >= 2) begin
//     //     Vector#(secondHalf, dType) secondHalfVec = drop(vecIn);
//     //     secondHalfRes = reduceBalancedTree(func, secondHalfVec);
//     // end
//     // else begin
//     //     secondHalfRes = last(vecIn);
//     // end

//     // return func(firstHalfRes, secondHalfRes);
// endfunction

typeclass ReduceBalancedTree#(numeric type num, type dType);
    function dType reduceBalancedTree(function dType op(dType a, dType b), Vector#(num, dType) vecIn);
endtypeclass

instance ReduceBalancedTree#(2, dType);
    function reduceBalancedTree(op, vecIn) = op(vecIn[0], vecIn[1]);
endinstance

instance ReduceBalancedTree#(1, dType);
    function reduceBalancedTree(op, vecIn) = vecIn[0];
endinstance

instance ReduceBalancedTree#(num, dType) 
    provisos(Div#(num, 2, firstHalf), Add#(firstHalf, secondHalf, num),
             ReduceBalancedTree#(firstHalf, dType), ReduceBalancedTree#(secondHalf, dType));
    function reduceBalancedTree(op, vecIn);
        Vector#(firstHalf, dType) firstHalfVec   = take(vecIn);
        Vector#(secondHalf, dType) secondHalfVec = drop(vecIn);
        let firstHalfRes  = reduceBalancedTree(op, firstHalfVec);
        let secondHalfRes = reduceBalancedTree(op, secondHalfVec);
        return op(firstHalfRes, secondHalfRes);
    endfunction
endinstance


////////////////////////////////////////////////////////////////////////////////
////////// Definitions of signals passed through pipelines
////////////////////////////////////////////////////////////////////////////////
typedef struct {
    Bool tLast;
    Bit#(TLog#(TAdd#(1, byteWidth))) shiftAmt;
} CrcCtrlSig#(numeric type byteWidth) deriving(Bits, FShow);

typedef struct {
    Bit#(width) data;
    CrcCtrlSig#(byteNum) ctrlSig;
} PreProcessRes#(numeric type byteNum, numeric type width) deriving(Bits, FShow);

typedef PreProcessRes#(byteNum, width) ShiftInputRes#(numeric type byteNum, numeric type width);

typedef struct {
    CrcResult#(crcWidth) crcRes;
    CrcCtrlSig#(dataByteNum) ctrlSig;
} ReduceCrcRes#(numeric type dataByteNum, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    CrcResult#(crcWidth) curCrc;
    CrcResult#(crcWidth) interCrc;
    CrcCtrlSig#(dataByteNum) ctrlSig;
} AccumulateRes#(numeric type dataByteNum, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    CrcResult#(crcWidth) curCrc;
    CrcResult#(crcWidth) remainder;
    Bit#(dataWidth) interCrc;
} ShiftInterCrcRes#(numeric type dataWidth, numeric type crcWidth) deriving(Bits, FShow);


interface CrcAxiStream#(numeric type crcWidth, numeric type dataByteNum, numeric type dataWidth);
    interface Put#(AxiStream#(dataByteNum, dataWidth)) axiStreamIn;
    interface Get#(CrcResult#(crcWidth)) crcResultOut;
endinterface

module mkCrcAxiStream#(CrcConfig#(crcWidth) conf)(CrcAxiStream#(crcWidth, dataByteNum, dataWidth)) 
    provisos(
        Mul#(BYTE_WIDTH, dataByteNum, dataWidth), 
        Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
        Mul#(BYTE_WIDTH, interByteNum, TAdd#(dataWidth, crcWidth)),
        ReduceBalancedTree#(dataByteNum, CrcResult#(crcWidth)),
        ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth))
    );

    FIFOF#(PreProcessRes#(dataByteNum, dataWidth)) preProcessBuf <- mkFIFOF;
    FIFOF#(ShiftInputRes#(dataByteNum, dataWidth)) shiftInputBuf <- mkFIFOF;
    FIFOF#(Vector#(dataByteNum, CrcResult#(crcWidth))) readTabBuf <- mkFIFOF;
    FIFOF#(CrcCtrlSig#(dataByteNum)) ctrlSigBuf <- mkFIFOF;
    FIFOF#(ReduceCrcRes#(dataByteNum, crcWidth)) reduceCrcBuf <- mkFIFOF;
    FIFOF#(AccumulateRes#(dataByteNum, crcWidth)) accuCrcBuf <- mkFIFOF;
    FIFOF#(ShiftInterCrcRes#(dataWidth, crcWidth)) shiftInterBuf <- mkFIFOF;
    FIFOF#(Vector#(dataByteNum, CrcResult#(crcWidth))) interReadTabBuf <- mkFIFOF;
    FIFOF#(CrcResult#(crcWidth)) currentCrcBuf <- mkFIFOF;
    FIFOF#(CrcResult#(crcWidth)) finalCrcBuf <- mkFIFOF;

    Reg#(CrcResult#(crcWidth)) interCrcRes <- mkReg(conf.initVal);
    Vector#(dataByteNum, RegFile#(Byte, CrcResult#(crcWidth))) crcTabVec <- genWithM(mkCrcRegFileTable(0));
    Integer tabOffset = valueOf(dataByteNum) - valueOf(crcByteNum);
    Vector#(crcByteNum, RegFile#(Byte, CrcResult#(crcWidth))) interCrcTabVec <- genWithM(mkCrcRegFileTable(tabOffset));
    
    rule shiftInput;
        let preProcessRes = preProcessBuf.first;
        preProcessBuf.deq;
        let data = preProcessRes.data;
        let shiftAmt = preProcessRes.ctrlSig.shiftAmt;
        preProcessRes.data = byteRightShift(data, shiftAmt);
        shiftInputBuf.enq(preProcessRes);
    endrule

    rule readCrcTable;
        let shiftInputRes = shiftInputBuf.first;
        shiftInputBuf.deq;
        Vector#(dataByteNum, Byte) dataVec = unpack(shiftInputRes.data);
        Vector#(dataByteNum, CrcResult#(crcWidth)) tempCrcVec = newVector;
        for (Integer i = 0; i < valueOf(dataByteNum); i = i + 1) begin
            tempCrcVec[i] = crcTabVec[i].sub(dataVec[i]);
        end
        readTabBuf.enq(tempCrcVec);
        ctrlSigBuf.enq(shiftInputRes.ctrlSig);
    endrule

    rule reduceTempCrc;
        let tempCrcVec = readTabBuf.first;
        readTabBuf.deq;
        let ctrlSig = ctrlSigBuf.first;
        ctrlSigBuf.deq;

        let crcRes = reduceBalancedTree(addCrc, tempCrcVec);
        ReduceCrcRes#(dataByteNum, crcWidth) reduceCrcRes = ReduceCrcRes {
            crcRes: crcRes,
            ctrlSig: ctrlSig
        };
        reduceCrcBuf.enq(reduceCrcRes);
    endrule

    rule accumulateCrc;
        let reduceCrcRes = reduceCrcBuf.first;
        reduceCrcBuf.deq;

        Vector#(crcByteNum, Byte) interCrcVec = unpack(interCrcRes);
        Vector#(crcByteNum, CrcResult#(crcWidth)) interTempCrcVec = newVector;
        for (Integer i = 0; i < valueOf(crcByteNum); i = i + 1) begin
            interTempCrcVec[i] = interCrcTabVec[i].sub(interCrcVec[i]);
        end

        let nextInterCrc = reduceBalancedTree(addCrc, interTempCrcVec);
        nextInterCrc = nextInterCrc ^ reduceCrcRes.crcRes;

        AccumulateRes#(dataByteNum, crcWidth) accuCrcRes = AccumulateRes {
            curCrc  : reduceCrcRes.crcRes,
            interCrc: interCrcRes,
            ctrlSig : reduceCrcRes.ctrlSig
        };

        if (reduceCrcRes.ctrlSig.tLast) begin
            accuCrcBuf.enq(accuCrcRes);
            interCrcRes <= conf.initVal;
        end
        else begin
            interCrcRes <= nextInterCrc;
        end
    endrule

    rule shiftInterCrc;
        let accuCrcRes = accuCrcBuf.first;
        accuCrcBuf.deq;
        
        Bit#(TAdd#(dataWidth, crcWidth)) interCrc = {accuCrcRes.interCrc, 0};
        interCrc = byteRightShift(interCrc, accuCrcRes.ctrlSig.shiftAmt);
        let shiftInterCrcRes = ShiftInterCrcRes {
            curCrc: accuCrcRes.curCrc,
            remainder: truncate(interCrc),
            interCrc: truncateLSB(interCrc)
        };
        shiftInterBuf.enq(shiftInterCrcRes);
    endrule

    rule readInterCrcTab;
        let shiftInterCrcRes = shiftInterBuf.first;
        shiftInterBuf.deq;
        Vector#(dataByteNum, Byte) interCrcVec = unpack(shiftInterCrcRes.interCrc);
        Vector#(dataByteNum, CrcResult#(crcWidth)) tempCrcVec = newVector;
        for (Integer i = 0; i < valueOf(dataByteNum); i = i + 1) begin
            tempCrcVec[i] = crcTabVec[i].sub(interCrcVec[i]);
        end
        interReadTabBuf.enq(tempCrcVec);
        currentCrcBuf.enq(shiftInterCrcRes.curCrc ^ shiftInterCrcRes.remainder);
    endrule

    rule reduceFinalCrc;
        let tempCrcVec = interReadTabBuf.first;
        interReadTabBuf.deq;
        let curCrc = currentCrcBuf.first;
        currentCrcBuf.deq;
        let interCrc = reduceBalancedTree(addCrc, tempCrcVec);
        let finalCrc = interCrc ^ curCrc;
        if (conf.reflectRemainder) begin
            finalCrc = reverseBits(finalCrc);
        end
        finalCrc = finalCrc ^ conf.finalXor;
        finalCrcBuf.enq(finalCrc);
    endrule

    interface Put axiStreamIn;
        method Action put(AxiStream#(dataByteNum, dataWidth) stream);
            // swap endian
            stream.tData = swapEndian(stream.tData);
            stream.tKeep = reverseBits(stream.tKeep);
            // reverse bits of Byte
            if (conf.reflectData) begin
                stream.tData = reverseBitsOfEachByte(stream.tData);
            end
            // TODO: modify count Zero logic
            let extraByteNum = countZerosLSB(stream.tKeep);

            CrcCtrlSig#(dataByteNum) ctrlSig = CrcCtrlSig {
                tLast: stream.tLast,
                shiftAmt: pack(extraByteNum)
            };
            PreProcessRes#(dataByteNum, dataWidth) preProcessRes = PreProcessRes {
                data: stream.tData,
                ctrlSig: ctrlSig
            };
            preProcessBuf.enq(preProcessRes);
        endmethod
    endinterface

    interface Get crcResultOut = toGet(finalCrcBuf);
endmodule
