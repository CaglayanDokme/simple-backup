#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch mult1 mult2
bash "${BKP_SCRIPT}" mult1 mult2
[[ -f mult1.bkp && -f mult2.bkp ]]
pass_test "Multiple files"
