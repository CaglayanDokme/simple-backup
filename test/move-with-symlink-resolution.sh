#!/bin/bash
# test/move-with-symlink-resolution.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

mkdir move_sym_dir
touch target.txt
ln -s ../target.txt move_sym_dir/link
bash "$BKP_SCRIPT" -rms move_sym_dir
[[ ! -e "move_sym_dir" ]] && [[ -f "move_sym_dir.bkp/link" ]] && [[ ! -L "move_sym_dir.bkp/link" ]]
echo "Test Passed: Move with symlink resolution"
