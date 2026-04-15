#!/bin/bash
# test/symlink-resolution.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

touch target.txt
ln -s target.txt link
if bash "$BKP_SCRIPT" link 2>/dev/null; then
    echo "FAIL: Expected error when backing up symlink without -s"
    exit 1
fi

bash "$BKP_SCRIPT" -s link
[[ -f "link.bkp" ]] && [[ ! -L "link.bkp" ]]
echo "Test Passed: Symlink resolution"
