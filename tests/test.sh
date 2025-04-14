#!/usr/bin/env bash

set -euo pipefail

# Path to the gat script
GAT_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/gat"
if [[ ! -x "$GAT_SCRIPT" ]]; then
  echo "❌ Error: $GAT_SCRIPT not found or not executable"
  exit 1
fi

# Create temporary Git repo
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

# Initialize Git repository and make initial commits
git init -q
echo "Initial content" > file.txt
git add file.txt
git commit -m "Initial commit" > /dev/null

echo "More content" > file2.txt
git add file2.txt
git commit -m "Add file2.txt" > /dev/null

# Create a feature branch and commit some changes
git checkout -b feature-branch
echo "Feature change" > feature.txt
git add feature.txt
git commit -m "Feature commit" > /dev/null
FEATURE_COMMIT=$(git rev-parse HEAD)

# Create a second commit for cherry-pick testing
echo "Another feature" > extra.txt
git add extra.txt
git commit -m "Extra feature commit" > /dev/null
SECOND_FEATURE_COMMIT=$(git rev-parse HEAD)

# Create a third empty commit (content already exists)
touch file.txt
git commit --allow-empty -m "Empty commit" > /dev/null
EMPTY_COMMIT=$(git rev-parse HEAD)

git checkout main

# Utility to optionally modify a file if needed (for commits)
prepare_commit_if_needed() {
  local args=("$@")
  for arg in "${args[@]}"; do
    if [[ "$arg" == "commit" ]]; then
      echo "Test change at $(date)" >> file.txt
      git add file.txt
      break
    fi
  done
}

reset_repo_state() {
  git reset --hard -q
  git clean -fdq
  git checkout main -q
}

run_test() {
  local description="$1"
  shift
  local args=("$@")

  reset_repo_state
  echo "➡️  Test: $description"
  prepare_commit_if_needed "${args[@]}"

  if "$GAT_SCRIPT" "${args[@]}"; then
    echo "✅ Passed"
  else
    echo "❌ Failed"
  fi
  echo "-----------------------------"
}

run_test_expect_failure() {
  local description="$1"
  shift
  local args=("$@")

  reset_repo_state
  echo "➡️  Test (expect failure): $description"

  if "$GAT_SCRIPT" "${args[@]}"; then
    echo "❌ Unexpected success"
  else
    echo "✅ Correctly failed"
  fi
  echo "-----------------------------"
}

# 🧪 Run the tests
run_test "Commit with yesterday's date" yesterday commit -am "Commit with yesterday's date"
run_test "Commit with specific date" 2023-03-15 commit -am "Commit on March 15th, 2023"
run_test "Cherry-pick with time" 2024-01-01 cherry-pick "$SECOND_FEATURE_COMMIT" --time 10:30
run_test "Cherry-pick allow-empty (should succeed)" 2024-02-01 cherry-pick "$EMPTY_COMMIT" --allow-empty
run_test "Merge with relative date -2d" -2d merge --no-ff -m "Merge test" feature-branch
run_test_expect_failure "Invalid date format" invalid-date commit -am "This should fail"

# 📜 Output Git log
echo
echo "🧾 Git log for inspection:"
git log --pretty=format:"%h %ad %s" --date=iso

echo
echo "🧪 All tests completed."
