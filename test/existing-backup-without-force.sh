#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'first version\n' > note.txt
bash "${BKP_SCRIPT}" note.txt
printf 'second version\n' > note.txt

set +e
output="$(bash "${BKP_SCRIPT}" note.txt 2>&1)"
status=$?
set -e

[[ ${status} -ne 0 ]]
grep -q "Backup already exists: ./note.txt.bkp" <<< "${output}"
grep -q "first version" note.txt.bkp
if grep -q "second version" note.txt.bkp; then
    exit 1
fi

pass_test "Existing backup requires force"