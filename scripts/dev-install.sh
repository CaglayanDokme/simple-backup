#!/bin/bash

# ============================================================================
# dev-install.sh - Installs bkp from a local repository checkout
# Embeds the current git describe version and installs via symlink.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT
readonly SOURCE_FILE="${REPO_ROOT}/src/backup.sh"

readonly INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
readonly TARGET_NAME="${TARGET_NAME:-bkp}"

TEMP_FILE=""

cleanup() {
    if [[ -n "${TEMP_FILE}" && -f "${TEMP_FILE}" ]]; then
        rm -f "${TEMP_FILE}"
    fi
}

trap cleanup EXIT

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
Usage: scripts/dev-install.sh [OPTIONS]

Installs bkp from the local repository checkout. The version is derived from
git describe and embedded into the installed script.

Options:
  -h, --help    Show this help message.

Environment:
  INSTALL_DIR   Override install directory (default: /usr/local/bin).
EOF
}

resolve_version() {
    if command -v git >/dev/null 2>&1; then
        if git -C "${REPO_ROOT}" rev-parse --show-toplevel >/dev/null 2>&1; then
            git -C "${REPO_ROOT}" describe --tags --dirty --always 2>/dev/null && return 0
        fi
    fi

    printf 'dev\n'
}

escape_sed_replacement() {
    local value="$1"

    value="${value//\\/\\\\}"
    value="${value//&/\\&}"
    value="${value//|/\\|}"

    printf '%s\n' "${value}"
}

run_privileged() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif [[ -d "${INSTALL_DIR}" && -w "${INSTALL_DIR}" ]]; then
        "$@"
    elif [[ ! -e "${INSTALL_DIR}" && -w "$(dirname "${INSTALL_DIR}")" ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        error "sudo is required to install ${TARGET_NAME} into ${INSTALL_DIR}."
        exit 1
    fi
}

install_script() {
    if [[ ! -f "${SOURCE_FILE}" ]]; then
        error "Source not found: ${SOURCE_FILE}"
        error "Run this script from a cloned simple-backup repository."
        exit 1
    fi

    TEMP_FILE="$(mktemp)" || exit 1
    cp "${SOURCE_FILE}" "${TEMP_FILE}"

    local version
    version="$(resolve_version)"

    local escaped_version
    escaped_version="$(escape_sed_replacement "${version}")"

    if ! grep -q '@@VERSION@@' "${TEMP_FILE}"; then
        error "Version placeholder not found in source script."
        exit 1
    fi

    sed -i "s|@@VERSION@@|${escaped_version}|" "${TEMP_FILE}"

    local versioned_name="${TARGET_NAME}-${version}"
    local versioned_path="${INSTALL_DIR}/${versioned_name}"
    local symlink_path="${INSTALL_DIR}/${TARGET_NAME}"

    info "Installing ${versioned_name} to ${INSTALL_DIR}..."

    run_privileged mkdir -p "${INSTALL_DIR}" || exit 1
    run_privileged install -m 0755 "${TEMP_FILE}" "${versioned_path}" || exit 1
    run_privileged ln -sf "${versioned_name}" "${symlink_path}" || exit 1

    success "Installed ${versioned_name}"
    info "${symlink_path} -> ${versioned_name}"

    if command -v "${TARGET_NAME}" >/dev/null 2>&1; then
        success "Verified: '${TARGET_NAME}' is available in PATH ($(${TARGET_NAME} --version))"
    fi
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    install_script
}

main "$@"
