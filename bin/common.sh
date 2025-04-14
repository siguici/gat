#!/bin/bash

# Validate the provided date string.
# Accepts keywords like: now, today, yesterday, tomorrow,
# or relative dates ending with d/w/m (e.g. -1d, +2w) or absolute dates.
function validate_date() {
    local input="$1"
    case "$input" in
        now|today|yesterday|tomorrow|[+-]*[dwm])
            return 0
            ;;
    esac
    if ! date -d "$input" >/dev/null 2>&1; then
        echo "Invalid date format: $input"
        exit 1
    fi
}

# Resolve a date (relative or absolute) with an optional time override.
# Output format: ISO 8601 (YYYY-MM-DDTHH:MM:SS+ZZZZ)
function resolve_git_date() {
    local input="$1"
    local time="$2"
    local datetime

    # Si le format relatif (ex: -1d, +2w, etc.)
    if [[ "$input" =~ ^[+-][0-9]+[dwm]$ ]]; then
        local unit="${input: -1}"
        local number="${input:0:-1}"
        case "$unit" in
            d) datetime=$(date -d "$number days" "+%Y-%m-%dT%T%z") ;;
            w) datetime=$(date -d "$((number * 7)) days" "+%Y-%m-%dT%T%z") ;;
            m) datetime=$(date -d "$number month" "+%Y-%m-%dT%T%z") ;;
        esac
    else
        if [[ -n "$time" ]]; then
            datetime=$(date -d "$input $time" "+%Y-%m-%dT%T%z")
        else
            datetime=$(date -d "$input" "+%Y-%m-%dT%T%z")
        fi
    fi
    echo "$datetime"
}

function extract_time_flag() {
    local args=("$@")
    for ((i = 0; i < ${#args[@]}; i++)); do
        if [[ "${args[i]}" == "--time" ]]; then
            echo "${args[i+1]}"
            return
        fi
    done
    echo ""
}

function strip_time_flag() {
    local skip_next=false
    local result=()
    for arg in "$@"; do
        if $skip_next; then
            skip_next=false
            continue
        fi
        if [[ "$arg" == "--time" ]]; then
            skip_next=true
            continue
        fi
        result+=("$arg")
    done

    for item in "${result[@]}"; do
        printf '%s\n' "$item"
    done
}

function execute_git_command() {
    local date_input="$1"
    shift
    local time
    time=$(extract_time_flag "$@")
    local git_date
    git_date=$(resolve_git_date "$date_input" "$time")
    mapfile -t args < <(strip_time_flag "$@")
    GIT_AUTHOR_DATE="$git_date" GIT_COMMITTER_DATE="$git_date" git "${args[@]}"
}
