#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch file1.txt
bash "${BKP_SCRIPT}" file1.txt
[[ -f file1.txt && -f file1.txt.bkp ]]
pass_test "Basic file copy"
