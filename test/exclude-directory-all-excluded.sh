#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir tree
touch tree/a.tmp

if output="$(bash "${BKP_SCRIPT}" -r --exclude '*.tmp' tree 2>&1)"; then
    echo "FAIL: Expected fully excluded directory backup to abort"
    exit 1
fi

grep -F "Error: All entries under tree are excluded." <<<"${output}"
[[ ! -e tree.bkp ]]

pass_test "Directory backup aborts when all entries are excluded"