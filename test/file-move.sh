#!/bin/bash
# test/file-move.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

touch file2.txt
bash "$BKP_SCRIPT" -m file2.txt
[[ ! -e "file2.txt" ]] && [[ -f "file2.txt.bkp" ]]
echo "Test Passed: File move"
