#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir dest_dir
touch dest_file
bash "${BKP_SCRIPT}" -d dest_dir dest_file
[[ -f dest_dir/dest_file.bkp ]]
pass_test "Destination directory"
