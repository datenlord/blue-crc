import FIFOF :: *;
import GetPut :: *;
import Vector :: *;

import CrcAxiStream :: *;
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

interface AxiStreamSender#(
    numeric type rawWidth,
    numeric type axiByteNum,
    numeric type axiWidth,
    numeric type caseCountWidth
);
    interface Put#(Bit#(rawWidth)) rawDataIn;
    interface Get#(AxiStream#(axiByteNum, axiWidth)) axiStreamOut;
endinterface

module mkAxiStreamSender(AxiStreamSender#(rawWidth, axiByteNum, axiWidth, caseCountWidth)) 
    provisos(
        Mul#(axiByteNum, BYTE_WIDTH, axiWidth), 
        Mul#(rawByteNum, BYTE_WIDTH, rawWidth),
        Div#(rawWidth, axiWidth, fragNum),
        Add#(rawByteNum, extraByteNum, TMul#(axiByteNum, fragNum)),
        Add#(rawWidth, extraWidth, TMul#(fragNum, axiWidth))
    );
    Reg#(Bit#(caseCountWidth)) caseCounter <- mkReg(0);
    Reg#(Bit#(TLog#(fragNum))) fragmentCount <- mkReg(0);
    FIFOF#(Bit#(rawWidth)) inputBuf <- mkFIFOF;
    FIFOF#(AxiStream#(axiByteNum, axiWidth)) outputBuf <- mkFIFOF;

    rule send;
        Integer maxFragNum = valueOf(fragNum) - 1;
        let tLast = fragmentCount == fromInteger(maxFragNum);
        Bit#(TMul#(fragNum, axiWidth)) rawData = {inputBuf.first, 0};
        Vector#(fragNum, Bit#(axiWidth)) rawDataVec = unpack(rawData);
        rawDataVec = reverse(rawDataVec);

        AxiStream#(axiByteNum, axiWidth) fragment = AxiStream {
            tData : swapEndian(rawDataVec[fragmentCount]),
            tKeep : maxBound,
            tLast : tLast,
            tUser : False
        };

        if (tLast) begin
            fragment.tKeep = fragment.tKeep >> valueOf(extraByteNum);
        end

        outputBuf.enq(fragment);
        $display("AxiStreamSender: send %5d fragment of %5d case", caseCounter, fragmentCount);
        $display(fshow(fragment));
        if (tLast) begin
            fragmentCount <= 0;
            $display("AxiStreamSender: complete sending %5d case", caseCounter);
            inputBuf.deq;
        end
        else begin
            fragmentCount <= fragmentCount + 1;
        end
    endrule

    interface Put rawDataIn;
        method Action put(Bit#(rawWidth) data);
            inputBuf.enq(data);
            caseCounter <= caseCounter + 1;
            $display("AxiStreamSender: start sending %5d case", caseCounter);
            $display("AxiStreamSender: Raw data of %5d: %x", caseCounter, fshow(data));
        endmethod
    endinterface
    interface Get axiStreamOut = toGet(outputBuf);
endmodule