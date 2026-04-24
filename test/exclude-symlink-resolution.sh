#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir dir
printf 'keep\n' > dir/keep.txt
printf 'target\n' > target.txt
ln -s ../target.txt dir/link

bash "${BKP_SCRIPT}" -rs --exclude 'keep.txt' dir

[[ -f dir.bkp/link ]]
[[ ! -L dir.bkp/link ]]
[[ ! -e dir.bkp/keep.txt ]]

pass_test "Exclude works with symlink resolution"