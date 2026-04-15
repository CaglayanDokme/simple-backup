#!/bin/bash
# test/force-overwrite.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

touch force_test.txt
bash "$BKP_SCRIPT" force_test.txt
echo "Original Content" > force_test.txt
bash "$BKP_SCRIPT" -f force_test.txt
# If it worked, force_test.txt.bkp should exist with new content
grep "Original Content" force_test.txt.bkp > /dev/null
echo "Test Passed: Force overwrite"
