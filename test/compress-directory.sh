#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir docs
printf 'alpha\n' > docs/a.txt
printf 'beta\n' > docs/b.txt

bash "${BKP_SCRIPT}" -cr docs

[[ -d docs && -f docs.bkp.tar.gz ]]
grep -Fx 'docs/' < <(tar tzf docs.bkp.tar.gz)
grep -Fx 'docs/a.txt' < <(tar tzf docs.bkp.tar.gz)
grep -Fx 'docs/b.txt' < <(tar tzf docs.bkp.tar.gz)

pass_test "Compressed directory backup"