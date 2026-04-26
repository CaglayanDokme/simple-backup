#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt

if output="$(bash "${BKP_SCRIPT}" -a bundle one.txt 2>&1)"; then
    echo "FAIL: Expected --archive-name without compression to fail"
    exit 1
fi

grep -F -- "--archive-name requires merged compression." <<<"${output}"

if output="$(bash "${BKP_SCRIPT}" --compress=separate -a bundle one.txt 2>&1)"; then
    echo "FAIL: Expected --archive-name with separate compression to fail"
    exit 1
fi

grep -F -- "--archive-name can only be used with merged compression." <<<"${output}"

pass_test "Archive name validation rejects unsupported combinations"