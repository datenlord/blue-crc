import FIFOF :: *;
import GetPut :: *;
import Vector :: *;

import CrcUtils :: *;
import CrcDefines :: *;
import CrcAxiStream :: *;
import AxiStreamTypes :: *;

import SemiFifo :: *;

function Action immAssert(Bool condition, String assertName, Fmt assertFmtMsg);
    action
        let pos = printPosition(getStringPosition(assertName));
        // let pos = printPosition(getEvalPosition(condition));
        if (!condition) begin
            $display(
              "ImmAssert failed in %m @time=%0t: %s-- %s: ",
              $time, pos, assertName, assertFmtMsg
            );
            $finish(1);
        end
    endaction
endfunction

function Action immFail(String assertName, Fmt assertFmtMsg);
    action
        let pos = printPosition(getStringPosition(assertName));
        // let pos = printPosition(getEvalPosition(condition));
        $display(
            "ImmAssert failed in %m @time=%0t: %s-- %s: ",
            $time, pos, assertName, assertFmtMsg
        );
        $finish(1);
    endaction
endfunction

// interface AxiStreamSender#(
//     numeric type rawDataWidth,
//     numeric type axiKeepWidth,
//     numeric type axiUsrWidth,
//     numeric type caseCountWidth
// );
//     interface Put#(Bit#(rawDataWidth)) rawDataIn;
//     interface Get#(AxiStream#(axiKeepWidth, axiUsrWidth)) axiStreamOut;
// endinterface

// module mkAxiStreamSender(AxiStreamSender#(rawDataWidth, axiKeepWidth, axiUsrWidth, caseCountWidth)) 
//     provisos(
//         Mul#(axiKeepWidth, BYTE_WIDTH, axiDataWidth), 
//         Mul#(rawKeepWidth, BYTE_WIDTH, rawDataWidth),
//         Div#(rawDataWidth, axiDataWidth, fragNum),
//         Add#(rawKeepWidth, extraKeepWidth, TMul#(axiKeepWidth, fragNum)),
//         Add#(rawDataWidth, extraDataWidth, TMul#(fragNum, axiDataWidth))
//     );

//     Reg#(Bit#(caseCountWidth)) caseCounter <- mkReg(0);
//     Reg#(Bit#(TLog#(fragNum))) fragCounter <- mkReg(0);
//     FIFOF#(Bit#(rawDataWidth)) inputBuf <- mkFIFOF;
//     FIFOF#(AxiStream#(axiKeepWidth, axiUsrWidth)) outputBuf <- mkFIFOF;

//     rule send;
//         Integer maxFragNum = valueOf(fragNum) - 1;
//         let tLast = fragCounter == fromInteger(maxFragNum);
//         Bit#(TMul#(fragNum, axiDataWidth)) rawData = {inputBuf.first, 0};
//         Vector#(fragNum, Bit#(axiDataWidth)) rawDataVec = unpack(rawData);
//         rawDataVec = reverse(rawDataVec);

//         AxiStream#(axiKeepWidth, axiUsrWidth) fragment = AxiStream {
//             tData : swapEndian(rawDataVec[fragCounter]),
//             tKeep : maxBound,
//             tLast : tLast,
//             tUser : 0
//         };

//         if (tLast) begin
//             fragment.tKeep = fragment.tKeep >> valueOf(extraKeepWidth);
//         end

//         outputBuf.enq(fragment);
//         $display("AxiStreamSender: send %4d fragment of %4d case", fragCounter, caseCounter);
//         $display(fshow(fragment));
//         if (tLast) begin
//             fragCounter <= 0;
//             $display("AxiStreamSender: complete sending %4d case", caseCounter);
//             inputBuf.deq;
//         end
//         else begin
//             fragCounter <= fragCounter + 1;
//         end
//     endrule

//     interface Put rawDataIn;
//         method Action put(Bit#(rawDataWidth) data);
//             inputBuf.enq(data);
//             caseCounter <= caseCounter + 1;
//             $display("AxiStreamSender: start sending %5d case", caseCounter);
//             $display("AxiStreamSender: Raw data of %5d: %x", caseCounter, data);
//         endmethod
//     endinterface
//     interface Get axiStreamOut = toGet(outputBuf);
// endmodule

module mkAxiStreamSender#(
    String instanceName,
    FifoOut#(Bit#(maxRawByteNumWidth)) rawByteNumIn,
    FifoOut#(Bit#(maxRawDataWidth)) rawDataIn
)(FifoOut#(AxiStream#(axiKeepWidth, axiUsrWidth))) provisos(
    Mul#(axiKeepWidth, BYTE_WIDTH, axiDataWidth),
    Mul#(maxFragNum, axiKeepWidth, maxRawByteNum),
    Mul#(maxRawByteNum, BYTE_WIDTH, maxRawDataWidth),
    NumAlias#(TLog#(TAdd#(maxRawByteNum, 1)), maxRawByteNumWidth),
    NumAlias#(TLog#(maxFragNum), maxFragNumWidth)
);
    Reg#(Bit#(maxFragNumWidth)) fragCounter <- mkReg(0);
    Reg#(Bit#(maxRawByteNumWidth)) rawDataByteCounter <- mkReg(0);
    FIFOF#(AxiStream#(axiKeepWidth, axiUsrWidth)) outputBuf <- mkFIFOF;

    rule doFragment;
        let rawData = rawDataIn.first;
        Vector#(maxFragNum, Bit#(axiDataWidth)) rawDataVec = unpack(rawData);
        let rawByteNum = rawByteNumIn.first;

        AxiStream#(axiKeepWidth, axiUsrWidth) axiStream = AxiStream {
            tData: rawDataVec[fragCounter],
            tKeep: setAllBits,
            tLast: False,
            tUser: 0
        };

        let nextRawByteCountVal = rawDataByteCounter + fromInteger(valueOf(axiKeepWidth));
        if (nextRawByteCountVal >= rawByteNum) begin
            let extraByteNum = nextRawByteCountVal - rawByteNum;
            axiStream.tKeep = axiStream.tKeep >> extraByteNum;
            axiStream.tLast = True;
            fragCounter <= 0;
            rawDataByteCounter <= 0;
            rawDataIn.deq;
            rawByteNumIn.deq;
        end
        else begin
            fragCounter <= fragCounter + 1;
            rawDataByteCounter <= nextRawByteCountVal;
        end

        outputBuf.enq(axiStream);
        $display("%s: send %8d fragment %s", instanceName, fragCounter, fshow(axiStream));
    endrule
    
    return convertFifoToFifoOut(outputBuf);
endmodule
