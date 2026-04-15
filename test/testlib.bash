#!/bin/bash

# ============================================================================
# Shared helpers for shell-based backup tests
# ============================================================================

readonly TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
readonly BKP_SCRIPT="${REPO_ROOT}/src/backup.sh"

TEST_DIR=""

cleanup_test_env() {
    if [[ -n "${TEST_DIR}" && -d "${TEST_DIR}" ]]; then
        rm -rf "${TEST_DIR}"
    fi
}

setup_test_env() {
    TEST_DIR="$(mktemp -d)"
    trap cleanup_test_env EXIT
    cd "${TEST_DIR}"
}

pass_test() {
    echo "Test Passed: $1"
}
