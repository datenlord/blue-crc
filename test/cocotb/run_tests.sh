#!/bin/bash

log_dir="logs"
crc_width_opt=(8 16 32)
axi_width_opt=(64 128 256 512)
protocol_opt=()
test_results=()
modules=()
pass_all=0

mkdir -p ${log_dir}

for crc_width in ${crc_width_opt[@]}; do
    for axi_width in ${axi_width_opt[@]}; do
        module="mkCrc${crc_width}AxiStream${axi_width}"
        log_file="${log_dir}/${module}.log"
        echo "Generate Loopup Tables for ${module}"
        python3 ../../src/gen_crc_tab.py ${crc_width} ${axi_width}

        echo "Generate verilog source files"
        make verilog CRC_WIDTH=${crc_width} AXI_WIDTH=${axi_width} > ${log_file}
        
        echo "Start Cocotb Tests of ${module}"
        python3 testCrcAxiStream.py ${crc_width} ${axi_width} >> ${log_file}

        test_results=(${test_results[@]} $?)
        modules=(${modules[@]} ${module})
        rm -f *.dat
    done
done

echo "Complete All tests"
for ((i=0; i<${#test_results[@]}; i++));
do
    if [ ${test_results[i]} == 0 ]
    then
        echo "Pass tests of ${modules[i]}"
    else
        echo "Fail tests of ${modules[i]}"
        pass_all=1
    fi
done

return ${pass_all}