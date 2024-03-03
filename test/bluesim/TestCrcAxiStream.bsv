import FIFOF :: *;
import Randomizable :: *;
import CRC :: *;
import Vector :: *;
import GetPut :: *;
import Connectable :: *;

import CrcDefines :: *;
import CrcUtils :: *;
import CrcAxiStream :: *;
import TestUtils :: *;

import SemiFifo :: *;

// `define CRC_WIDTH 32
// `define AXI_KEEP_WIDTH 32
//`define POLY 32'h04C11DB7
// `define INIT_VAL 32'hFFFFFFFF
// `define FINAL_XOR 32'hFFFFFFFF
// `define REV_INPUT BIT_ORDER_REVERSE
// `define REV_OUTPUT BIT_ORDER_REVERSE
// `define MEM_FILE_PREFIX "crc_tab"
// `define CRC_MODE CRC_MODE_RECV

typedef 512 TEST_CASE_NUM;
typedef 16 CYCLE_COUNT_WIDTH;
typedef 40000 MAX_CYCLE_NUM;
typedef 16 CASE_COUNT_WIDTH;

typedef 2 MAX_FRAG_NUM;
typedef TMul#(MAX_FRAG_NUM, `AXI_KEEP_WIDTH) MAX_RAW_DATA_BYTE_NUM;
typedef TMul#(MAX_RAW_DATA_BYTE_NUM, BYTE_WIDTH) MAX_RAW_DATA_WIDTH;
typedef TLog#(TAdd#(MAX_RAW_DATA_BYTE_NUM, 1)) RAW_DATA_COUNT_WIDTH;

typedef TDiv#(`CRC_WIDTH, BYTE_WIDTH) CRC_BYTE_NUM;

module mkTestCrcAxiStream(Empty);
    Integer maxCycleNum = valueOf(MAX_CYCLE_NUM);
    Integer testCaseNum = valueOf(TEST_CASE_NUM);
    Integer maxRawDataByteNum = valueOf(MAX_RAW_DATA_BYTE_NUM);
    Integer crcByteNum = valueOf(CRC_BYTE_NUM);
    
    // Common Signals
    Reg#(Bool) isInit <- mkReg(False);
    Reg#(Bit#(CYCLE_COUNT_WIDTH)) cycle <- mkReg(0);
    Reg#(Bit#(CASE_COUNT_WIDTH)) inputCaseCount <- mkReg(0);
    Reg#(Bit#(CASE_COUNT_WIDTH)) outputCaseCount <- mkReg(0);
    
    // Random Signals
    Randomize#(Bit#(RAW_DATA_COUNT_WIDTH)) randRawDataByteNum <- mkGenericRandomizer;
    Randomize#(Bit#(MAX_RAW_DATA_WIDTH)) randRawData <- mkGenericRandomizer;
    

    // DUT and REF Model
    Bit#(`CRC_WIDTH) polynominal = `POLY;
    Bit#(`CRC_WIDTH) initVal = `INIT_VAL;
    Bit#(`CRC_WIDTH) finalXor = `FINAL_XOR;
    IsReverseBitOrder revInput = `REV_INPUT;
    IsReverseBitOrder revOutput = `REV_OUTPUT;
    String memFilePrefix = `MEM_FILE_PREFIX;
    CrcMode crcMode = `CRC_MODE;

    CRC#(`CRC_WIDTH) refCrcModel <- mkCRC(
        polynominal, 
        initVal,
        finalXor,
        revInput == BIT_ORDER_REVERSE, 
        revOutput == BIT_ORDER_REVERSE
    );

    CrcConfig#(`CRC_WIDTH) crcConf = CrcConfig {
        polynominal: `POLY,
        initVal: `INIT_VAL,
        finalXor: `FINAL_XOR,
        revInput: `REV_INPUT,
        revOutput: `REV_OUTPUT,
        memFilePrefix: `MEM_FILE_PREFIX,
        crcMode: `CRC_MODE
    };

    FIFOF#(Bit#(`CRC_WIDTH)) refCrcOutputBuf <- mkFIFOF;
    FIFOF#(Bit#(MAX_RAW_DATA_WIDTH)) rawDataBuf <- mkFIFOF;
    FIFOF#(Bit#(RAW_DATA_COUNT_WIDTH)) rawDataByteNumBuf <- mkFIFOF;
    AxiStreamFifoOut#(`AXI_KEEP_WIDTH) dutAxiStreamInput <- mkAxiStreamSender(
        "AxiStreamSender",
        convertFifoToFifoOut(rawDataByteNumBuf),
        convertFifoToFifoOut(rawDataBuf)
    );
    let dutCrcOutput <- mkCrcAxiStreamFifoOut(
        crcConf,
        dutAxiStreamInput
    );

    
    rule doRandInit if (!isInit);
        randRawDataByteNum.cntrl.init;
        randRawData.cntrl.init;
        refCrcModel.clear;
        isInit <= True;
    endrule

    rule doCycleCount if (isInit);
        cycle <= cycle + 1;
        immAssert(
            cycle <= fromInteger(maxCycleNum),
            "Testbench timeout assertion @ mkTestCrcAxiStream",
            $format("Cycle count can't overflow %d", maxCycleNum)
        );
        $display("\nCycle %d ----------------------------------------", cycle);
    endrule
    
    Reg#(Bit#(RAW_DATA_COUNT_WIDTH)) rawDataByteCounter <- mkReg(0);
    Reg#(Bit#(MAX_RAW_DATA_WIDTH)) tempRawData <- mkRegU;
    Reg#(Bit#(RAW_DATA_COUNT_WIDTH)) tempRawDataByteNum <- mkRegU;
    rule genDutInput if (isInit && inputCaseCount < fromInteger(testCaseNum));
        if (rawDataByteCounter == 0) begin
            let rawData <- randRawData.next;
            let rawDataByteNum <- randRawDataByteNum.next;
            Bit#(RAW_DATA_COUNT_WIDTH) maxCaseByteNum = fromInteger(maxRawDataByteNum);
            
            if (crcMode == CRC_MODE_RECV) begin
                maxCaseByteNum = maxCaseByteNum - fromInteger(crcByteNum);
            end
            if (rawDataByteNum > maxCaseByteNum) begin
                rawDataByteNum = maxCaseByteNum;
            end
            tempRawData <= bitMask(rawData, (1 << rawDataByteNum) - 1);
            tempRawDataByteNum <= rawDataByteNum;
            $display("input case %d raw data byte num %d", inputCaseCount, rawDataByteNum);
            if (rawDataByteNum > 0) begin
                refCrcModel.add(truncate(rawData));
                rawDataByteCounter <= rawDataByteCounter + 1;
            end
        end
        else if (rawDataByteCounter < tempRawDataByteNum) begin
            Vector#(MAX_RAW_DATA_BYTE_NUM, Byte) rawDataVec = unpack(tempRawData);
            refCrcModel.add(rawDataVec[rawDataByteCounter]);
            rawDataByteCounter <= rawDataByteCounter + 1;
            $display("Case %d Add Ref Crc32: %x", inputCaseCount, rawDataVec[rawDataByteCounter]);
        end
        else begin
            rawDataByteCounter <= 0;
            inputCaseCount <= inputCaseCount + 1;
            let refCrc <- refCrcModel.complete;

            let dataByteNum = tempRawDataByteNum;
            if (crcMode == CRC_MODE_RECV) begin
                dataByteNum = dataByteNum + fromInteger(crcByteNum);
            end
            rawDataBuf.enq(tempRawData);
            rawDataByteNumBuf.enq(dataByteNum);
            
            refCrcOutputBuf.enq(refCrc);
            $display("Generate %d input case: %x crc: %x", inputCaseCount, tempRawData, refCrc);
        end
    endrule

    rule checkDutOuput if (isInit && outputCaseCount < fromInteger(testCaseNum));
        let dutCrc = dutCrcOutput.first;
        dutCrcOutput.deq;
        let refCrc = refCrcOutputBuf.first;
        refCrcOutputBuf.deq;

        $display("Case %d DUT Output: %x", outputCaseCount, dutCrc);
        immAssert(
            dutCrc == refCrc,
            "The output of DUT and REF are inconsistent @ mkTestCrcAxiStream",
            $format("DUT: %x REF: %x", dutCrc, refCrc)
        );
        outputCaseCount <= outputCaseCount + 1;
    endrule

    rule doFinish if (outputCaseCount == fromInteger(testCaseNum));
        $display("Pass all %d test cases!", testCaseNum);
        $display("0");
        $finish;
    endrule
endmodule