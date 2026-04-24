#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir dest srcdir
printf 'keep\n' > srcdir/a.txt
printf 'skip\n' > srcdir/b.tmp

bash "${BKP_SCRIPT}" -r -d dest --exclude '*.tmp' srcdir

[[ -f dest/srcdir.bkp/a.txt ]]
[[ ! -e dest/srcdir.bkp/b.tmp ]]

pass_test "Destination backups honor exclude patterns"