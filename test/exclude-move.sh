#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir work
printf 'keep\n' > work/keep.txt
printf 'skip\n' > work/drop.log

bash "${BKP_SCRIPT}" -mr --exclude '*.log' work

[[ -d work.bkp ]]
[[ -f work.bkp/keep.txt ]]
[[ ! -e work/keep.txt ]]
[[ -f work/drop.log ]]

pass_test "Move keeps excluded source entries in place"