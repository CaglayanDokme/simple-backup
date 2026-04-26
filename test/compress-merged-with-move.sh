#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

bash "${BKP_SCRIPT}" -c -a bundle -m one.txt two.txt

[[ ! -e one.txt && ! -e two.txt ]]
[[ -f bundle.bkp.tar.gz ]]
grep -Fx 'one.txt' < <(tar tzf bundle.bkp.tar.gz)
grep -Fx 'two.txt' < <(tar tzf bundle.bkp.tar.gz)

pass_test "Merged compression supports move mode"