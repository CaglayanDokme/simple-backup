#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch force_test.txt
bash "${BKP_SCRIPT}" force_test.txt
echo "Original Content" > force_test.txt
bash "${BKP_SCRIPT}" -f force_test.txt
grep -q "Original Content" force_test.txt.bkp
pass_test "Force overwrite"
