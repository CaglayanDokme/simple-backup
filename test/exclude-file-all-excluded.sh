#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

touch only.cpp

if output="$(bash "${BKP_SCRIPT}" --exclude '*.cpp' only.cpp 2>&1)"; then
    echo "FAIL: Expected exclude-only file backup to abort"
    exit 1
fi

grep -F "Error: Target only.cpp is excluded by the provided patterns." <<<"${output}"
[[ ! -e only.cpp.bkp ]]

pass_test "File backup aborts when target is excluded"