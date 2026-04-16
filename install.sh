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

# Resolve a local source file only when install.sh is executed from a real repo checkout.
resolve_local_source() {
    local script_source="${BASH_SOURCE[0]:-}"
    local script_dir
    local source_file

    if [[ -z "${script_source}" || "${script_source}" == "-" || ! -f "${script_source}" ]]; then
        return 1
    fi

    script_dir="$(cd "$(dirname "${script_source}")" && pwd)"
    source_file="${script_dir}/src/backup.sh"

    if [[ -f "${source_file}" ]]; then
        printf '%s\n' "${source_file}"
        return 0
    fi

    return 1
}

download_script() {
    local destination_file="$1"

    info "Downloading from GitHub..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${GITHUB_RAW}/src/backup.sh" -o "${destination_file}" || return 1
        return 0
    fi

    if command -v wget >/dev/null 2>&1; then
        wget -qO "${destination_file}" "${GITHUB_RAW}/src/backup.sh" || return 1
        return 0
    fi

    error "Neither curl nor wget found. Please install one and try again."
    return 1
}

stage_script() {
    local destination_file="$1"
    local source_file

    if source_file="$(resolve_local_source)"; then
        info "Using local source from: ${source_file}"
        cp "${source_file}" "${destination_file}"
        return 0
    fi

    download_script "${destination_file}"
}

validate_script() {
    local script_file="$1"

    if [[ ! -s "${script_file}" ]]; then
        error "Downloaded installer payload is empty."
        return 1
    fi

    if ! head -n 1 "${script_file}" | grep -qx '#!/bin/bash'; then
        error "Installer payload does not look like the bkp script."
        return 1
    fi
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

    TEMP_FILE="$(mktemp)" || exit 1

    stage_script "${TEMP_FILE}" || exit 1
    validate_script "${TEMP_FILE}" || exit 1

    run_privileged mkdir -p "${INSTALL_DIR}" || exit 1
    run_privileged install -m 0755 "${TEMP_FILE}" "${TARGET_PATH}" || exit 1

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
