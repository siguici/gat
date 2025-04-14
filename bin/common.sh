#!/bin/bash

function validate_date() {
    local input="$1"
    local resolved

    # Support some shortcuts
    case "$input" in
        now) resolved=$(date) ;;
        yesterday) resolved=$(date --date="yesterday") ;;
        tomorrow) resolved=$(date --date="tomorrow") ;;
        -*|+*) resolved=$(date --date="$input") ;; # relative like -1d, +2h
        *)
            # Try absolute date
            resolved=$(date --date="$input" 2>/dev/null)
            if [[ $? -ne 0 ]]; then
                echo "Invalid date format: $input"
                exit 1
            fi
            ;;
    esac

    # Save the resolved date
    export RESOLVED_DATE="$resolved"
}

function apply_git_date_env() {
    local time="$1"

    local final_date="$RESOLVED_DATE"

    # Inject time if given
    if [[ -n "$time" ]]; then
        final_date="$(date --date="$RESOLVED_DATE $time")"
    fi

    export GIT_AUTHOR_DATE="$final_date"
    export GIT_COMMITTER_DATE="$final_date"
}

function extract_time_flag() {
    local time=""
    local args=()
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --time)
                shift
                time="$1"
                ;;
            *)
                args+=("$1")
                ;;
        esac
        shift
    done

    # Restore positional args
    set -- "${args[@]}"
    echo "$time"
}
