#!/bin/bash

# Test: Commit with yesterday's date
gat yesterday commit -am "Test commit with yesterday's date"

# Test: Commit with specific date
gat 2023-03-15 commit -am "Test commit on March 15th, 2023"

# Test: Merge with relative date
gat -2d merge feature-branch

# Test: Cherry-pick with specific time
gat 2024-01-01 cherry-pick abc123 --time 10:30

# Test: Invalid date format
gat invalid-date commit -am "This should fail"
