#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir move_sym_dir
touch target.txt
ln -s ../target.txt move_sym_dir/link
bash "${BKP_SCRIPT}" -rms move_sym_dir
[[ ! -e move_sym_dir && -f move_sym_dir.bkp/link && ! -L move_sym_dir.bkp/link ]]
pass_test "Move with symlink resolution"
