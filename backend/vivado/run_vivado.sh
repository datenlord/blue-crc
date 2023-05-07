#!/bin/bash

crc_width_opt=(8 16 32)
axi_width_opt=(64 128 256 512)

mkdir -p ${log_dir}

for crc_width in ${crc_width_opt[@]}; do
    for axi_width in ${axi_width_opt[@]}; do
        make vivado CRC_WIDTH=${crc_width} AXI_WIDTH=${axi_width}
        rm -f *.mem
    done
done
