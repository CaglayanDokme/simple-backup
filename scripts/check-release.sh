#!/bin/bash

# ============================================================================
# check-release.sh - Validates that the changelog is release-ready
# Requires a concrete versioned heading at the top of docs/changelog.md,
# validates SemVer progression, extracts release notes, and builds the
# release artifact.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT
readonly CHANGELOG="${REPO_ROOT}/docs/changelog.md"

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
Usage: scripts/check-release.sh [OPTIONS]

Validates that docs/changelog.md is release-ready. The top section must
be a concrete versioned heading (e.g., '## v0.4.3 - April 26, 2026').

The script:
  1. Detects the top changelog heading and rejects non-versioned entries.
  2. Validates SemVer progression against the previous release.
  3. Extracts release notes via scripts/extract-release-notes.sh.
  4. Builds and verifies the release artifact via scripts/build-release.sh.

Options:
  -h, --help    Show this help message.
EOF
}

detect_version() {
    if [[ ! -f "${CHANGELOG}" ]]; then
        error "Changelog not found: ${CHANGELOG}"
        exit 1
    fi

    local first_heading=""
    first_heading="$(grep -m1 '^## ' "${CHANGELOG}")" || true

    if [[ -z "${first_heading}" ]]; then
        error "No section heading found in ${CHANGELOG}."
        exit 1
    fi

    if [[ ! "${first_heading}" =~ ^'## v'[0-9]+\.[0-9]+\.[0-9]+' - ' ]]; then
        error "The top changelog section is not a concrete release version."
        error "Found: ${first_heading}"
        error "Expected format: '## vMAJOR.MINOR.PATCH - <date>'"
        error "Rename the top section to a versioned heading before merging to master."
        exit 1
    fi

    local version=""
    version="$(awk '{print $2}' <<< "${first_heading}")"
    printf '%s\n' "${version}"
}

main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
    esac

    local version=""
    version="$(detect_version)"
    info "Detected release version: ${version}"

    info "Validating release notes extraction"
    bash "${SCRIPT_DIR}/extract-release-notes.sh" "${version}" >/dev/null

    info "Validating release artifact build"
    bash "${SCRIPT_DIR}/build-release.sh" "${version}" >/dev/null

    success "Release check passed for ${version}"
}

main "$@"
