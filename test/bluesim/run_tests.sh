#!/bin/bash

log_dir="logs"
crc_width_opt=(8 16 32)
axi_width_opt=(64 128 256 512)
protocol_opt=()
pass_all=0

mkdir -p ${log_dir}
for crc_width in ${crc_width_opt[@]}; do
    for axi_width in ${axi_width_opt[@]}; do
        module="mkTestCrc${crc_width}AxiStream${axi_width}"
        log_file="${log_dir}/${module}.log"
        echo "Generate Loopup Tables for ${module}"
        python3 ../../src/gen_crc_tab.py ${crc_width} ${axi_width}

        echo "Start Testing ${module}"
        make CRC_WIDTH=${crc_width} AXI_WIDTH=${axi_width} > ${log_file}
        result=$(tail -n 1 ${log_file})
        
        if [ ${result} == 0 ]
        then
            echo "Pass tests of ${module}"
        else
            echo "Tests of ${module} fail"
            pass_all=1
        fi
        echo ""
        rm -f *.mem
    done
done
echo "Complete All tests"
return $pass_all