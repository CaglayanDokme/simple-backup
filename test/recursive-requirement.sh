#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir folder1
if bash "${BKP_SCRIPT}" folder1 2>/dev/null; then
    echo "FAIL: Expected error when backing up directory without -r"
    exit 1
fi

bash "${BKP_SCRIPT}" -r folder1
[[ -d folder1 && -d folder1.bkp ]]
pass_test "Recursive requirement"
