#!/bin/bash
# One-step: log in to GitHub (if needed), create GitSummarizer repo, and push.

set -e
cd "$(dirname "$0")"

echo "→ Checking GitHub login..."
if ! gh auth status &>/dev/null; then
  echo "  Please complete login in the browser (one-time)."
  gh auth login --web --git-protocol https
fi

echo "→ Creating GitHub repo 'GitSummarizer' and pushing..."
USER=$(gh api user -q .login)
git remote set-url origin "https://github.com/${USER}/GitSummarizer.git" 2>/dev/null || true
gh repo create GitSummarizer --public --source=. --remote=origin --push --description "Safari extension – summarise and chat about GitHub repos with Apple Intelligence"

echo ""
echo "✓ Done. Your repo is live at: https://github.com/${USER}/GitSummarizer"
