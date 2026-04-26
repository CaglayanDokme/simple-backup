#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

printf 'plain\n' > plain.txt
BKP_TAR_BIN=missing-tar BKP_GZIP_BIN=missing-gzip bash "${BKP_SCRIPT}" plain.txt
[[ -f plain.txt.bkp ]]

printf 'archive\n' > archive.txt
if BKP_TAR_BIN=missing-tar BKP_GZIP_BIN=missing-gzip bash "${BKP_SCRIPT}" -c archive.txt >compress.out 2>compress.err; then
    echo "Expected compressed backup to fail when tar and gzip are unavailable" >&2
    exit 1
fi

grep -F "Compression requires 'tar' and 'gzip' to be installed." compress.err

pass_test "Compression requires tar and gzip only when requested"