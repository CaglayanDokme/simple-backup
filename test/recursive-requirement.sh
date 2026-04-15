#!/bin/bash
# test/recursive-requirement.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

mkdir folder1
if bash "$BKP_SCRIPT" folder1 2>/dev/null; then
    echo "FAIL: Expected error when backing up directory without -r"
    exit 1
fi

bash "$BKP_SCRIPT" -r folder1
[[ -d "folder1" ]] && [[ -d "folder1.bkp" ]]
echo "Test Passed: Recursive requirement"
