#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'move-me\n' > draft.txt
bash "${BKP_SCRIPT}" -cm draft.txt

[[ ! -e draft.txt && -f draft.txt.bkp.tar.gz ]]
[[ "$(tar xOzf draft.txt.bkp.tar.gz draft.txt)" == "move-me" ]]

pass_test "Compressed move backup"