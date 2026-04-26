#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

bash "${BKP_SCRIPT}" --compress=separate one.txt two.txt

[[ -f one.txt.bkp.tar.gz && -f two.txt.bkp.tar.gz ]]
[[ "$(tar xOzf one.txt.bkp.tar.gz one.txt)" == "alpha" ]]
[[ "$(tar xOzf two.txt.bkp.tar.gz two.txt)" == "beta" ]]

pass_test "Separate compression keeps one archive per target"