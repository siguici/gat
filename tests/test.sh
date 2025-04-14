#!/usr/bin/env bash

set -e

GAT_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/gat"
if [[ ! -x "$GAT_SCRIPT" ]]; then
  echo "❌ Error: $GAT_SCRIPT not found or not executable"
  exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

git init -q
echo "Temporary test repo created at $TMP_DIR"

echo "Initial content" > file.txt
git add file.txt
git commit -m "Initial commit" > /dev/null

echo "More content" > file2.txt
git add file2.txt
git commit -m "Add file2.txt" > /dev/null

git checkout -b feature-branch
echo "Feature change" >> feature.txt
git add feature.txt
git commit -m "Feature commit" > /dev/null
FEATURE_COMMIT=$(git rev-parse HEAD)
git checkout main

run_test() {
  echo "➡️  Test: $1"
  shift
  if [[ "$1" == "commit" ]]; then
    echo "Modifying file.txt" >> file.txt
    git add file.txt
  fi
  if "$GAT_SCRIPT" "$@"; then
    echo "✅ Passed"
  else
    echo "❌ Failed"
  fi
  echo "-----------------------------"
}

run_test "Commit with yesterday's date" yesterday commit -am "Test commit with yesterday's date"

run_test "Commit with specific date" 2023-03-15 commit -am "Test commit on March 15th, 2023"

run_test "Merge with relative date -2d" -2d merge --no-ff -m "Merge test" feature-branch

run_test "Cherry-pick with time" 2024-01-01 cherry-pick "$FEATURE_COMMIT" --time 10:30

run_test "Invalid date format" invalid-date commit -am "This should fail"

echo
echo "🧾 Git log for inspection:"
git log --pretty=format:"%h %ad %s" --date=iso

echo
echo "🧪 All tests completed."
