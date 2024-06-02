import FIFOF :: *;
import Vector :: *;
import GetPut :: *;
import RegFile :: *;

import CrcUtils :: *;
import CrcDefines :: *;

import SemiFifo :: *;
import BusConversion :: *;
import AxiStreamTypes :: *;


////////////////////////////////////////////////////////////////////////////////
////////// Definitions of signals passed through pipelines
////////////////////////////////////////////////////////////////////////////////
typedef struct {
    Bool isLast;
    Bool isFirst;
    Bit#(TLog#(TAdd#(1, axiKeepWidth))) shiftAmt;
} CrcCtrlSig#(numeric type axiKeepWidth) deriving(Bits, FShow);

typedef struct {
    Bit#(TMul#(axiKeepWidth, BYTE_WIDTH)) data;
    CrcCtrlSig#(axiKeepWidth) ctrlSig;
} PreProcessRes#(numeric type axiKeepWidth) deriving(Bits, FShow);

typedef PreProcessRes#(axiKeepWidth) ShiftInputRes#(numeric type axiKeepWidth);

typedef struct {
    Vector#(axiKeepWidth, CrcResult#(crcWidth)) tempCrcVec;
    CrcCtrlSig#(axiKeepWidth) ctrlSig;
} ReadCrcTabRes#(numeric type axiKeepWidth, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    CrcResult#(crcWidth) crcRes;
    CrcCtrlSig#(axiKeepWidth) ctrlSig;
} ReduceCrcRes#(numeric type axiKeepWidth, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    CrcResult#(crcWidth) curCrc;
    CrcResult#(crcWidth) interCrc;
    CrcCtrlSig#(axiKeepWidth) ctrlSig;
} AccuCrcRes#(numeric type axiKeepWidth, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    CrcResult#(crcWidth) curCrc;
    Bit#(TAdd#(axiDataWidth, crcWidth)) interCrc;
} ShiftInterCrcRes#(numeric type axiDataWidth, numeric type crcWidth) deriving(Bits, FShow);

typedef struct {
    Vector#(interByteNum, CrcResult#(crcWidth)) interCrc;
    CrcResult#(crcWidth) curCrc;
} ReadInterCrcTabRes#(numeric type interByteNum, numeric type crcWidth) deriving(Bits, FShow);


module mkCrcAxiStreamFifoOut#(
    CrcConfig#(crcWidth) conf,
    AxiStreamFifoOut#(axiKeepWidth) crcReq
)(CrcResultFifoOut#(crcWidth)) provisos(
    Mul#(BYTE_WIDTH, axiKeepWidth, axiDataWidth), 
    Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
    Mul#(BYTE_WIDTH, interByteNum, TAdd#(axiDataWidth, crcWidth)),
    ReduceBalancedTree#(axiKeepWidth, CrcResult#(crcWidth)),
    ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth)),
    ReduceBalancedTree#(interByteNum, CrcResult#(crcWidth))
);

    FIFOF#(PreProcessRes#(axiKeepWidth)) preProcessResBuf <- mkFIFOF;
    FIFOF#(ShiftInputRes#(axiKeepWidth)) shiftInputResBuf <- mkFIFOF;
    FIFOF#(ReadCrcTabRes#(axiKeepWidth, crcWidth)) readCrcTabResBuf <- mkFIFOF;
    FIFOF#(ReduceCrcRes#(axiKeepWidth, crcWidth)) reduceCrcResBuf <- mkFIFOF;
    FIFOF#(AccuCrcRes#(axiKeepWidth, crcWidth)) accuCrcResBuf <- mkFIFOF;
    FIFOF#(ShiftInterCrcRes#(axiDataWidth, crcWidth)) shiftInterCrcResBuf <- mkFIFOF;
    FIFOF#(ReadInterCrcTabRes#(interByteNum, crcWidth)) readInterCrcTabResBuf <- mkFIFOF;
    FIFOF#(CrcResult#(crcWidth)) finalCrcResBuf <- mkFIFOF;

    Reg#(Bool) isFirstFlag <- mkReg(True);
    Reg#(CrcResult#(crcWidth)) interCrcRes <- mkReg(conf.initVal);
    Vector#(interByteNum, LookupTable#(Byte, CrcResult#(crcWidth))) crcTabVec <- genWithM(mkCrcLookupTable(0, conf.memFilePrefix));

    rule preProcess;
        let axiStream = crcReq.first;
        crcReq.deq;
        // swap endian
        axiStream.tData = bitMask(axiStream.tData, axiStream.tKeep);
        axiStream.tData = swapEndian(axiStream.tData);
        axiStream.tKeep = reverseBits(axiStream.tKeep);
    
        // reverse bits of each input byte 
        if (conf.revInput == BIT_ORDER_REVERSE) begin
            axiStream.tData = reverseBitsOfEachByte(axiStream.tData);
        end

        // TODO: modify count Zero logic
        let extraByteNum = countZerosLSB(axiStream.tKeep);
        
        CrcCtrlSig#(axiKeepWidth) ctrlSig = CrcCtrlSig {
            isFirst : isFirstFlag,
            isLast  : axiStream.tLast,
            shiftAmt: pack(extraByteNum)
        };
        PreProcessRes#(axiKeepWidth) preProcessRes = PreProcessRes {
            data: axiStream.tData,
            ctrlSig: ctrlSig
        };

        isFirstFlag <= axiStream.tLast;
        preProcessResBuf.enq(preProcessRes);
    endrule

    rule shiftInput;
        let preProcessRes = preProcessResBuf.first;
        preProcessResBuf.deq;
        let data = preProcessRes.data;
        let shiftAmt = preProcessRes.ctrlSig.shiftAmt;
        preProcessRes.data = byteRightShift(data, shiftAmt);
        shiftInputResBuf.enq(preProcessRes);
        //$display("shiftInput Result: %x", preProcessRes.data);
    endrule

    rule readCrcTab;
        let shiftInputRes = shiftInputResBuf.first;
        shiftInputResBuf.deq;
        Vector#(axiKeepWidth, Byte) dataVec = unpack(shiftInputRes.data);
        Vector#(axiKeepWidth, CrcResult#(crcWidth)) tempCrcVec = newVector;
        Integer tabOffset = 0;
        if (conf.crcMode == CRC_MODE_SEND) tabOffset = valueOf(crcByteNum);
        for (Integer i = 0; i < valueOf(axiKeepWidth); i = i + 1) begin
            tempCrcVec[i] = crcTabVec[tabOffset + i].sub1(dataVec[i]);
            //$display("read tab %d result: %x", i, tempCrcVec[i]);
        end
        let readCrcTabRes = ReadCrcTabRes {
            tempCrcVec: tempCrcVec,
            ctrlSig: shiftInputRes.ctrlSig
        };
        readCrcTabResBuf.enq(readCrcTabRes);
    endrule

    rule reduceCrc;
        let readCrcTabRes = readCrcTabResBuf.first;
        readCrcTabResBuf.deq;

        let crcRes = reduceBalancedTree(addCrc, readCrcTabRes.tempCrcVec);
        ReduceCrcRes#(axiKeepWidth, crcWidth) reduceCrcRes = ReduceCrcRes {
            crcRes: crcRes,
            ctrlSig: readCrcTabRes.ctrlSig
        };
        reduceCrcResBuf.enq(reduceCrcRes);
        //$display("reduce temp Crc: %x", crcRes);
    endrule

    rule accuCrc;
        let reduceCrcRes = reduceCrcResBuf.first;
        reduceCrcResBuf.deq;

        Vector#(crcByteNum, Byte) interCrcVec = unpack(interCrcRes);
        Vector#(crcByteNum, CrcResult#(crcWidth)) interTempCrcVec = newVector;
        Integer tabOffset = valueOf(axiKeepWidth);
        if (conf.crcMode == CRC_MODE_RECV) begin
            Integer initTabOffset = tabOffset - valueOf(crcByteNum);
            for (Integer i = 0; i < valueOf(crcByteNum); i = i + 1) begin
                if (reduceCrcRes.ctrlSig.isFirst) begin
                    interTempCrcVec[i] = crcTabVec[i + initTabOffset].sub2(interCrcVec[i]);
                end
                else begin
                    interTempCrcVec[i] = crcTabVec[i + tabOffset].sub2(interCrcVec[i]);
                end
            end
        end
        else begin
            for (Integer i = 0; i < valueOf(crcByteNum); i = i + 1) begin
                interTempCrcVec[i] = crcTabVec[i + tabOffset].sub2(interCrcVec[i]);
            end
        end

        let nextInterCrc = reduceBalancedTree(addCrc, interTempCrcVec);
        nextInterCrc = nextInterCrc ^ reduceCrcRes.crcRes;

        AccuCrcRes#(axiKeepWidth, crcWidth) accuCrcRes = AccuCrcRes {
            curCrc  : reduceCrcRes.crcRes,
            interCrc: interCrcRes,
            ctrlSig : reduceCrcRes.ctrlSig
        };

        if (reduceCrcRes.ctrlSig.isLast) begin
            accuCrcResBuf.enq(accuCrcRes);
            interCrcRes <= conf.initVal;
            //$display("Accumulate Res:", fshow(accuCrcRes));
        end
        else begin
            interCrcRes <= nextInterCrc;
        end
    endrule

    rule shiftInterCrc;
        let accuCrcRes = accuCrcResBuf.first;
        accuCrcResBuf.deq;
        
        Bit#(TAdd#(axiDataWidth, crcWidth)) interCrc = {accuCrcRes.interCrc, 0};
        Bit#(TAdd#(TLog#(TAdd#(1, axiKeepWidth)), 1)) shiftAmt = zeroExtend(accuCrcRes.ctrlSig.shiftAmt);
        if (conf.crcMode == CRC_MODE_RECV) begin
            if (accuCrcRes.ctrlSig.isFirst && accuCrcRes.ctrlSig.isLast) begin
                shiftAmt = shiftAmt + fromInteger(valueOf(crcByteNum));
            end
        end
        interCrc = byteRightShift(interCrc, shiftAmt);
        let shiftInterCrcRes = ShiftInterCrcRes {
            curCrc: accuCrcRes.curCrc,
            interCrc: interCrc
        };
        shiftInterCrcResBuf.enq(shiftInterCrcRes);
        //$display("shiftInterCrcRes: %x", interCrc);
    endrule

    rule readInterCrcTab;
        let shiftInterCrcRes = shiftInterCrcResBuf.first;
        shiftInterCrcResBuf.deq;
        Vector#(interByteNum, Byte) interCrcVec = unpack(shiftInterCrcRes.interCrc);
        Vector#(interByteNum, CrcResult#(crcWidth)) readCrcTabResVec = newVector;
        for (Integer i = 0; i < valueOf(interByteNum); i = i + 1) begin
            readCrcTabResVec[i] = crcTabVec[i].sub3(interCrcVec[i]);
            //$display("ReadInterCrcTab%d: %x", i, readCrcTabResVec[i]);
        end
        let readInterCrcTabRes = ReadInterCrcTabRes {
            interCrc: readCrcTabResVec,
            curCrc: shiftInterCrcRes.curCrc
        };
        readInterCrcTabResBuf.enq(readInterCrcTabRes);
    endrule

    rule reduceFinalCrc;
        let readInterCrcTabRes = readInterCrcTabResBuf.first;
        readInterCrcTabResBuf.deq;
        let interCrc = reduceBalancedTree(addCrc, readInterCrcTabRes.interCrc);
        let finalCrc = interCrc ^ readInterCrcTabRes.curCrc;
        //$display("final CRC: %x", finalCrc);
        if (conf.revOutput == BIT_ORDER_REVERSE) begin
            finalCrc = reverseBits(finalCrc);
        end
        finalCrc = finalCrc ^ conf.finalXor;
        finalCrcResBuf.enq(finalCrc);
    endrule

    return convertFifoToFifoOut(finalCrcResBuf);
endmodule


interface CrcAxiStream#(numeric type crcWidth, numeric type axiKeepWidth);
    interface AxiStreamPut#(axiKeepWidth) crcReq;
    interface CrcResultGet#(crcWidth) crcResp;
endinterface


module mkCrcAxiStream#(
    CrcConfig#(crcWidth) conf
)(CrcAxiStream#(crcWidth, axiKeepWidth)) provisos(
    Mul#(BYTE_WIDTH, axiKeepWidth, axiDataWidth), 
    Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
    Mul#(BYTE_WIDTH, interByteNum, TAdd#(axiDataWidth, crcWidth)),
    ReduceBalancedTree#(axiKeepWidth, CrcResult#(crcWidth)),
    ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth)),
    ReduceBalancedTree#(interByteNum, CrcResult#(crcWidth))
);
    FIFOF#(AxiStream#(axiKeepWidth, AXIS_USER_WIDTH)) crcReqBuf <- mkFIFOF;
    let crcReqFifoOut = convertFifoToFifoOut(crcReqBuf);
    let crcRespFifoOut <- mkCrcAxiStreamFifoOut(conf, crcReqFifoOut);

    interface Put crcReq = toPut(crcReqBuf);
    interface Get crcResp = toGet(crcRespFifoOut);
endmodule


interface CrcRawAxiStream#(numeric type crcWidth, numeric type axiKeepWidth);
    (* prefix = "s_axis" *)
    interface RawAxiStreamSlave#(axiKeepWidth, AXIS_USER_WIDTH) rawCrcReq;
    (* prefix = "m_crc_stream" *)
    interface RawBusMaster#(CrcResult#(crcWidth)) rawCrcResp;
endinterface

module mkCrcRawAxiStream#(CrcConfig#(crcWidth) conf)(CrcRawAxiStream#(crcWidth, axiKeepWidth)) provisos(
    Mul#(BYTE_WIDTH, axiKeepWidth, dataWidth), 
    Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
    Mul#(BYTE_WIDTH, interByteNum, TAdd#(dataWidth, crcWidth)),
    ReduceBalancedTree#(axiKeepWidth, CrcResult#(crcWidth)),
    ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth)),
    ReduceBalancedTree#(interByteNum, CrcResult#(crcWidth))
);

    CrcAxiStream#(crcWidth, axiKeepWidth) crcAxiStream <- mkCrcAxiStream(conf);
    let rawAxiStreamSlave <- mkPutToRawAxiStreamSlave(crcAxiStream.crcReq, CF);
    let rawBusMaster <- mkGetToRawBusMaster(crcAxiStream.crcResp, CF);
    
    interface RawAxiStreamRecv rawCrcReq = rawAxiStreamSlave;
    interface RawBusSend rawCrcResp = rawBusMaster;
endmodule

