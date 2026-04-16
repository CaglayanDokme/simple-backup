#!/bin/bash

# ============================================================================
# install.sh - Installs bkp to /usr/local/bin
# Works both locally (from cloned repo) and remotely (via curl | bash)
# ============================================================================

set -euo pipefail

readonly INSTALL_DIR="/usr/local/bin"
readonly TARGET_NAME="bkp"
readonly TARGET_PATH="${INSTALL_DIR}/${TARGET_NAME}"
readonly GITHUB_RAW="https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master"

error() {
    echo "[✗] Error: $*" >&2
}

info() {
    echo "[→] $*"
}

success() {
    echo "[✓] $*"
}

# Try to get the script content from local file or GitHub
get_script_content() {
    local script_dir
    local source_file

    # Try to find local source file first
    if [[ -n "${BASH_SOURCE[0]}" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" 2>/dev/null && pwd || echo ".")"
        source_file="${script_dir}/src/backup.sh"

        if [[ -f "${source_file}" ]]; then
            info "Using local source from: ${source_file}"
            cat "${source_file}"
            return 0
        fi
    fi

    # Fall back to downloading from GitHub
    info "Downloading from GitHub..."

    # Try curl first
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${GITHUB_RAW}/src/backup.sh" || return 1
        return 0
    fi

    # Fall back to wget
    if command -v wget >/dev/null 2>&1; then
        wget -qO- "${GITHUB_RAW}/src/backup.sh" || return 1
        return 0
    fi

    error "Neither curl nor wget found. Please install one and try again."
    return 1
}

run_privileged() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        error "sudo is required to install ${TARGET_NAME} into ${INSTALL_DIR}."
        exit 1
    fi
}

install_script() {
    info "Installing ${TARGET_NAME} to ${TARGET_PATH}..."

    local script_content
    local temp_file

    script_content=$(get_script_content) || exit 1
    temp_file=$(mktemp) || exit 1

    # Write content to temp file
    echo "${script_content}" > "${temp_file}" || exit 1

    # Move to target location with privilege elevation
    run_privileged mv "${temp_file}" "${TARGET_PATH}" || exit 1
    run_privileged chmod +x "${TARGET_PATH}" || exit 1

    success "Installation complete!"
    info "You can now use the '${TARGET_NAME}' command."

    # Verify installation
    if command -v "${TARGET_NAME}" >/dev/null 2>&1; then
        success "Verified: '${TARGET_NAME}' is available in PATH"
    fi
}

main() {
    install_script
}

main "$@"
