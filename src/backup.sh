#!/bin/bash

# bkp - A simple backup utility
# Moves or copies files/folders to <name>.bkp with optional timestamps and destination.

set -e

# Default values
FORCE=false
FOLLOW_SYMLINKS=false
RECURSIVE=false
TIMESTAMP=false
MOVE=false
DESTINATION=""
PATHS=()

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <path1> [path2] ...

Options:
  -f, --force          Overwrite existing backup files.
  -s, --symbolic       Follow symbolic links. By default, errors if a symlink is encountered.
  -r, --recursive       Allow backing up directories.
  -t, --timestamp       Add a timestamp to the backup name: <name>.<timestamp>.bkp
  -m, --move            Move the resource instead of copying it (default).
  -d, --destination DIR Specify a target directory for backups.
  -h, --help            Show this help message.

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) FORCE=true; shift ;;
        -s|--symbolic) FOLLOW_SYMLINKS=true; shift ;;
        -r|--recursive) RECURSIVE=true; shift ;;
        -t|--timestamp) TIMESTAMP=true; shift ;;
        -m|--move) MOVE=true; shift ;;
        -d|--destination)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: --destination requires an argument." >&2
                exit 1
            fi
            DESTINATION="$2"
            shift 2
            ;;
        -h|--help) show_help; exit 0 ;;
        -rs|-sr) RECURSIVE=true; FOLLOW_SYMLINKS=true; shift ;;
        -rf|-fr) RECURSIVE=true; FORCE=true; shift ;;
        -sf|-fs) FOLLOW_SYMLINKS=true; FORCE=true; shift ;;
        -rm|-mr) RECURSIVE=true; MOVE=true; shift ;;
        -sm|-ms) FOLLOW_SYMLINKS=true; MOVE=true; shift ;;
        -rms|-rsm|-mrs|-msr|-srm|-smr) RECURSIVE=true; MOVE=true; FOLLOW_SYMLINKS=true; shift ;;
        -*) 
            if [[ "$1" =~ ^-[fsrtm]+$ ]]; then
                # Handle any combination of short flags without arguments
                flags="${1#-}"
                for (( i=0; i<${#flags}; i++ )); do
                    case "${flags:$i:1}" in
                        f) FORCE=true ;;
                        s) FOLLOW_SYMLINKS=true ;;
                        r) RECURSIVE=true ;;
                        t) TIMESTAMP=true ;;
                        m) MOVE=true ;;
                    esac
                done
                shift
            else
                echo "Unknown option: $1" >&2; show_help; exit 1
            fi
            ;;
        *) PATHS+=("$1"); shift ;;
    esac
done

if [[ ${#PATHS[@]} -eq 0 ]]; then
    echo "Error: No paths specified." >&2
    show_help
    exit 1
fi

# Ensure destination exists if specified
if [[ -n "$DESTINATION" ]]; then
    mkdir -p "$DESTINATION"
fi

# Function to process a single path
backup_path() {
    local target="$1"
    
    # 1. Validation
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        echo "Error: Target does not exist: $target" >&2
        return 1
    fi

    if [[ -d "$target" && "$RECURSIVE" == "false" ]]; then
        echo "Error: $target is a directory. Use -r or --recursive to backup folders." >&2
        return 1
    fi

    # Check for symlinks if -s is not provided
    if [[ "$FOLLOW_SYMLINKS" == "false" ]]; then
        if [[ -L "$target" ]]; then
            echo "Error: $target is a symbolic link. Use -s or --symbolic to follow." >&2
            return 1
        fi
        if [[ -d "$target" ]]; then
            # Check if any symlinks exist within the directory
            if [[ -n $(find "$target" -type l -print -quit) ]]; then
                echo "Error: Directory $target contains symbolic links. Use -s or --symbolic to follow." >&2
                return 1
            fi
        fi
    fi

    # 2. Determine Backup Name
    local base_name=$(basename "$target")
    local backup_name="$base_name"
    
    if [[ "$TIMESTAMP" == "true" ]]; then
        backup_name="${backup_name}.$(date +%Y%m%d%H%M%S)"
    fi
    backup_name="${backup_name}.bkp"

    local final_dest
    if [[ -n "$DESTINATION" ]]; then
        final_dest="$DESTINATION/$backup_name"
    else
        final_dest="$(dirname "$target")/$backup_name"
    fi

    # 3. Perform Operation
    local cp_cmd=("cp")
    local mv_cmd=("mv")

    if [[ "$FORCE" == "true" ]]; then
        cp_cmd+=("-f")
        mv_cmd+=("-f")
    else
        cp_cmd+=("-n") # Do not overwrite if -f not specified
        mv_cmd+=("-n")
    fi

    if [[ "$RECURSIVE" == "true" ]]; then
        if [[ "$FOLLOW_SYMLINKS" == "true" ]]; then
            cp_cmd+=("-rL")
        else
            cp_cmd+=("-r")
        fi
    fi

    if [[ "$MOVE" == "true" ]]; then
        # If move and follow symlinks, we must copy-then-delete to resolve symlinks
        if [[ "$FOLLOW_SYMLINKS" == "true" ]]; then
            "${cp_cmd[@]}" "$target" "$final_dest"
            rm -rf "$target"
        else
            "${mv_cmd[@]}" "$target" "$final_dest"
        fi
    else
        "${cp_cmd[@]}" "$target" "$final_dest"
    fi

    echo "Backed up: $target -> $final_dest"
}

# Iterate over all paths
for p in "${PATHS[@]}"; do
    backup_path "$p"
done
