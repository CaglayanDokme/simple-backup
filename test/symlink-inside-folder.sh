#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir sym_dir
touch target.txt
ln -s ../target.txt sym_dir/inner_link
if bash "${BKP_SCRIPT}" -r sym_dir 2>/dev/null; then
    echo "FAIL: Expected error when folder contains symlink without -s"
    exit 1
fi

bash "${BKP_SCRIPT}" -rs sym_dir
[[ -d sym_dir.bkp && -f sym_dir.bkp/inner_link && ! -L sym_dir.bkp/inner_link ]]
pass_test "Symlink resolution inside folder"
