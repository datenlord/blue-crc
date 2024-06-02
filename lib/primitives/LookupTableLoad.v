
`ifdef  BSV_WARN_REGFILE_ADDR_RANGE
`else
`define BSV_WARN_REGFILE_ADDR_RANGE 0
`endif

`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif


// Multi-ported Lookup Table(ROM) -- initializable from a file.
module LookupTableLoad(
    CLK,
    ADDR_1, D_OUT_1,
    ADDR_2, D_OUT_2,
    ADDR_3, D_OUT_3,
    ADDR_4, D_OUT_4,
    ADDR_5, D_OUT_5
);
   parameter                   file = "";
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;
   parameter                   binary = 0;

   input CLK;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;

   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;

   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;

   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;

   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   reg [data_width - 1 : 0]    arr[lo:hi];


   initial
     begin : init_rom_block
	if (binary)
           $readmemb(file, arr, lo, hi);
        else
           $readmemh(file, arr, lo, hi);
     end // initial begin

   assign D_OUT_1 = arr[ADDR_1];
   assign D_OUT_2 = arr[ADDR_2];
   assign D_OUT_3 = arr[ADDR_3];
   assign D_OUT_4 = arr[ADDR_4];
   assign D_OUT_5 = arr[ADDR_5];

endmodule
