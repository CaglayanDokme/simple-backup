#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

bash "${BKP_SCRIPT}" -c -a bundle one.txt two.txt

[[ -f bundle.bkp.tar.gz ]]
grep -Fx 'one.txt' < <(tar tzf bundle.bkp.tar.gz)
grep -Fx 'two.txt' < <(tar tzf bundle.bkp.tar.gz)
[[ "$(tar xOzf bundle.bkp.tar.gz one.txt)" == "alpha" ]]
[[ "$(tar xOzf bundle.bkp.tar.gz two.txt)" == "beta" ]]

pass_test "Merged compression stores multiple targets in one archive"