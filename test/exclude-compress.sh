#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir docs
printf 'alpha\n' > docs/a.txt
printf 'beta\n' > docs/b.cpp

bash "${BKP_SCRIPT}" -cr --exclude '*.cpp' docs

[[ -f docs.bkp.tar.gz ]]
grep -Fx 'docs/' < <(tar tzf docs.bkp.tar.gz)
grep -Fx 'docs/a.txt' < <(tar tzf docs.bkp.tar.gz)

if grep -Fx 'docs/b.cpp' < <(tar tzf docs.bkp.tar.gz); then
    echo "FAIL: Expected docs/b.cpp to be excluded from archive"
    exit 1
fi

pass_test "Compressed backup respects exclude patterns"