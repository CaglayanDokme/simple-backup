#!/bin/bash
# test/multiple-files.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

touch mult1 mult2
bash "$BKP_SCRIPT" mult1 mult2
[[ -f "mult1.bkp" ]] && [[ -f "mult2.bkp" ]]
echo "Test Passed: Multiple files"
