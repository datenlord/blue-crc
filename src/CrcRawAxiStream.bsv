import GetPut :: *;
import FIFOF :: *;
import Connectable :: *;

import CrcAxiStream :: *;

(* always_ready, always_enabled *)
interface RawBusSend#(type dType);
    (* result = "data" *) method dType  data;
    (* result = "valid"   *) method Bool   valid;
    (* prefix = "" *) method Action ready((* port = "ready" *) Bool rdy);
endinterface

(* always_ready, always_enabled *)
interface RawBusRecv#(type dType);
    (* prefix = "" *) method Action validData(
        (* port = "valid"   *) Bool valid,
        (* port = "data" *) dType data
    );
    (* result = "ready" *)method Bool ready;
endinterface

interface RawBusSender#(type dType);
    interface Put#(dType)        in;
    interface RawBusSend#(dType) out;
endinterface

interface RawBusReceiver#(type dType);
    interface RawBusRecv#(dType) in;
    interface Get#(dType)        out;
endinterface

(* always_ready, always_enabled *)
interface RawAxiStreamSend#(numeric type keepWidth, numeric type dataWidth);
    (* result = "axis_tvalid" *) method Bool tValid;
    (* result = "axis_tdata"  *) method Bit#(dataWidth) tData;
    (* result = "axis_tkeep"  *) method Bit#(keepWidth) tKeep;
    (* result = "axis_tlast"  *) method Bool tLast;
    (* result = "axis_tuser"  *) method Bool tUser;
    (* prefix = "" *) method Action tReady((* port="axis_tready" *) Bool ready);
endinterface

(* always_ready, always_enabled *)
interface RawAxiStreamRecv#(numeric type keepWidth, numeric type dataWidth);
    (* prefix = "" *)
    method Action tValid (
         (* port="axis_tvalid" *) Bool            valid,
         (* port="axis_tdata"  *) Bit#(dataWidth) tData,
         (* port="axis_tkeep"  *) Bit#(keepWidth) tKeep,
         (* port="axis_tlast"  *) Bool            tLast,
         (* port="axis_tuser"  *) Bool            tUser
     );
    (* result="axis_tready" *) 
    method Bool    tReady;
endinterface


module mkRawBusSender(RawBusSender#(dType)) provisos(Bits#(dType, dTypeSz));
    Bool unguarded = True;
    Bool guarded = False;
    FIFOF#(dType) buffer <- mkGFIFOF(guarded, unguarded);

    interface Put in = toPut(buffer);

    interface RawBusSend out;
        method Bool valid = buffer.notEmpty;
        method dType data = buffer.first;
        method Action ready(Bool rdy);
            if (rdy && buffer.notEmpty) begin
                buffer.deq;
            end
        endmethod
    endinterface
endmodule

module mkRawBusReceiver(RawBusReceiver#(dType)) provisos(Bits#(dType, dTypeSz));
    Bool unguarded = True;
    Bool guarded = False;
    FIFOF#(dType) buffer <- mkGFIFOF(unguarded, guarded);    

    interface RawBusRecv in;
        method Action validData(Bool valid, dType data);
            if (valid && buffer.notFull) begin
                buffer.enq(data);
            end
        endmethod

        method Bool ready = buffer.notFull;
    endinterface

    interface Get out = toGet(buffer);
endmodule

module mkRawBusSendToRawAxiStream#(
    RawBusSend#(AxiStream#(keepWidth, dataWidth)) rawBusSend
    )(RawAxiStreamSend#(keepWidth, dataWidth));

    method Bool tValid = rawBusSend.valid;
    method Bit#(dataWidth) tData = rawBusSend.data.tData;
    method Bit#(keepWidth) tKeep = rawBusSend.data.tKeep;
    method Bool tLast = rawBusSend.data.tLast;
    method Bool tUser = rawBusSend.data.tUser;
    method Action tReady(Bool val);
        rawBusSend.ready(val);
    endmethod
endmodule

module mkRawBusRecvToRawAxiStream#(
    RawBusRecv#(AxiStream#(keepWidth, dataWidth)) rawBusRecv
    )(RawAxiStreamRecv#(keepWidth, dataWidth) rawAxiRecv);

    method Action tValid (Bool valid, Bit#(dataWidth) tData, Bit#(keepWidth) tKeep, Bool tLast, Bool tUser);
        AxiStream#(keepWidth, dataWidth) axiStream = AxiStream {
            tData: tData,
            tKeep: tKeep,
            tLast: tLast,
            tUser: tUser
        };
        rawBusRecv.validData(valid, axiStream);
    endmethod

    method Bool tReady = rawBusRecv.ready;
endmodule


interface CrcRawAxiStream#(numeric type crcWidth, numeric type keepWidth, numeric type dataWidth);
    (* prefix = "s" *)
    interface RawAxiStreamRecv#(keepWidth, dataWidth) crcReq; // crcReq
    (* prefix = "m_crc_stream" *)
    interface RawBusSend#(CrcResult#(crcWidth)) crcResp; // crcResp
endinterface

module mkCrcRawAxiStream#(CrcConfig#(crcWidth) conf)(CrcRawAxiStream#(crcWidth, keepWidth, dataWidth)) 
    provisos(
        Mul#(BYTE_WIDTH, keepWidth, dataWidth), 
        Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
        Mul#(BYTE_WIDTH, interByteNum, TAdd#(dataWidth, crcWidth)),
        ReduceBalancedTree#(keepWidth, CrcResult#(crcWidth)),
        ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth))
    );

    RawBusReceiver#(AxiStream#(keepWidth, dataWidth)) rawBusReceiver <- mkRawBusReceiver;
    RawBusSender#(CrcResult#(crcWidth)) rawBusSender <- mkRawBusSender;
    CrcAxiStream#(crcWidth, keepWidth, dataWidth) crcAxiStream <- mkCrcAxiStream(conf);

    mkConnection(rawBusReceiver.out, crcAxiStream.crcReq);
    mkConnection(crcAxiStream.crcResp, rawBusSender.in);
    RawAxiStreamRecv#(keepWidth, dataWidth) rawAxiRecv <- mkRawBusRecvToRawAxiStream(rawBusReceiver.in);
    
    interface RawAxiStreamRecv crcReq = rawAxiRecv;
    interface RawBusSend crcResp = rawBusSender.out;
endmodule

