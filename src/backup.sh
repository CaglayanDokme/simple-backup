#!/bin/bash

# ============================================================================
# bkp - A simple backup utility
# Copies or moves files and directories to <name>.bkp, with optional
# timestamps, symlink resolution, and destination directory support.
# ============================================================================

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
readonly VERSION="@@VERSION@@"
readonly VERSION_PLACEHOLDER="@""@VERSION@""@"

INVOCATION_TIMESTAMP="$(date +%Y%m%d%H%M%S)"
readonly INVOCATION_TIMESTAMP

TAR_BIN="${BKP_TAR_BIN:-tar}"
readonly TAR_BIN
GZIP_BIN="${BKP_GZIP_BIN:-gzip}"
readonly GZIP_BIN

FORCE=false
COMPRESS_MODE=""
FOLLOW_SYMLINKS=false
RECURSIVE=false
TIMESTAMP=false
MOVE=false
DESTINATION=""
ARCHIVE_NAME=""
PATHS=()
EXCLUDE_PATTERNS=()
EXCLUDE_MATCH_COUNTS=()
TEMP_DIRS=()
FILTERED_ENTRIES=()
FILTERED_SOURCE_PATHS=()
FILTERED_ROOT_EXCLUDED=false
FILTERED_TOTAL_CHILDREN=0
FILTERED_INCLUDED_CHILDREN=0

cleanup_temp_dirs() {
    local temp_dir

    for temp_dir in "${TEMP_DIRS[@]}"; do
        if [[ -n "${temp_dir}" && -d "${temp_dir}" ]]; then
            rm -rf -- "${temp_dir}"
        fi
    done
}

create_temp_dir() {
    local temp_dir

    temp_dir="$(mktemp -d)"
    TEMP_DIRS+=("${temp_dir}")
    printf '%s\n' "${temp_dir}"
}

trap cleanup_temp_dirs EXIT

show_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <path1> [path2] ...

Options:
  -f, --force            Overwrite existing backup files or directories.
  -c, --compress[=MODE]  Create a compressed tar.gz backup.
  -s, --symbolic         Follow symbolic links. By default, errors if a symlink is encountered.
  -r, --recursive        Allow backing up directories.
  -t, --timestamp        Add a timestamp to the backup name: <name>.<timestamp>.bkp
  -m, --move             Move the resource instead of copying.
  -d, --destination DIR  Specify a target directory for backups.
  -a, --archive-name     Set merged archive name. Required for merged compression with multiple targets.
  -e, --exclude PATTERN  Exclude matching files or folders using glob patterns.
  -v, --version          Show version information.
  -h, --help             Show this help message.

Compression modes (--compress[=MODE]):
  merged                 Store targets in a single archive (default).
  separate               Create one archive per target.
EOF
}

error() {
    echo "Error: $*" >&2
}

resolve_git_version() {
    local script_dir

    if ! command -v git >/dev/null 2>&1; then
        return 1
    fi

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    git -C "${script_dir}" describe --tags --dirty --always 2>/dev/null
}

show_version() {
    local resolved_version="${VERSION}"

    if [[ "${resolved_version}" == "${VERSION_PLACEHOLDER}" ]]; then
        if ! resolved_version="$(resolve_git_version)"; then
            resolved_version="dev"
        fi
    fi

    printf '%s\n' "${resolved_version}"
}

set_compress_mode() {
    local mode="$1"

    case "${mode}" in
        merged|separate)
            COMPRESS_MODE="${mode}"
            ;;
        *)
            error "Invalid compress mode: ${mode}. Use 'merged' or 'separate'."
            exit 1
            ;;
    esac
}

parse_short_flags() {
    local flags="$1"
    local index flag

    for (( index = 0; index < ${#flags}; index++ )); do
        flag="${flags:index:1}"
        case "${flag}" in
            c) COMPRESS_MODE="merged" ;;
            f) FORCE=true ;;
            s) FOLLOW_SYMLINKS=true ;;
            r) RECURSIVE=true ;;
            t) TIMESTAMP=true ;;
            m) MOVE=true ;;
            v)
                show_version
                exit 0
                ;;
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
            -c|--compress)
                COMPRESS_MODE="merged"
                shift
                ;;
            --compress=*)
                set_compress_mode "${1#--compress=}"
                shift
                ;;
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
            -a|--archive-name)
                if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
                    error "$1 requires a name."
                    exit 1
                fi
                ARCHIVE_NAME="$2"
                shift 2
                ;;
            -e|--exclude)
                if [[ $# -lt 2 || -z "$2" ]]; then
                    error "$1 requires a pattern."
                    exit 1
                fi
                EXCLUDE_PATTERNS+=("$2")
                EXCLUDE_MATCH_COUNTS+=(0)
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --)
                shift
                PATHS+=("$@")
                break
                ;;
            -?*)
                if [[ "$1" =~ ^-[cfsrtmv]+$ ]]; then
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

validate_compress_dependencies() {
    if ! command -v "${TAR_BIN}" >/dev/null 2>&1 || ! command -v "${GZIP_BIN}" >/dev/null 2>&1; then
        error "Compression requires 'tar' and 'gzip' to be installed."
        exit 1
    fi
}

validate_exclude_dependencies() {
    if ! command -v "${TAR_BIN}" >/dev/null 2>&1; then
        error "Exclude filtering requires 'tar' to be installed."
        exit 1
    fi
}

show_exclude_warnings() {
    local index

    for index in "${!EXCLUDE_MATCH_COUNTS[@]}"; do
        if (( EXCLUDE_MATCH_COUNTS[index] == 0 )); then
            printf 'Warning: exclude pattern matched nothing: %s\n' "${EXCLUDE_PATTERNS[index]}" >&2
        fi
    done
}

validate_args() {
    if [[ ${#PATHS[@]} -eq 0 ]]; then
        error "No paths specified."
        show_help
        exit 1
    fi

    if [[ -n "${ARCHIVE_NAME}" && -z "${COMPRESS_MODE}" ]]; then
        error "--archive-name requires merged compression."
        exit 1
    fi

    if [[ -n "${ARCHIVE_NAME}" && "${COMPRESS_MODE}" != "merged" ]]; then
        error "--archive-name can only be used with merged compression."
        exit 1
    fi

    if [[ "${COMPRESS_MODE}" == "merged" && ${#PATHS[@]} -gt 1 && -z "${ARCHIVE_NAME}" ]]; then
        error "Merged compression with multiple targets requires -a or --archive-name."
        exit 1
    fi

    if [[ -n "${COMPRESS_MODE}" ]]; then
        validate_compress_dependencies
    fi

    if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
        validate_exclude_dependencies
    fi

    if [[ -n "${DESTINATION}" ]]; then
        mkdir -p "${DESTINATION}"
        if [[ ! -d "${DESTINATION}" ]]; then
            error "Destination is not a directory: ${DESTINATION}"
            exit 1
        fi
    fi
}

pattern_matches() {
    local value="$1"
    local pattern="$2"

    # shellcheck disable=SC2254
    case "${value}" in
        ${pattern})
            return 0
            ;;
    esac

    return 1
}

is_backup_artifact() {
    local path="$1"
    local base_name

    base_name="$(basename -- "${path}")"

    case "${base_name}" in
        *.bkp|*.bkp.tar.gz)
            return 0
            ;;
    esac

    return 1
}

filter_backup_artifacts() {
    local path
    local -a filtered_paths=()

    for path in "${PATHS[@]}"; do
        if is_backup_artifact "${path}"; then
            printf 'Warning: omitting backup file: %s\n' "${path}" >&2
            continue
        fi

        filtered_paths+=("${path}")
    done

    if [[ ${#filtered_paths[@]} -eq 0 ]]; then
        error "All specified paths are backup files."
        exit 1
    fi

    PATHS=("${filtered_paths[@]}")
}

entry_matches_exclude() {
    local target_name="$1"
    local relative_path="$2"
    local entry_name="$3"
    local archive_path="${target_name}"
    local matched=false
    local index pattern

    if [[ -n "${relative_path}" ]]; then
        archive_path="${target_name}/${relative_path}"
    fi

    for index in "${!EXCLUDE_PATTERNS[@]}"; do
        pattern="${EXCLUDE_PATTERNS[index]}"

        if pattern_matches "${entry_name}" "${pattern}" || pattern_matches "${archive_path}" "${pattern}"; then
            EXCLUDE_MATCH_COUNTS[index]=$(( EXCLUDE_MATCH_COUNTS[index] + 1 ))
            matched=true
            continue
        fi

        if [[ -n "${relative_path}" ]] && pattern_matches "${relative_path}" "${pattern}"; then
            EXCLUDE_MATCH_COUNTS[index]=$(( EXCLUDE_MATCH_COUNTS[index] + 1 ))
            matched=true
        fi
    done

    [[ "${matched}" == "true" ]]
}

add_filtered_entry() {
    local archive_path="$1"
    local source_path="$2"

    FILTERED_ENTRIES+=("${archive_path}")
    FILTERED_SOURCE_PATHS+=("${source_path}")
}

scan_directory_entries() {
    local current_path="$1"
    local target_name="$2"
    local relative_base="$3"
    local child child_name child_relative_path
    local restore_dotglob=false
    local restore_nullglob=false

    if ! shopt -q dotglob; then
        shopt -s dotglob
        restore_dotglob=true
    fi

    if ! shopt -q nullglob; then
        shopt -s nullglob
        restore_nullglob=true
    fi

    for child in "${current_path}"/*; do
        child_name="$(basename "${child}")"

        if [[ -n "${relative_base}" ]]; then
            child_relative_path="${relative_base}/${child_name}"
        else
            child_relative_path="${child_name}"
        fi

        FILTERED_TOTAL_CHILDREN=$(( FILTERED_TOTAL_CHILDREN + 1 ))

        if entry_matches_exclude "${target_name}" "${child_relative_path}" "${child_name}"; then
            continue
        fi

        add_filtered_entry "${target_name}/${child_relative_path}" "${child}"
        FILTERED_INCLUDED_CHILDREN=$(( FILTERED_INCLUDED_CHILDREN + 1 ))

        if [[ -d "${child}" ]]; then
            scan_directory_entries "${child}" "${target_name}" "${child_relative_path}"
        fi
    done

    if [[ "${restore_nullglob}" == "true" ]]; then
        shopt -u nullglob
    fi

    if [[ "${restore_dotglob}" == "true" ]]; then
        shopt -u dotglob
    fi
}

build_filtered_entries() {
    local target="$1"
    local target_name

    FILTERED_ENTRIES=()
    FILTERED_SOURCE_PATHS=()
    FILTERED_ROOT_EXCLUDED=false
    FILTERED_TOTAL_CHILDREN=0
    FILTERED_INCLUDED_CHILDREN=0

    target_name="$(basename "${target}")"

    if entry_matches_exclude "${target_name}" "" "${target_name}"; then
        FILTERED_ROOT_EXCLUDED=true
        return 0
    fi

    add_filtered_entry "${target_name}" "${target}"

    if [[ -d "${target}" ]]; then
        scan_directory_entries "${target}" "${target_name}" ""
    fi
}

create_filtered_backup_stage() {
    local target="$1"
    local stage_dir="$2"
    local target_dir
    local -a tar_cmd=("${TAR_BIN}" "-cf" "-" "--no-recursion")

    target_dir="$(dirname "${target}")"

    if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
        tar_cmd+=("--dereference")
    fi

    tar_cmd+=("-C" "${target_dir}" "--")
    tar_cmd+=("${FILTERED_ENTRIES[@]}")

    "${tar_cmd[@]}" | "${TAR_BIN}" -xf - -C "${stage_dir}"
}

write_filtered_archive() {
    local target="$1"
    local final_dest="$2"
    local target_dir
    local -a tar_cmd=("${TAR_BIN}" "-czf" "${final_dest}" "--no-recursion")

    target_dir="$(dirname "${target}")"

    if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
        tar_cmd+=("--dereference")
    fi

    tar_cmd+=("-C" "${target_dir}" "--")
    tar_cmd+=("${FILTERED_ENTRIES[@]}")
    "${tar_cmd[@]}"
}

remove_filtered_source_entries() {
    local target="$1"
    local source_paths_name="${2:-FILTERED_SOURCE_PATHS}"
    local -n source_paths="${source_paths_name}"
    local index path

    if [[ ! -d "${target}" || -L "${target}" ]]; then
        rm -rf -- "${target}"
        return 0
    fi

    for (( index = ${#source_paths[@]} - 1; index >= 1; index-- )); do
        path="${source_paths[index]}"

        if [[ -d "${path}" && ! -L "${path}" ]]; then
            rmdir --ignore-fail-on-non-empty -- "${path}" 2>/dev/null || true
        else
            rm -rf -- "${path}"
        fi
    done

    rmdir --ignore-fail-on-non-empty -- "${target}" 2>/dev/null || true
}

run_filtered_backup_operation() {
    local target="$1"
    local final_dest="$2"
    local target_name
    local stage_dir
    local staged_path

    target_name="$(basename "${target}")"

    if [[ -n "${COMPRESS_MODE}" ]]; then
        prepare_destination "${final_dest}"
        write_filtered_archive "${target}" "${final_dest}"
    else
        stage_dir="$(create_temp_dir)"
        create_filtered_backup_stage "${target}" "${stage_dir}"
        staged_path="${stage_dir}/${target_name}"

        prepare_destination "${final_dest}"
        mv -- "${staged_path}" "${final_dest}"
    fi

    if [[ "${MOVE}" == "true" ]]; then
        remove_filtered_source_entries "${target}"
    fi
}

directory_contains_symlink() {
    local target="$1"

    if find "${target}" -type l -print -quit | grep -q .; then
        return 0
    fi

    return 1
}

validate_backup_target() {
    local target="$1"

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
}

validate_filtered_target() {
    local target="$1"

    build_filtered_entries "${target}"

    if [[ "${FILTERED_ROOT_EXCLUDED}" == "true" ]]; then
        error "Target ${target} is excluded by the provided patterns."
        return 1
    fi

    if [[ -d "${target}" && ${FILTERED_TOTAL_CHILDREN} -gt 0 && ${FILTERED_INCLUDED_CHILDREN} -eq 0 ]]; then
        error "All entries under ${target} are excluded."
        return 1
    fi
}

build_backup_path() {
    local target="$1"
    local base_name backup_name

    base_name="$(basename "${target}")"
    backup_name="${base_name}"

    if [[ "${TIMESTAMP}" == "true" ]]; then
        backup_name="${backup_name}.${INVOCATION_TIMESTAMP}"
    fi

    backup_name="${backup_name}.bkp"

    if [[ -n "${COMPRESS_MODE}" ]]; then
        backup_name="${backup_name}.tar.gz"
    fi

    if [[ -n "${DESTINATION}" ]]; then
        printf '%s\n' "${DESTINATION}/${backup_name}"
    else
        printf '%s\n' "$(dirname "${target}")/${backup_name}"
    fi
}

build_merged_backup_path() {
    local archive_name="${ARCHIVE_NAME}"

    if [[ -z "${archive_name}" ]]; then
        archive_name="$(basename "${PATHS[0]}")"
    fi

    if [[ "${TIMESTAMP}" == "true" ]]; then
        archive_name="${archive_name}.${INVOCATION_TIMESTAMP}"
    fi

    archive_name="${archive_name}.bkp.tar.gz"

    if [[ -n "${DESTINATION}" ]]; then
        printf '%s\n' "${DESTINATION}/${archive_name}"
    else
        local target
        local target_dir
        local common_dir=""

        for target in "${PATHS[@]}"; do
            target_dir="$(cd "$(dirname "${target}")" && pwd)"

            if [[ -z "${common_dir}" ]]; then
                common_dir="${target_dir}"
                continue
            fi

            if [[ "${target_dir}" != "${common_dir}" ]]; then
                error "Merged compression targets are in different directories. Use -d or --destination to specify the output location."
                return 1
            fi
        done

        printf '%s\n' "${common_dir}/${archive_name}"
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

backup_merged() {
    local final_dest
    local target
    local target_dir
    local target_name
    local move_state_dir=""
    local list_file
    local index
    local -a tar_cmd
    local -a move_targets=()
    local -a move_lists=()

    for target in "${PATHS[@]}"; do
        validate_backup_target "${target}" || return 1
    done

    final_dest="$(build_merged_backup_path)" || return 1
    tar_cmd=("${TAR_BIN}" "-czf" "${final_dest}")

    if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
        tar_cmd+=("--dereference")
    fi

    if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
        tar_cmd+=("--no-recursion")

        if [[ "${MOVE}" == "true" ]]; then
            move_state_dir="$(create_temp_dir)"
        fi

        for index in "${!PATHS[@]}"; do
            target="${PATHS[index]}"
            validate_filtered_target "${target}" || return 1

            target_dir="$(cd "$(dirname "${target}")" && pwd)"
            tar_cmd+=("-C" "${target_dir}")
            tar_cmd+=("${FILTERED_ENTRIES[@]}")

            if [[ "${MOVE}" == "true" ]]; then
                list_file="${move_state_dir}/${index}.paths"
                printf '%s\n' "${FILTERED_SOURCE_PATHS[@]}" > "${list_file}"
                move_targets+=("${target}")
                move_lists+=("${list_file}")
            fi
        done
    else
        for target in "${PATHS[@]}"; do
            target_dir="$(cd "$(dirname "${target}")" && pwd)"
            target_name="$(basename "${target}")"
            tar_cmd+=("-C" "${target_dir}" "${target_name}")
        done
    fi

    prepare_destination "${final_dest}"
    "${tar_cmd[@]}"

    if [[ "${MOVE}" == "true" ]]; then
        if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
            for index in "${!move_targets[@]}"; do
                local -a merged_source_paths=()
                # shellcheck disable=SC2034
                mapfile -t merged_source_paths < "${move_lists[index]}"
                remove_filtered_source_entries "${move_targets[index]}" merged_source_paths
            done
        else
            for target in "${PATHS[@]}"; do
                rm -rf -- "${target}"
            done
        fi
    fi

    echo "Backed up ${#PATHS[@]} target(s) -> ${final_dest}"
}

run_backup_operation() {
    local target="$1"
    local final_dest="$2"
    local target_dir target_name
    local -a cp_cmd=("cp")
    local -a mv_cmd=("mv")
    local -a tar_cmd=("${TAR_BIN}" "-czf" "${final_dest}")

    if [[ "${RECURSIVE}" == "true" ]]; then
        if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
            cp_cmd+=("-rL")
        else
            cp_cmd+=("-r")
        fi
    fi

    prepare_destination "${final_dest}"

    if [[ -n "${COMPRESS_MODE}" ]]; then
        target_dir="$(dirname "${target}")"
        target_name="$(basename "${target}")"

        if [[ "${FOLLOW_SYMLINKS}" == "true" ]]; then
            tar_cmd+=("--dereference")
        fi

        tar_cmd+=("-C" "${target_dir}" "${target_name}")
        "${tar_cmd[@]}"

        if [[ "${MOVE}" == "true" ]]; then
            rm -rf -- "${target}"
        fi

        return 0
    fi

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

    validate_backup_target "${target}" || return 1

    final_dest="$(build_backup_path "${target}")"

    if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
        validate_filtered_target "${target}" || return 1

        run_filtered_backup_operation "${target}" "${final_dest}"
    else
        run_backup_operation "${target}" "${final_dest}"
    fi

    echo "Backed up: ${target} -> ${final_dest}"
}

main() {
    local path

    parse_args "$@"
    validate_args
    filter_backup_artifacts

    if [[ "${COMPRESS_MODE}" == "merged" && ( ${#PATHS[@]} -gt 1 || -n "${ARCHIVE_NAME}" ) ]]; then
        backup_merged
        show_exclude_warnings
        return 0
    fi

    for path in "${PATHS[@]}"; do
        backup_path "${path}"
    done

    show_exclude_warnings
}

main "$@"
