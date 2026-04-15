#!/bin/bash

# ============================================================================
# install.sh - Installs src/backup.sh to /usr/local/bin as 'bkp'
# ============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_DIR="/usr/local/bin"
readonly SOURCE_FILE="${SCRIPT_DIR}/src/backup.sh"
readonly TARGET_NAME="bkp"
readonly TARGET_PATH="${INSTALL_DIR}/${TARGET_NAME}"

error() {
    echo "Error: $*" >&2
}

require_source_file() {
    if [[ ! -f "${SOURCE_FILE}" ]]; then
        error "Source file not found: ${SOURCE_FILE}"
        exit 1
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
    echo "Installing ${SOURCE_FILE} to ${TARGET_PATH}..."
    run_privileged cp "${SOURCE_FILE}" "${TARGET_PATH}"
    run_privileged chmod +x "${TARGET_PATH}"
    echo "Installation complete. You can now use the '${TARGET_NAME}' command."
}

main() {
    require_source_file
    install_script
}

main "$@"
