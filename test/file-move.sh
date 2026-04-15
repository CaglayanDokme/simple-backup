#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch file2.txt
bash "${BKP_SCRIPT}" -m file2.txt
[[ ! -e file2.txt && -f file2.txt.bkp ]]
pass_test "File move"
