#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

if output="$(bash "${BKP_SCRIPT}" -c one.txt two.txt 2>&1)"; then
    echo "FAIL: Expected merged compression without archive name to fail"
    exit 1
fi

grep -F "Merged compression with multiple targets requires -a or --archive-name." <<<"${output}"
[[ ! -e bundle.bkp.tar.gz ]]

pass_test "Merged compression requires archive name for multiple targets"