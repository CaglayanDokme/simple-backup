#!/bin/bash

# ============================================================================
# install.sh - Installs bkp to /usr/local/bin
# Works both locally (from cloned repo) and remotely (via curl | bash)
# ============================================================================

set -euo pipefail

readonly INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
readonly TARGET_NAME="${TARGET_NAME:-bkp}"
readonly TARGET_PATH="${INSTALL_DIR}/${TARGET_NAME}"
readonly REPOSITORY="CaglayanDokme/simple-backup"
readonly GITHUB_REPO_URL="https://github.com/${REPOSITORY}"
readonly GITHUB_RAW_BASE="https://raw.githubusercontent.com/${REPOSITORY}"

TEMP_FILE=""
REQUESTED_VERSION=""
EMBEDDED_VERSION=""

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
Usage: install.sh [OPTIONS]

Options:
  --version TAG    Install a specific tagged release (for example: v0.0.2).
  -h, --help       Show this help message.

When no version is provided, a local checkout installs the current working tree.
Remote installs resolve the latest published GitHub Release.
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
        error "Invalid version tag: ${version_tag}. Expected a release tag like v0.0.2."
        return 1
    fi
}

resolve_latest_release_tag() {
    local effective_url
    local release_tag=""

    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required to resolve the latest stable release. Install curl or use --version <tag>."
        return 1
    fi

    effective_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "${GITHUB_REPO_URL}/releases/latest")" || {
        error "Unable to resolve the latest release from GitHub."
        return 1
    }

    case "${effective_url}" in
        "${GITHUB_REPO_URL}/releases/tag/"*)
            release_tag="${effective_url#"${GITHUB_REPO_URL}"/releases/tag/}"
            release_tag="${release_tag%%[?#]*}"
            release_tag="${release_tag%/}"
            ;;
    esac

    if [[ -z "${release_tag}" ]]; then
        error "No GitHub Release is published yet. Create a release or use --version <tag>."
        return 1
    fi

    printf '%s\n' "${release_tag}"
}

resolve_local_version() {
    local source_file="$1"
    local source_dir

    source_dir="$(cd "$(dirname "${source_file}")" && pwd)"

    if command -v git >/dev/null 2>&1; then
        if git -C "${source_dir}" rev-parse --show-toplevel >/dev/null 2>&1; then
            git -C "${source_dir}" describe --tags --dirty --always 2>/dev/null && return 0
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

embed_version() {
    local destination_file="$1"
    local version_value="$2"
    local escaped_version

    if ! grep -q '@@VERSION@@' "${destination_file}"; then
        error "Version placeholder not found in staged script."
        return 1
    fi

    escaped_version="$(escape_sed_replacement "${version_value}")"
    sed -i "s|@@VERSION@@|${escaped_version}|" "${destination_file}"
}

ensure_version_support() {
    local script_file="$1"
    local rewritten_file

    if grep -q '@@VERSION@@' "${script_file}"; then
        return 0
    fi

    info "Adding version support to legacy tagged script..."
    rewritten_file="$(mktemp)" || return 1

    awk '
        /^readonly SCRIPT_NAME=/ {
            print
            print "readonly VERSION=\"@@VERSION@@\""
            print "readonly VERSION_PLACEHOLDER=\"@\"\"@VERSION@\"\"@\""
            next
        }
        /^parse_short_flags\(\) \{/ && !inserted_helpers {
            print "resolve_git_version() {"
            print "    local script_dir"
            print ""
            print "    if ! command -v git >/dev/null 2>&1; then"
            print "        return 1"
            print "    fi"
            print ""
            print "    script_dir=\"$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)\""
            print ""
            print "    git -C \"${script_dir}\" describe --tags --dirty --always 2>/dev/null"
            print "}"
            print ""
            print "show_version() {"
            print "    local resolved_version=\"${VERSION}\""
            print ""
            print "    if [[ \"${resolved_version}\" == \"${VERSION_PLACEHOLDER}\" ]]; then"
            print "        if ! resolved_version=\"$(resolve_git_version)\"; then"
            print "            resolved_version=\"dev\""
            print "        fi"
            print "    fi"
            print ""
            print "    printf \"%s\\n\" \"${resolved_version}\""
            print "}"
            print ""
            inserted_helpers = 1
        }
        /^  -h, --help             Show this help message\.$/ {
            print "  -v, --version          Show version information."
            print
            next
        }
        /m\) MOVE=true ;;/ && !inserted_short_version {
            print
            print "            v)"
            print "                show_version"
            print "                exit 0"
            print "                ;;"
            inserted_short_version = 1
            next
        }
        /^[[:space:]]*-h\|--help\)/ && !inserted_long_version {
            print "            -v|--version)"
            print "                show_version"
            print "                exit 0"
            print "                ;;"
            print
            inserted_long_version = 1
            next
        }
        {
            gsub(/\^\-\[fsrtm\]\+\$/, "^-[fsrtmv]+$")
            print
        }
    ' "${script_file}" > "${rewritten_file}" || {
        rm -f "${rewritten_file}"
        return 1
    }

    mv "${rewritten_file}" "${script_file}"
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
    local source_ref="$2"

    info "Downloading ${TARGET_NAME} from GitHub (${source_ref})..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${GITHUB_RAW_BASE}/${source_ref}/src/backup.sh" -o "${destination_file}" || return 1
        return 0
    fi

    if command -v wget >/dev/null 2>&1; then
        wget -qO "${destination_file}" "${GITHUB_RAW_BASE}/${source_ref}/src/backup.sh" || return 1
        return 0
    fi

    error "Neither curl nor wget found. Please install one and try again."
    return 1
}

stage_script() {
    local destination_file="$1"
    local source_file
    local release_tag

    if [[ -n "${REQUESTED_VERSION}" ]]; then
        validate_version_tag "${REQUESTED_VERSION}" || return 1
        download_script "${destination_file}" "${REQUESTED_VERSION}" || return 1
        EMBEDDED_VERSION="${REQUESTED_VERSION}"
        return 0
    fi

    if source_file="$(resolve_local_source)"; then
        info "Using local source from: ${source_file}"
        cp "${source_file}" "${destination_file}"
        EMBEDDED_VERSION="$(resolve_local_version "${source_file}")"
        return 0
    fi

    release_tag="$(resolve_latest_release_tag)" || return 1
    download_script "${destination_file}" "${release_tag}" || return 1
    EMBEDDED_VERSION="${release_tag}"
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
    info "Installing ${TARGET_NAME} to ${TARGET_PATH}..."

    TEMP_FILE="$(mktemp)" || exit 1

    stage_script "${TEMP_FILE}" || exit 1
    ensure_version_support "${TEMP_FILE}" || exit 1
    embed_version "${TEMP_FILE}" "${EMBEDDED_VERSION}" || exit 1
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
    parse_args "$@"
    install_script
}

main "$@"
