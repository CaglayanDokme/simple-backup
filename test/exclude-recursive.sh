#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir -p proj/build proj/src
printf 'bundle\n' > proj/build/output.txt
printf 'main\n' > proj/src/main.cpp
printf 'notes\n' > proj/readme.md

bash "${BKP_SCRIPT}" -r --exclude build --exclude '*.cpp' proj

[[ -d proj.bkp ]]
[[ ! -e proj.bkp/build ]]
[[ ! -e proj.bkp/src/main.cpp ]]
[[ -f proj.bkp/readme.md ]]

pass_test "Recursive exclude filters files and folders"