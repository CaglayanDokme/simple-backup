#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'hello\n' > note.txt
bash "${BKP_SCRIPT}" -c note.txt

[[ -f note.txt && -f note.txt.bkp.tar.gz ]]
[[ "$(tar tzf note.txt.bkp.tar.gz)" == "note.txt" ]]
[[ "$(tar xOzf note.txt.bkp.tar.gz note.txt)" == "hello" ]]

pass_test "Compressed file backup"