#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch time_file
bash "${BKP_SCRIPT}" -t time_file
shopt -s nullglob
matches=(time_file.*.bkp)
[[ ${#matches[@]} -gt 0 ]]
pass_test "Timestamp"
