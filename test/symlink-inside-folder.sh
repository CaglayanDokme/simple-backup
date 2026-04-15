#!/bin/bash
# test/symlink-inside-folder.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

mkdir sym_dir
touch target.txt
ln -s ../target.txt sym_dir/inner_link
if bash "$BKP_SCRIPT" -r sym_dir 2>/dev/null; then
    echo "FAIL: Expected error when folder contains symlink without -s"
    exit 1
fi

bash "$BKP_SCRIPT" -rs sym_dir
[[ -d "sym_dir.bkp" ]] && [[ -f "sym_dir.bkp/inner_link" ]] && [[ ! -L "sym_dir.bkp/inner_link" ]]
echo "Test Passed: Symlink resolution inside folder"
