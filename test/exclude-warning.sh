#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch sample.txt
output="$(bash "${BKP_SCRIPT}" -e '*.cpp' sample.txt 2>&1)"

[[ -f sample.txt.bkp ]]
grep -F "Warning: exclude pattern matched nothing: *.cpp" <<<"${output}"

pass_test "Unmatched exclude patterns warn once"