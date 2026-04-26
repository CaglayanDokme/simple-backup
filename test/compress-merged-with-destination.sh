#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir backups
printf 'alpha\n' > one.txt
printf 'beta\n' > two.txt

bash "${BKP_SCRIPT}" -c -a bundle -d backups one.txt two.txt

[[ -f backups/bundle.bkp.tar.gz ]]
grep -Fx 'one.txt' < <(tar tzf backups/bundle.bkp.tar.gz)
grep -Fx 'two.txt' < <(tar tzf backups/bundle.bkp.tar.gz)

pass_test "Merged compression writes named archive to destination"