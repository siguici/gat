#!/bin/bash

# Validate the provided date string
function validate_date() {
    local input="$1"

    case "$input" in
        now|today|yesterday|tomorrow|[+-]*[dwm]) return 0 ;;
    esac

    if ! date -d "$input" >/dev/null 2>&1; then
        echo "Invalid date format: $input"
        exit 1
    fi
}

# Resolve date string to proper GIT_COMMITTER_DATE format
function resolve_git_date() {
    local input="$1"
    local time="$2"

    local datetime

    if [[ "$input" =~ ^[+-][0-9]+[dwm]$ ]]; then
        # Convert relative date
        local unit="${input: -1}"
        local number="${input:0:-1}"
        case "$unit" in
            d) datetime=$(date -d "$number days" "+%a %b %e %T %Y %z") ;;
            w) datetime=$(date -d "$((number * 7)) days" "+%a %b %e %T %Y %z") ;;
            m) datetime=$(date -d "$number month" "+%a %b %e %T %Y %z") ;;
        esac
    else
        # Absolute date or supported keyword
        if [[ -n "$time" ]]; then
            datetime=$(date -d "$input $time" "+%a %b %e %T %Y %z")
        else
            datetime=$(date -d "$input" "+%a %b %e %T %Y %z")
        fi
    fi

    echo "$datetime"
}

# Extract the --time value if passed
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

# Remove --time and its value from arguments
function strip_time_flag() {
    local args=("$@")
    local result=()
    local skip_next=false
    for arg in "${args[@]}"; do
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
    echo "${result[@]}"
}

# Execute the actual Git command with proper environment
function execute_git_command() {
    local date="$1"
    shift

    local time=$(extract_time_flag "$@")
    local git_date=$(resolve_git_date "$date" "$time")
    local args=($(strip_time_flag "$@"))

    # Run Git command with overridden author/committer dates
    GIT_AUTHOR_DATE="$git_date" GIT_COMMITTER_DATE="$git_date" git "${args[@]}"
}
