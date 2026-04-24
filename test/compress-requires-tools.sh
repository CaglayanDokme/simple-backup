#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir fake-bin
ln -s "$(command -v bash)" fake-bin/bash
ln -s "$(command -v basename)" fake-bin/basename
ln -s "$(command -v dirname)" fake-bin/dirname
ln -s "$(command -v cp)" fake-bin/cp

printf 'plain\n' > plain.txt
PATH="${PWD}/fake-bin" bash "${BKP_SCRIPT}" plain.txt
[[ -f plain.txt.bkp ]]

printf 'archive\n' > archive.txt
if PATH="${PWD}/fake-bin" bash "${BKP_SCRIPT}" -c archive.txt >compress.out 2>compress.err; then
    echo "Expected compressed backup to fail when tar and gzip are unavailable" >&2
    exit 1
fi

grep -F "Compression requires 'tar' and 'gzip' to be installed." compress.err

pass_test "Compression requires tar and gzip only when requested"