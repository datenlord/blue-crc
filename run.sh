#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

BASH_PROFILE=$HOME/.bash_profile
if [ -f "$BASH_PROFILE" ]; then
    source $BASH_PROFILE
fi

ROOT_DIR=`pwd`
TEST_DIR=${ROOT_DIR}/test
BLUESIM_DIR=${TEST_DIR}/bluesim
COCOTB_DIR=${TEST_DIR}/cocotb

# Check Codes format
echo -e "\nStart formatting Codes"
#black --check $(find ./ -name "*.py")

# Run Bluesim Tests
echo -e "\nStart Bluesim Tests"
cd ${BLUESIM_DIR}
#source ./run_tests.sh

# Run Cocotb Tests
echo -e "\nStart Cocotb Tests"
cd ${COCOTB_DIR}
#source ./run_tests.sh
