import GetPut :: *;
import FIFOF :: *;
import Connectable :: *;

import CrcAxiStream :: *;
import BusConversion :: *;
import AxiStreamTypes :: *;


interface CrcRawAxiStream#(numeric type crcWidth, numeric type keepWidth, numeric type usrWidth);
    (* prefix = "s_axis" *)
    interface RawAxiStreamSlave#(keepWidth, usrWidth) rawCrcReq;
    (* prefix = "m_crc_stream" *)
    interface RawBusMaster#(CrcResult#(crcWidth)) rawCrcResp;
endinterface

module mkCrcRawAxiStream#(CrcConfig#(crcWidth) conf)(CrcRawAxiStream#(crcWidth, keepWidth, usrWidth)) 
    provisos(
        Mul#(BYTE_WIDTH, keepWidth, dataWidth), 
        Mul#(BYTE_WIDTH, crcByteNum, crcWidth),
        Mul#(BYTE_WIDTH, interByteNum, TAdd#(dataWidth, crcWidth)),
        ReduceBalancedTree#(keepWidth, CrcResult#(crcWidth)),
        ReduceBalancedTree#(crcByteNum, CrcResult#(crcWidth))
    );

    CrcAxiStream#(crcWidth, keepWidth, usrWidth) crcAxiStream <- mkCrcAxiStream(conf);
    let rawAxiStreamSlave <- mkPutToRawAxiStreamSlave(crcAxiStream.crcReq, CF);
    let rawBusMaster <- mkGetToRawBusMaster(crcAxiStream.crcResp, CF);
    
    interface RawAxiStreamRecv rawCrcReq = rawAxiStreamSlave;
    interface RawBusSend rawCrcResp = rawBusMaster;
endmodule

