#!/bin/bash

# ============================================================================
# Shared helpers for shell-based backup tests
# ============================================================================

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_ROOT
REPO_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
readonly REPO_ROOT
# shellcheck disable=SC2034
BKP_SCRIPT="${REPO_ROOT}/src/backup.sh"
export BKP_SCRIPT
readonly BKP_SCRIPT
# shellcheck disable=SC2034
INSTALL_SCRIPT="${REPO_ROOT}/install.sh"
export INSTALL_SCRIPT
readonly INSTALL_SCRIPT

TEST_DIR=""

cleanup_test_env() {
    if [[ -n "${TEST_DIR}" && -d "${TEST_DIR}" ]]; then
        rm -rf "${TEST_DIR}"
    fi
}

setup_test_env() {
    TEST_DIR="$(mktemp -d)"
    trap cleanup_test_env EXIT
    cd "${TEST_DIR}" || exit 1
}

pass_test() {
    echo "Test Passed: $1"
}

current_repo_version() {
    if command -v git >/dev/null 2>&1; then
        git -C "${REPO_ROOT}" describe --tags --dirty --always 2>/dev/null && return 0
    fi

    printf 'dev\n'
}
