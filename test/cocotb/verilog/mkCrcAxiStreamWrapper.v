`ifdef CRC8_AXI64
    `define DUT mkCrc8AxiStream64
`elsif CRC8_AXI128
    `define DUT mkCrc8AxiStream128
`elsif CRC8_AXI256
    `define DUT mkCrc8AxiStream256
`elsif CRC8_AXI512
    `define DUT mkCrc8AxiStream512
`elsif CRC16_AXI64
    `define DUT mkCrc16AxiStream64
`elsif CRC16_AXI128
    `define DUT mkCrc16AxiStream128
`elsif CRC16_AXI256
    `define DUT mkCrc16AxiStream256
`elsif CRC16_AXI512
    `define DUT mkCrc16AxiStream512
`elsif CRC32_AXI64
    `define DUT mkCrc32AxiStream64
`elsif CRC32_AXI128
    `define DUT mkCrc32AxiStream128
`elsif CRC32_AXI256
    `define DUT mkCrc32AxiStream256
`elsif CRC32_AXI512
    `define DUT mkCrc32AxiStream512
`endif

module mkCrcAxiStreamWrapper#(
    parameter DATA_WIDTH = 256,
    parameter KEEP_WIDTH = 32,
    parameter CRC_WIDTH  = 32
)(
    input clk,
    input reset_n,

    input  s_axi_stream_tvalid,
    output s_axi_stream_tready,
    input  s_axi_stream_tlast,
    input  s_axi_stream_tuser,
    input [DATA_WIDTH - 1 : 0] s_axi_stream_tdata,
    input [KEEP_WIDTH - 1 : 0] s_axi_stream_tkeep,

    output m_crc_stream_valid,
    input  m_crc_stream_ready,
    output [CRC_WIDTH - 1 : 0] m_crc_stream_data
);
    `DUT crcAxiStreamInst(
        .CLK  (    clk),
        .RST_N(reset_n),
        
        .EN_axiStreamIn_put (s_axi_stream_tvalid & s_axi_stream_tready),
		.RDY_axiStreamIn_put(s_axi_stream_tready),
        .axiStreamIn_put(
            {
                s_axi_stream_tdata,
                s_axi_stream_tkeep,
                s_axi_stream_tuser,
                s_axi_stream_tlast
            }
        ),
		
        .RDY_crcResultOut_get(m_crc_stream_valid),
        .EN_crcResultOut_get(m_crc_stream_ready & m_crc_stream_valid),
        .crcResultOut_get(m_crc_stream_data)
    );

    // initial begin            
    //     $dumpfile("mkCrcAxiStream.vcd");
    //     $dumpvars(0);
    // end

endmodule