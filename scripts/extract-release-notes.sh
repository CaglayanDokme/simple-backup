#!/bin/bash

# ============================================================================
# extract-release-notes.sh - Extract release notes for a release tag
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
    echo "[→] $*" >&2
}

success() {
    echo "[✓] $*" >&2
}

show_help() {
    cat <<EOF
Usage: scripts/extract-release-notes.sh [OPTIONS] <version-tag> [output-file]

Extracts release notes for the given version from docs/changelog.md.

Options:
  -h, --help    Show this help message.

Arguments:
  version-tag   Version tag to extract, such as v0.4.2.
  output-file   Optional file path to also write the extracted notes to.
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

    local tag="$1"
    local output_file="${2:-}"
    local header_pattern="^## ${tag} -"
    local start_line=""
    local total_lines=""
    local next_section_line=""
    local end_line=""
    local body=""

    if [[ ! -f "${CHANGELOG}" ]]; then
        error "Changelog not found: ${CHANGELOG}"
        exit 1
    fi

    start_line="$(grep -n "${header_pattern}" "${CHANGELOG}" | head -n1 | cut -d: -f1)" || true

    if [[ -z "${start_line}" ]]; then
        error "Changelog entry not found for ${tag}."
        error "Expected a header matching '## ${tag} - <date>' in ${CHANGELOG}."
        exit 1
    fi

    total_lines="$(wc -l < "${CHANGELOG}")"
    next_section_line="$(tail -n +"$((start_line + 1))" "${CHANGELOG}" | grep -n '^## ' | head -n1 | cut -d: -f1)" || true

    if [[ -n "${next_section_line}" ]]; then
        end_line="$((start_line + next_section_line - 1))"
    else
        end_line="${total_lines}"
    fi

    body="$(sed -n "$((start_line + 1)),${end_line}p" "${CHANGELOG}" | sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba;}')"

    if [[ -n "${output_file}" ]]; then
        printf '%s\n' "${body}" > "${output_file}"
        info "Wrote release notes to ${output_file}"
    fi

    printf '%s\n' "${body}"
    success "Extracted release notes for ${tag}"
}

main "$@"