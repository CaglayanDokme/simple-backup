#!/bin/bash

# ============================================================================
# run-all.sh - Runs the full shell test suite and prints a summary
# ============================================================================

set -uo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_ROOT
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

passed=0
failed=0
failed_tests=()

run_test() {
    local test_script="$1"

    echo "==> $(basename "${test_script}")"

    if bash "${test_script}"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
        failed_tests+=("$(basename "${test_script}")")
    fi

    echo
}

main() {
    local discovered_tests=()
    local test_script=""
    local total=0

    shopt -s nullglob
    discovered_tests=("${TEST_ROOT}"/*.sh)
    shopt -u nullglob

    for test_script in "${discovered_tests[@]}"; do
        case "$(basename "${test_script}")" in
            testlib.bash|"${SCRIPT_NAME}")
                continue
                ;;
        esac

        run_test "${test_script}"
    done

    total=$((passed + failed))

    echo "Summary: ${passed} passed, ${failed} failed, ${total} total"

    if (( failed > 0 )); then
        echo "Failed tests:"
        for test_script in "${failed_tests[@]}"; do
            echo "  - ${test_script}"
        done
        exit 1
    fi

    if (( total == 0 )); then
        echo "No test scripts found."
    fi
}

main "$@"