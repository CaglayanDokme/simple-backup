#!/bin/bash
# test/timestamp.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

touch time_file
bash "$BKP_SCRIPT" -t time_file
# Check if any file matching the timestamp pattern exists
ls time_file.*.bkp > /dev/null
echo "Test Passed: Timestamp"
