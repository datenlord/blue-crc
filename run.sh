#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

ROOT_DIR=`pwd`
TEST_DIR=${ROOT_DIR}/test
BLUESIM_DIR=${TEST_DIR}/bluesim
COCOTB_DIR=${TEST_DIR}/cocotb

# Run Bluesim Tests
echo -e "\nStart Bluesim Tests"
cd ${BLUESIM_DIR}
source ./run_tests.sh

# Run Cocotb Tests
echo -e "\nStart Cocotb Tests"
cd ${COCOTB_DIR}
source ./run_tests.sh
