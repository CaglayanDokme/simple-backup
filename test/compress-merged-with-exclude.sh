#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir first second
printf 'keep-one\n' > first/a.txt
printf 'skip-one\n' > first/a.log
printf 'keep-two\n' > second/b.txt
printf 'skip-two\n' > second/b.log

bash "${BKP_SCRIPT}" -c -a bundle -r --exclude '*.log' first second

[[ -f bundle.bkp.tar.gz ]]
grep -Fx 'first/' < <(tar tzf bundle.bkp.tar.gz)
grep -Fx 'first/a.txt' < <(tar tzf bundle.bkp.tar.gz)
grep -Fx 'second/' < <(tar tzf bundle.bkp.tar.gz)
grep -Fx 'second/b.txt' < <(tar tzf bundle.bkp.tar.gz)

if grep -Fx 'first/a.log' < <(tar tzf bundle.bkp.tar.gz); then
    echo "FAIL: Expected first/a.log to be excluded from merged archive"
    exit 1
fi

if grep -Fx 'second/b.log' < <(tar tzf bundle.bkp.tar.gz); then
    echo "FAIL: Expected second/b.log to be excluded from merged archive"
    exit 1
fi

pass_test "Merged compression respects exclude patterns across targets"