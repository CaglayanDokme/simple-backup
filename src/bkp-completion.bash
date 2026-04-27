#!/bin/bash

# ============================================================================
# bkp-completion.bash - Bash completion for bkp
# ============================================================================

_bkp_complete_paths() {
    local current_word="$1"

    mapfile -t COMPREPLY < <(compgen -A file -- "${current_word}")

    if declare -F compopt >/dev/null 2>&1; then
        compopt -o filenames
    fi
}

_bkp_complete_directories() {
    local current_word="$1"

    mapfile -t COMPREPLY < <(compgen -d -- "${current_word}")

    if declare -F compopt >/dev/null 2>&1; then
        compopt -o dirnames
    fi
}

_bkp() {
    local current_word previous_word token
    local short_options long_options compress_modes

    COMPREPLY=()
    current_word="${COMP_WORDS[COMP_CWORD]}"
    previous_word="${COMP_WORDS[COMP_CWORD - 1]:-}"
    short_options='-f -c -s -r -t -m -d -a -e -v -h --'
    long_options='--force --compress --compress=merged --compress=separate --symbolic --recursive --timestamp --move --destination --archive-name --exclude --version --help --'
    compress_modes='merged separate'

    for token in "${COMP_WORDS[@]:1:COMP_CWORD-1}"; do
        if [[ "${token}" == "--" ]]; then
            _bkp_complete_paths "${current_word}"
            return 0
        fi
    done

    case "${previous_word}" in
        -d|--destination)
            _bkp_complete_directories "${current_word}"
            return 0
            ;;
        -a|--archive-name|-e|--exclude)
            _bkp_complete_paths "${current_word}"
            return 0
            ;;
    esac

    if [[ "${current_word}" == --compress=* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${compress_modes}" -- "${current_word#--compress=}")

        local index
        for index in "${!COMPREPLY[@]}"; do
            COMPREPLY[${index}]="--compress=${COMPREPLY[${index}]}"
        done

        return 0
    fi

    if [[ "${current_word}" == --* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${long_options}" -- "${current_word}")
        return 0
    fi

    if [[ "${current_word}" == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${short_options}" -- "${current_word}")
        return 0
    fi

    _bkp_complete_paths "${current_word}"
}

complete -F _bkp bkp