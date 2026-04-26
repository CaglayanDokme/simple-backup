#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

mkdir mixed-inputs
cd mixed-inputs || exit 1

touch file0 file0.bkp archive.bkp.tar.gz
output="$(bash "${BKP_SCRIPT}" -t file0 file0.bkp archive.bkp.tar.gz 2>&1)"

shopt -s nullglob
timestamp_backups=(file0.*.bkp)
shopt -u nullglob

[[ ${#timestamp_backups[@]} -eq 1 ]]
[[ -f file0.bkp ]]
grep -E 'Backed up: file0 -> \./file0\.[0-9]{14}\.bkp' <<<"${output}"
grep -F "Warning: omitting backup file: file0.bkp" <<<"${output}"
grep -F "Warning: omitting backup file: archive.bkp.tar.gz" <<<"${output}"

cd "${TEST_DIR}" || exit 1
mkdir all-backups
cd all-backups || exit 1

touch file0.bkp archive.bkp.tar.gz

set +e
output="$(bash "${BKP_SCRIPT}" file0.bkp archive.bkp.tar.gz 2>&1)"
status=$?
set -e

[[ ${status} -eq 1 ]]
grep -F "Warning: omitting backup file: file0.bkp" <<<"${output}"
grep -F "Warning: omitting backup file: archive.bkp.tar.gz" <<<"${output}"
grep -F "Error: All specified paths are backup files." <<<"${output}"

pass_test "Backup artifacts are omitted with warnings"