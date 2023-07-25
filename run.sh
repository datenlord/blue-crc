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
black --check $(find ./ -name "*.py")

# Run Cocotb Tests
echo -e "\nStart Cocotb Testbenches"
cd ${COCOTB_DIR}
python3 run_tests.py
