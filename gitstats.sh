#!/bin/bash
# Show commit statistics for a git repo

repo="${1:-.}"
days="${2:-14}"

if ! git -C "$repo" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: '$repo' is not a git repository"
    exit 1
fi 

if ! git -C "$repo" rev-parse HEAD > /dev/null 2>&1; then 
    echo "This repo has no commits yet"
    exit 1
fi 

if ! [[ "$days" =~ ^[0-9]+$ ]] || [ "$days" -lt 1 ]; then
    echo "Error: days must be a positive number"
    exit 1
fi

name=$(basename "$(git -C "$repo" rev-parse --show-toplevel)")
total=$(git -C "$repo" rev-list --count HEAD)
first=$(git -C "$repo" log --reverse --format=%ad --date=short | head -1)
last=$(git -C "$repo" log -1  --format=%ad --date=short)

echo "===== Commit Stats: $name ====="
echo "Total commits: $total"
echo "First commit: $first"
echo "Latest commit: $last"

echo
echo "Commits per author:"
git -C "$repo" shortlog -sn HEAD | head -5

echo
echo "Commits per day (last $days days):"
git -C "$repo" log --since="$days days ago" --format=%ad --date=short \
    | sort | uniq -c \
    | while read -r count day; do 
        bar=$(printf '%*s' "$count" '' | tr ' ' '#')
        printf "%s %s %s\n" "$day" "$bar" "$count"
     done 