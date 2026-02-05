#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="${1:-ajmarquez/MergeDeck}"
TMP_DIR="$(mktemp -d)"
WIKI_URL="git@github.com:${REPO_SLUG}.wiki.git"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Cloning wiki: $WIKI_URL"
if ! git clone "$WIKI_URL" "$TMP_DIR"; then
  echo "Failed to clone wiki repo. Ensure Wiki is enabled and initialized on GitHub."
  exit 1
fi

cp docs/wiki/*.md "$TMP_DIR"/

cd "$TMP_DIR"
if [[ -n "$(git status --porcelain)" ]]; then
  git add *.md
  git commit -m "Update wiki documentation"
  git push origin HEAD
  echo "Wiki published for ${REPO_SLUG}."
else
  echo "No wiki changes to publish."
fi
