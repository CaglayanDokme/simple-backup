#!/bin/bash
# test/basic-file-copy.sh
set -e
BKP_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src/backup.sh"
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"

touch file1.txt
bash "$BKP_SCRIPT" file1.txt
[[ -f "file1.txt" ]] && [[ -f "file1.txt.bkp" ]]
echo "Test Passed: Basic file copy"
