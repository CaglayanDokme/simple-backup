#!/bin/bash

# ============================================================================
# install.sh - Downloads and installs bkp from GitHub Releases
# Supports installing the latest release or a specific tagged version.
# Uses symlink-based versioning: bkp -> bkp-v0.2.0
# ============================================================================

set -euo pipefail

readonly INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
readonly COMPLETION_DIR="${COMPLETION_DIR:-/usr/share/bash-completion/completions}"
readonly TARGET_NAME="${TARGET_NAME:-bkp}"
readonly COMPLETION_ASSET_NAME="${TARGET_NAME}-completion.bash"
readonly REPOSITORY="CaglayanDokme/simple-backup"
readonly GITHUB_RELEASES_URL="https://github.com/${REPOSITORY}/releases"

TEMP_BINARY_FILE=""
TEMP_COMPLETION_FILE=""
REQUESTED_VERSION=""

cleanup() {
    local temp_file

    for temp_file in "${TEMP_BINARY_FILE}" "${TEMP_COMPLETION_FILE}"; do
        if [[ -n "${temp_file}" && -f "${temp_file}" ]]; then
            rm -f "${temp_file}"
        fi
    done
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
Usage: install.sh [OPTIONS]

Options:
  --version TAG    Install a specific tagged release (for example: v0.2.0).
  -h, --help       Show this help message.

Environment:
    INSTALL_DIR      Override the binary install directory.
    COMPLETION_DIR   Override the bash-completion install directory.

When no version is provided, the latest published GitHub Release is installed.
Old versions are kept alongside new ones for rollback:
  ${INSTALL_DIR}/${TARGET_NAME}        -> ${TARGET_NAME}-v0.2.0  (symlink)
  ${INSTALL_DIR}/${TARGET_NAME}-v0.2.0                           (binary)
  ${INSTALL_DIR}/${TARGET_NAME}-v0.1.0                           (previous)

If ${COMPLETION_DIR} exists, the installer also places bash completion at:
    ${COMPLETION_DIR}/${TARGET_NAME}
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
                    error "--version requires a tag argument."
                    exit 1
                fi
                REQUESTED_VERSION="$2"
                shift 2
                ;;
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
}

validate_version_tag() {
    local version_tag="$1"

    if [[ ! "${version_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid version tag: ${version_tag}. Expected a release tag like v0.2.0."
        return 1
    fi
}

download() {
    local url="$1"
    local destination="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${url}" -o "${destination}" || return 1
        return 0
    fi

    if command -v wget >/dev/null 2>&1; then
        wget -qO "${destination}" "${url}" || return 1
        return 0
    fi

    error "Neither curl nor wget found. Please install one and try again."
    return 1
}

validate_payload() {
    local script_file="$1"

    if [[ ! -s "${script_file}" ]]; then
        error "Downloaded payload is empty."
        return 1
    fi

    if ! head -n 1 "${script_file}" | grep -qx '#!/bin/bash'; then
        error "Downloaded payload does not look like the bkp script."
        return 1
    fi
}

validate_completion_payload() {
    local completion_file="$1"

    if [[ ! -s "${completion_file}" ]]; then
        error "Downloaded completion payload is empty."
        return 1
    fi

    if ! grep -qx 'complete -F _bkp bkp' "${completion_file}"; then
        error "Downloaded payload does not look like the bkp completion script."
        return 1
    fi
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
    local binary_download_url
    local completion_download_url
    local version

    if [[ -n "${REQUESTED_VERSION}" ]]; then
        validate_version_tag "${REQUESTED_VERSION}" || exit 1
        binary_download_url="${GITHUB_RELEASES_URL}/download/${REQUESTED_VERSION}/${TARGET_NAME}"
        completion_download_url="${GITHUB_RELEASES_URL}/download/${REQUESTED_VERSION}/${COMPLETION_ASSET_NAME}"
    else
        binary_download_url="${GITHUB_RELEASES_URL}/latest/download/${TARGET_NAME}"
        completion_download_url="${GITHUB_RELEASES_URL}/latest/download/${COMPLETION_ASSET_NAME}"
    fi

    TEMP_BINARY_FILE="$(mktemp)" || exit 1

    info "Downloading ${TARGET_NAME} from GitHub Releases..."
    download "${binary_download_url}" "${TEMP_BINARY_FILE}" || {
        error "Download failed. Check the version tag and try again."
        exit 1
    }

    validate_payload "${TEMP_BINARY_FILE}" || exit 1

    version="$(bash "${TEMP_BINARY_FILE}" --version)" || {
        error "Failed to extract version from downloaded script."
        exit 1
    }

    local versioned_name="${TARGET_NAME}-${version}"
    local versioned_path="${INSTALL_DIR}/${versioned_name}"
    local symlink_path="${INSTALL_DIR}/${TARGET_NAME}"

    info "Installing ${versioned_name} to ${INSTALL_DIR}..."

    run_privileged mkdir -p "${INSTALL_DIR}" || exit 1
    run_privileged install -m 0755 "${TEMP_BINARY_FILE}" "${versioned_path}" || exit 1
    run_privileged ln -sf "${versioned_name}" "${symlink_path}" || exit 1

    success "Installed ${versioned_name}"
    info "${symlink_path} -> ${versioned_name}"

    if [[ -d "${COMPLETION_DIR}" ]]; then
        TEMP_COMPLETION_FILE="$(mktemp)" || exit 1

        info "Downloading bash completion from GitHub Releases..."
        if download "${completion_download_url}" "${TEMP_COMPLETION_FILE}"; then
            if validate_completion_payload "${TEMP_COMPLETION_FILE}"; then
                run_privileged install -m 0644 "${TEMP_COMPLETION_FILE}" "${COMPLETION_DIR}/${TARGET_NAME}" || exit 1
                success "Installed bash completion to ${COMPLETION_DIR}/${TARGET_NAME}"
            else
                info "Skipping bash completion installation because the downloaded asset was not valid."
            fi
        else
            info "Skipping bash completion installation because the release does not provide ${COMPLETION_ASSET_NAME}."
        fi
    else
        info "Skipping bash completion installation because ${COMPLETION_DIR} does not exist."
    fi

    if command -v "${TARGET_NAME}" >/dev/null 2>&1; then
        success "Verified: '${TARGET_NAME}' is available in PATH ($(${TARGET_NAME} --version))"
    fi
}

main() {
    parse_args "$@"
    install_script
}

main "$@"
