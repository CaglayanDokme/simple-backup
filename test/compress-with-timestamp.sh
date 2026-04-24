#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'timestamp\n' > journal.txt
bash "${BKP_SCRIPT}" -ct journal.txt

shopt -s nullglob
archives=(journal.txt.*.bkp.tar.gz)
shopt -u nullglob

[[ ${#archives[@]} -eq 1 ]]
[[ -f "${archives[0]}" ]]
[[ "$(tar xOzf "${archives[0]}" journal.txt)" == "timestamp" ]]

pass_test "Compressed timestamp backup"