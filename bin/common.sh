#!/bin/bash

# Helper function to convert relative date to absolute date
# Handles days offsets like -1d, +3d, etc.
get_date_from_offset() {
  local offset=$1
  # If offset is 'yesterday', convert to -1d
  if [ "$offset" == "yesterday" ]; then
    offset="-1d"
  fi
  # Use 'date' to compute the desired date
  date --date="$offset" "+%Y-%m-%d %H:%M:%S"
}

# Function to verify date format
validate_date() {
  local date="$1"
  # Regex to validate formats like 2023-12-25, +1d, -2d, etc.
  if [[ ! "$date" =~ ^(202[0-9]-[0-1][0-9]-[0-3][0-9]|[+-]?[0-9]+[dD]|yesterday|tomorrow)$ ]]; then
    echo "Invalid date format: $date"
    exit 1
  fi
}

# Function to parse and execute the Git command with custom date
execute_git_command() {
  local date="$1"
  shift
  # Get the absolute date using the offset
  resolved_date=$(get_date_from_offset "$date")

  # Apply the date to the GIT_COMMITTER_DATE and GIT_AUTHOR_DATE environment variables
  GIT_COMMITTER_DATE="$resolved_date" GIT_AUTHOR_DATE="$resolved_date" git "$@"
}
