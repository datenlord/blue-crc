import Vector :: *;
import Printf :: *;
import RegFile :: *;

import CrcDefines :: *;


////////////////////////////////////////////////////////////////////////////////
////////// Implementation of utility functions used in the design
////////////////////////////////////////////////////////////////////////////////
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

interface LookupTable#(type indexType, type dataType);
    method dataType sub1(indexType idx);
    method dataType sub2(indexType idx);
    method dataType sub3(indexType idx);
    method dataType sub4(indexType idx);
    method dataType sub5(indexType idx);
endinterface

module mkLookupTableBluesim#(String initFile)(LookupTable#(indexType, dataType))
    provisos(Bits#(indexType, indexWidth), Bits#(dataType, dataWidth), Bounded#(indexType));

    RegFile#(indexType, dataType) regFile <- mkRegFileFullLoad(initFile);

    method dataType sub1(indexType idx) = regFile.sub(idx);
    method dataType sub2(indexType idx) = regFile.sub(idx);
    method dataType sub3(indexType idx) = regFile.sub(idx);
    method dataType sub4(indexType idx) = regFile.sub(idx);
    method dataType sub5(indexType idx) = regFile.sub(idx);
endmodule

import "BVI" LookupTableLoad = 
module mkLookupTableVerilog#(String initFile)(LookupTable#(indexType, dataType))
    provisos(Bits#(indexType, indexWidth), Bits#(dataType, dataWidth));

    Integer table_depth = (2 ** valueOf(indexWidth));

    parameter file = initFile;
    parameter addr_width = valueOf(indexWidth);
    parameter data_width = valueOf(dataWidth);
    parameter lo = 0;
    parameter hi = table_depth - 1;
    parameter binary = 0;

    default_reset no_reset;
    default_clock dummyClk (CLK, (*unused*)CLK_GATE);

    method D_OUT_1 sub1(ADDR_1);
    method D_OUT_2 sub2(ADDR_2);
    method D_OUT_3 sub3(ADDR_3);
    method D_OUT_4 sub4(ADDR_4);
    method D_OUT_5 sub5(ADDR_5);

    schedule (sub1) CF (sub2, sub3, sub4, sub5);
    schedule (sub2) CF (sub1, sub3, sub4, sub5);
    schedule (sub3) CF (sub1, sub2, sub4, sub5);
    schedule (sub4) CF (sub1, sub2, sub3, sub5);
    schedule (sub5) CF (sub1, sub2, sub3, sub4);

    schedule sub1 C sub1;
    schedule sub2 C sub2;
    schedule sub3 C sub3;
    schedule sub4 C sub4;
    schedule sub5 C sub5;
endmodule

module mkLookupTable#(String initFile)(LookupTable#(indexType, dataType))
    provisos(Bits#(indexType, indexWidth), Bits#(dataType, dataWidth), Bounded#(indexType));
    LookupTable#(indexType, dataType) lookupTable;
    if (genVerilog) begin
        lookupTable <- mkLookupTableVerilog(initFile);
    end 
    else begin
        lookupTable <- mkLookupTableBluesim(initFile);
    end
    return lookupTable;
endmodule

module mkCrcLookupTable#(Integer offset, String filePrefix)(Integer idx, LookupTable#(Byte, CrcResult#(width)) ifc);
    // $display("crc lookup tab offset: %d", offset);
    let initFile = sprintf("%s_%d.mem", filePrefix, offset + idx);
    LookupTable#(Byte, CrcResult#(width)) lookupTable <- mkLookupTable(initFile);
    return lookupTable;
endmodule