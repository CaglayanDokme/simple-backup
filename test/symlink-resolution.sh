#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch target.txt
ln -s target.txt link
if bash "${BKP_SCRIPT}" link 2>/dev/null; then
    echo "FAIL: Expected error when backing up symlink without -s"
    exit 1
fi

bash "${BKP_SCRIPT}" -s link
[[ -f link.bkp && ! -L link.bkp ]]
pass_test "Symlink resolution"
