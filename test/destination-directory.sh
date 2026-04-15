#!/bin/bash
# test/destination-directory.sh
set -e
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
cd "$TEST_DIR"
BKP_SCRIPT="$(pwd)/../../src/backup.sh"

mkdir dest_dir
touch dest_file
bash "$BKP_SCRIPT" -d dest_dir dest_file
[[ -f "dest_dir/dest_file.bkp" ]]
echo "Test Passed: Destination directory"
