#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

bash "${BKP_SCRIPT}" -c -a bundle -t one.txt two.txt

shopt -s nullglob
archives=(bundle.*.bkp.tar.gz)
shopt -u nullglob

[[ ${#archives[@]} -eq 1 ]]
grep -Fx 'one.txt' < <(tar tzf "${archives[0]}")
grep -Fx 'two.txt' < <(tar tzf "${archives[0]}")

pass_test "Merged compression supports timestamped archive names"