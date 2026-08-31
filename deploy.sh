#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

WORKTREE=".gh-pages-worktree"

hugo --minify

if [ ! -d "$WORKTREE" ]; then
  if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
    git fetch origin gh-pages
    git worktree add "$WORKTREE" gh-pages
  else
    git worktree add -B gh-pages "$WORKTREE"
    git -C "$WORKTREE" rm -rf --quiet . || true
  fi
fi

rsync -a --delete --exclude .git public/ "$WORKTREE"/

cd "$WORKTREE"
git add -A
if git diff --cached --quiet; then
  echo "Nothing changed, skipping deploy."
else
  git commit -q -m "Deploy $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push origin gh-pages
  echo "Deployed."
fi
