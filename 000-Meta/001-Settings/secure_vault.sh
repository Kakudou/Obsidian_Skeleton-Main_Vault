#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   # in your vault (or submodule) directory:
#   sh /path/to/secure_vault.sh [<path-to-git-repo>]

# 1) Locate target repo (dir or submodule)
if [ $# -eq 0 ]; then
  REPO_DIR="$(pwd)"
elif [ $# -eq 1 ]; then
  REPO_DIR="$(cd "$1" && pwd)"
else
  echo "Usage: $0 [<path-to-git-repo>]" >&2
  exit 1
fi

if [[ ! -e "$REPO_DIR/.git" ]]; then
  echo "ERROR: $REPO_DIR is not a Git repo" >&2
  exit 1
fi

# 2) Prompt for your vault passphrase
read -rsp "Enter vault passphrase: " PASSPHRASE
echo

# 3) Check if filter was already configured
existing_filter="$(git -C "$REPO_DIR" config --get filter.vault.clean || true)"

# 4) Write/overwrite the filter driver using PBKDF2 + 100k iters + no salt
git -C "$REPO_DIR" config filter.vault.clean  \
  "openssl enc -aes-256-cbc -md sha256 -pbkdf2 -iter 100000 -nosalt -pass pass:$PASSPHRASE"
git -C "$REPO_DIR" config filter.vault.smudge \
  "openssl enc -d -aes-256-cbc -md sha256 -pbkdf2 -iter 100000 -nosalt -pass pass:$PASSPHRASE"
git -C "$REPO_DIR" config filter.vault.required true

# 5) Ensure *.md is filtered in .gitattributes
ATTR="$REPO_DIR/.gitattributes"
touch "$ATTR"
if ! grep -qxF "*.md filter=vault" "$ATTR"; then
  echo "*.md filter=vault" >> "$ATTR"
  git -C "$REPO_DIR" add .gitattributes
  gitattributes_changed=true
else
  gitattributes_changed=false
fi

# 6) Commit if we added the .gitattributes line
if [ "$gitattributes_changed" = true ]; then
  git -C "$REPO_DIR" commit -m "🔒 enable vault encryption in attrs"
fi

# 7) Print the right message
if [ -z "$existing_filter" ]; then
  echo "🔒 Vault encryption has now been configured in $REPO_DIR"
else
  echo "🔒 Vault encryption was already configured in $REPO_DIR"
fi


