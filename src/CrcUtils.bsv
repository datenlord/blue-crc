import Vector :: *;
import Printf :: *;
import RegFile :: *;

import CrcDefines :: *;


////////////////////////////////////////////////////////////////////////////////
////////// Implementation of utility functions used in the design
////////////////////////////////////////////////////////////////////////////////
module mkCrcRegFileTable#(Integer offset, String filePrefix)(Integer idx, RegFile#(Byte, CrcResult#(width)) ifc);
    // $display("crc lookup tab offset: %d", offset);
    let initFile = sprintf("%s_%d.mem", filePrefix, offset + idx);
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

function Bit#(dWidth) bitMask(Bit#(dWidth) data, Bit#(mWidth) mask) provisos(Mul#(mWidth, BYTE_WIDTH, dWidth));
    Bit#(dWidth) fullMask = 0;
    for (Integer i = 0; i < valueOf(mWidth); i = i + 1) begin
        for (Integer j = 0; j < 8; j = j + 1) begin
            fullMask[i*8+j] = mask[i];
        end
    end
    return fullMask & data;
endfunction

function Bit#(w) setAllBits;
    Bit#(TAdd#(w,1)) result = 1;
    return truncate((result << valueOf(w)) - 1);
endfunction

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
