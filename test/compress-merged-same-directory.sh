#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir sub
printf 'alpha\n' > sub/one.txt
printf 'beta\n' > sub/two.txt

bash "${BKP_SCRIPT}" -c -a bundle sub/one.txt sub/two.txt

[[ -f sub/bundle.bkp.tar.gz ]]
[[ ! -e bundle.bkp.tar.gz ]]
grep -Fx 'one.txt' < <(tar tzf sub/bundle.bkp.tar.gz)
grep -Fx 'two.txt' < <(tar tzf sub/bundle.bkp.tar.gz)
[[ "$(tar xOzf sub/bundle.bkp.tar.gz one.txt)" == "alpha" ]]
[[ "$(tar xOzf sub/bundle.bkp.tar.gz two.txt)" == "beta" ]]

pass_test "Merged compression writes archives beside same-directory targets"