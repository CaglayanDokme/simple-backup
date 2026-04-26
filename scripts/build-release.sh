#!/bin/bash

# ============================================================================
# build-release.sh - Build and verify the release artifact
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT
readonly SOURCE_FILE="${REPO_ROOT}/src/backup.sh"
readonly OUTPUT_FILE="${REPO_ROOT}/bkp"

error() {
    echo "[✗] Error: $*" >&2
}

info() {
    echo "[→] $*"
}

success() {
    echo "[✓] $*"
}

show_help() {
    cat <<EOF
Usage: scripts/build-release.sh [OPTIONS] <version-tag>

Builds the release artifact at ./bkp and verifies the embedded version.

Options:
  -h, --help    Show this help message.

Arguments:
  version-tag   Version tag to embed, such as v0.4.2.
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi

    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
    esac

    local version="$1"
    local embedded_version=""

    if [[ ! -f "${SOURCE_FILE}" ]]; then
        error "Source file not found: ${SOURCE_FILE}"
        exit 1
    fi

    info "Building ${OUTPUT_FILE##*/} for ${version}"
    sed "s/@@VERSION@@/${version}/g" "${SOURCE_FILE}" > "${OUTPUT_FILE}"
    chmod +x "${OUTPUT_FILE}"

    embedded_version="$(bash "${OUTPUT_FILE}" --version)"
    if [[ "${embedded_version}" != "${version}" ]]; then
        error "Version mismatch: expected '${version}', got '${embedded_version}'."
        exit 1
    fi

    success "Built ${OUTPUT_FILE##*/} with embedded version ${version}"
}

main "$@"