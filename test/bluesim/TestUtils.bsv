import FIFOF :: *;
import GetPut :: *;
import Vector :: *;

import CrcAxiStream :: *;
import AxiStreamTypes :: *;

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
    numeric type rawDataWidth,
    numeric type axiKeepWidth,
    numeric type axiUsrWidth,
    numeric type caseCountWidth
);
    interface Put#(Bit#(rawDataWidth)) rawDataIn;
    interface Get#(AxiStream#(axiKeepWidth, axiUsrWidth)) axiStreamOut;
endinterface

module mkAxiStreamSender(AxiStreamSender#(rawDataWidth, axiKeepWidth, axiUsrWidth, caseCountWidth)) 
    provisos(
        Mul#(axiKeepWidth, BYTE_WIDTH, axiDataWidth), 
        Mul#(rawKeepWidth, BYTE_WIDTH, rawDataWidth),
        Div#(rawDataWidth, axiDataWidth, fragNum),
        Add#(rawKeepWidth, extraKeepWidth, TMul#(axiKeepWidth, fragNum)),
        Add#(rawDataWidth, extraDataWidth, TMul#(fragNum, axiDataWidth))
    );

    Reg#(Bit#(caseCountWidth)) caseCounter <- mkReg(0);
    Reg#(Bit#(TLog#(fragNum))) fragCounter <- mkReg(0);
    FIFOF#(Bit#(rawDataWidth)) inputBuf <- mkFIFOF;
    FIFOF#(AxiStream#(axiKeepWidth, axiUsrWidth)) outputBuf <- mkFIFOF;

    rule send;
        Integer maxFragNum = valueOf(fragNum) - 1;
        let tLast = fragCounter == fromInteger(maxFragNum);
        Bit#(TMul#(fragNum, axiDataWidth)) rawData = {inputBuf.first, 0};
        Vector#(fragNum, Bit#(axiDataWidth)) rawDataVec = unpack(rawData);
        rawDataVec = reverse(rawDataVec);

        AxiStream#(axiKeepWidth, axiUsrWidth) fragment = AxiStream {
            tData : swapEndian(rawDataVec[fragCounter]),
            tKeep : maxBound,
            tLast : tLast,
            tUser : 0
        };

        if (tLast) begin
            fragment.tKeep = fragment.tKeep >> valueOf(extraKeepWidth);
        end

        outputBuf.enq(fragment);
        $display("AxiStreamSender: send %5d fragment of %5d case", caseCounter, fragCounter);
        $display(fshow(fragment));
        if (tLast) begin
            fragCounter <= 0;
            $display("AxiStreamSender: complete sending %5d case", caseCounter);
            inputBuf.deq;
        end
        else begin
            fragCounter <= fragCounter + 1;
        end
    endrule

    interface Put rawDataIn;
        method Action put(Bit#(rawDataWidth) data);
            inputBuf.enq(data);
            caseCounter <= caseCounter + 1;
            $display("AxiStreamSender: start sending %5d case", caseCounter);
            $display("AxiStreamSender: Raw data of %5d: %x", caseCounter, data);
        endmethod
    endinterface
    interface Get axiStreamOut = toGet(outputBuf);
endmodule