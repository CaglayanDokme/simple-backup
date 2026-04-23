#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/testlib.bash"

setup_test_env

cp "${INSTALL_SCRIPT}" "${TEST_DIR}/install.sh"

if INSTALL_DIR="${TEST_DIR}/bin" bash "${TEST_DIR}/install.sh" --version master >"${TEST_DIR}/stderr.log" 2>&1; then
    exit 1
fi

grep -q 'Invalid version tag: master' "${TEST_DIR}/stderr.log"

pass_test "Installer rejects invalid version tag"