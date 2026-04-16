#!/bin/bash

# ============================================================================
# bkp - A simple backup utility
# Copies or moves files and directories to <name>.bkp, with optional
# timestamps, symlink resolution, and destination directory support.
# ============================================================================

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

FORCE=false
FOLLOW_SYMLINKS=false
RECURSIVE=false
TIMESTAMP=false
MOVE=false
DESTINATION=""
PATHS=()

show_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <path1> [path2] ...

Options:
  -f, --force            Overwrite existing backup files or directories.
  -s, --symbolic         Follow symbolic links. By default, errors if a symlink is encountered.
  -r, --recursive        Allow backing up directories.
  -t, --timestamp        Add a timestamp to the backup name: <name>.<timestamp>.bkp
  -m, --move             Move the resource instead of copying.
  -d, --destination DIR  Specify a target directory for backups.
  -h, --help             Show this help message.
EOF
}

error() {
    echo "Error: $*" >&2
}

parse_short_flags() {
    local flags="$1"
    local index flag

    for (( index = 0; index < ${#flags}; index++ )); do
        flag="${flags:index:1}"
        case "${flag}" in
            f) FORCE=true ;;
            s) FOLLOW_SYMLINKS=true ;;
            r) RECURSIVE=true ;;
            t) TIMESTAMP=true ;;
            m) MOVE=true ;;
            *)
                error "Unknown option: -${flag}"
                show_help
                exit 1
                ;;
        esac
    done
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                FORCE=true
                shift
                ;;
            -s|--symbolic)
                FOLLOW_SYMLINKS=true
                shift
                ;;
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -t|--timestamp)
                TIMESTAMP=true
                shift
                ;;
            -m|--move)
                MOVE=true
                shift
                ;;
            -d|--destination)
                if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
                    error "--destination requires an argument."
                    exit 1
                fi
                DESTINATION="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --)
                shift
                PATHS+=("$@")
                break
                ;;
            -?*)
                if [[ "$1" =~ ^-[fsrtm]+$ ]]; then
                    parse_short_flags "${1#-}"
                    shift
                else
                    error "Unknown option: $1"
                    show_help
                    exit 1
                fi
                ;;
            *)
                PATHS+=("$1")
                shift
                ;;
        esac
    done
}

validate_args() {
    if [[ ${#PATHS[@]} -eq 0 ]]; then
        error "No paths specified."
        show_help
        exit 1
    fi

    if [[ -n "${DESTINATION}" ]]; then
        mkdir -p "${DESTINATION}"
        if [[ ! -d "${DESTINATION}" ]]; then
            error "Destination is not a directory: ${DESTINATION}"
            exit 1
        fi
    fi
}

directory_contains_symlink() {
    local target="$1"

    if find "${target}" -type l -print -quit | grep -q .; then
        return 0
    fi

    return 1
}

build_backup_path() {
    local target="$1"
    local base_name backup_name

    base_name="$(basename "${target}")"
    backup_name="${base_name}"

    if [[ "${TIMESTAMP}" == "true" ]]; then
        backup_name="${backup_name}.$(date +%Y%m%d%H%M%S)"
    fi

    backup_name="${backup_name}.bkp"

    if [[ -n "${DESTINATION}" ]]; then
        printf '%s\n' "${DESTINATION}/${backup_name}"
    else
        printf '%s\n' "$(dirname "${target}")/${backup_name}"
    fi
}

prepare_destination() {
    local final_dest="$1"

    if [[ ! -e "${final_dest}" && ! -L "${final_dest}" ]]; then
        return 0
    fi

    if [[ "${FORCE}" != "true" ]]; then
        error "Backup already exists: ${final_dest}. Use -f or --force to overwrite."
        return 1
    fi

    rm -rf -- "${final_dest}"
}

run_backup_operation() {
    local target="$1"
    local final_dest="$2"
    local -a cp_cmd=("cp")
    local -a mv_cmd=("mv")

    if [[ "${RECURSIVE}" == "true" ]]; then
        if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
            cp_cmd+=("-rL")
        else
            cp_cmd+=("-r")
        fi
    fi

    prepare_destination "${final_dest}"

    if [[ "${MOVE}" == "true" ]]; then
        if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
            "${cp_cmd[@]}" "${target}" "${final_dest}"
            rm -rf "${target}"
        else
            "${mv_cmd[@]}" "${target}" "${final_dest}"
        fi
    else
        "${cp_cmd[@]}" "${target}" "${final_dest}"
    fi
}

backup_path() {
    local target="$1"
    local final_dest

    if [[ ! -e "${target}" && ! -L "${target}" ]]; then
        error "Target does not exist: ${target}"
        return 1
    fi

    if [[ -d "${target}" && "${RECURSIVE}" == "false" ]]; then
        error "${target} is a directory. Use -r or --recursive to backup folders."
        return 1
    fi

    if [[ "${FOLLOW_SYMLINKS}" == "false" ]]; then
        if [[ -L "${target}" ]]; then
            error "${target} is a symbolic link. Use -s or --symbolic to follow."
            return 1
        fi

        if [[ -d "${target}" ]] && directory_contains_symlink "${target}"; then
            error "Directory ${target} contains symbolic links. Use -s or --symbolic to follow."
            return 1
        fi
    fi

    final_dest="$(build_backup_path "${target}")"
    run_backup_operation "${target}" "${final_dest}"

    echo "Backed up: ${target} -> ${final_dest}"
}

main() {
    local path

    parse_args "$@"
    validate_args

    for path in "${PATHS[@]}"; do
        backup_path "${path}"
    done
}

main "$@"
