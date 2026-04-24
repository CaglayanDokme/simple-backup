#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir backups
printf 'dest\n' > memo.txt
bash "${BKP_SCRIPT}" -c -d backups memo.txt

[[ -f memo.txt && -f backups/memo.txt.bkp.tar.gz ]]
[[ "$(tar xOzf backups/memo.txt.bkp.tar.gz memo.txt)" == "dest" ]]

pass_test "Compressed destination backup"