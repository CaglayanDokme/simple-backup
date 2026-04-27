#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir dir1 dir2
printf 'alpha\n' > dir1/one.txt
printf 'beta\n' > dir2/two.txt

if output="$(bash "${BKP_SCRIPT}" -c -a bundle dir1/one.txt dir2/two.txt 2>&1)"; then
    echo "FAIL: Expected merged compression across directories to fail without destination"
    exit 1
fi

grep -F "Merged compression targets are in different directories. Use -d or --destination to specify the output location." <<<"${output}"
[[ ! -e bundle.bkp.tar.gz ]]
[[ ! -e dir1/bundle.bkp.tar.gz ]]
[[ ! -e dir2/bundle.bkp.tar.gz ]]

pass_test "Merged compression requires destination for different target directories"