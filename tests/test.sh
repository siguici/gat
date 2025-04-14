#!/usr/bin/env bash

set -e

# Path to gat (assumes it's in PATH or in repo root/bin)
GAT=${GAT:-gat}

# Create a temporary directory and clean it up on exit
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

# Init a fresh Git repo
git init -q
echo "Temporary test repo created at $TMP_DIR"

# Create initial file
echo "Initial" > file.txt
git add file.txt
git commit -m "Initial commit"

function run_test() {
  echo "➡️  Test: $1"
  shift
  if "$GAT" "$@"; then
    echo "✅ Passed"
  else
    echo "❌ Failed"
  fi
  echo "-----------------------------"
}

# =======================
# Valid test cases
# =======================

run_test "Commit with yesterday's date" yesterday commit -am "Test commit with yesterday's date"
run_test "Commit with specific date" 2023-03-15 commit -am "Test commit on March 15th, 2023"
run_test "Merge with relative date -2d" -2d merge --no-ff -m "Merge test" HEAD
run_test "Cherry-pick with time" 2024-01-01 cherry-pick HEAD --time 10:30

# =======================
# Invalid date
# =======================

run_test "Invalid date format" invalid-date commit -am "This should fail"

# Optional: Show git log for verification
echo
echo "🧾 Git log for inspection:"
git log --pretty=format:"%h %ad %s" --date=iso

echo
echo "🧪 All tests completed."
