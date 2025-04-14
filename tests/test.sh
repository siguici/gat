#!/usr/bin/env bash

set -e

# 👇 Use local bin/gat script
GAT_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/gat"

if [[ ! -x "$GAT_SCRIPT" ]]; then
  echo "❌ Error: $GAT_SCRIPT not found or not executable"
  exit 1
fi

# 🧪 Create a temporary Git repo
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

git init -q
echo "Temporary test repo created at $TMP_DIR"

# ➕ Initial commit
echo "Initial" > file.txt
git add file.txt
git commit -m "Initial commit" > /dev/null

# Create an additional file for commit tests
echo "Test file" > file2.txt
git add file2.txt
git commit -m "Add file2.txt" > /dev/null

# Create a branch and add a commit for testing merge and cherry-pick
git checkout -b feature-branch
echo "Feature content" > feature.txt
git add feature.txt
git commit -m "Feature commit" > /dev/null

# =======================
# ✅ Valid test cases
# =======================

run_test() {
  echo "➡️  Test: $1"
  shift
  if "$GAT_SCRIPT" "$@"; then
    echo "✅ Passed"
  else
    echo "❌ Failed"
  fi
  echo "-----------------------------"
}

# Commit with yesterday's date
run_test "Commit with yesterday's date" yesterday commit -am "Test commit with yesterday's date"

# Commit with specific date (commit on a specific date, for example March 15th, 2023)
run_test "Commit with specific date" 2023-03-15 commit -am "Test commit on March 15th, 2023"

# Merge with relative date -2d (use a valid commit to merge from a branch)
run_test "Merge with relative date -2d" -2d merge --no-ff -m "Merge test" HEAD

# Cherry-pick with time (use a valid commit hash from the previous commits)
run_test "Cherry-pick with time" 2024-01-01 cherry-pick HEAD --time 10:30

# =======================
# ❌ Invalid date
# =======================
run_test "Invalid date format" invalid-date commit -am "This should fail"

# 🔍 Optional: show Git log
echo
echo "🧾 Git log for inspection:"
git log --pretty=format:"%h %ad %s" --date=iso

echo
echo "🧪 All tests completed."
