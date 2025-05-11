#!/usr/bin/env bash
set -euo pipefail

VAULT_NAME=$1
GITHUB_USER=$2

if [[ -z "$VAULT_NAME" || -z "$GITHUB_USER" ]]; then
  echo "Usage: $0 <vault_name> <github_user>" >&2
  exit 1
fi

# Helper: clone skeleton, init repo, commit, push
bootstrap_repo() {
  local SRC_URL=$1 DEST_DIR=$2 COMMIT_MSG=$3

  echo "Cloning $SRC_URL into $DEST_DIR"
  git clone "$SRC_URL" "$DEST_DIR"
  cd "$DEST_DIR"

  echo "Removing old git history"
  rm -rf .git

  echo "Initializing new git repository"
  git init

  # Mark markdown for encryption
  echo "*.md filter=vault" >> .gitattributes
  git add .gitattributes

  echo "Adding all files"
  git add .
  git commit -m ":tada: $COMMIT_MSG"

  echo "Configuring remote origin"
  git remote add origin git@github.com:$GITHUB_USER/$DEST_DIR.git

  read -p "Press Enter to push $DEST_DIR to GitHub (please ensure the repo exist on github)" </dev/tty
  git push -u origin main

  echo "$DEST_DIR created successfully"
  cd ..
}

# Main vault
echo "==> Creating main vault: $VAULT_NAME"
bootstrap_repo \
  "git@github.com:Kakudou/Obsidian_Skeleton-Main_Vault.git" \
  "$VAULT_NAME" \
  "Initial commit of $VAULT_NAME"

# Personal submodule
echo "==> Creating personal vault: $VAULT_NAME-personal"
bootstrap_repo \
  "git@github.com:Kakudou/Obsidian_Skeleton-Personal_Vault.git" \
  "$VAULT_NAME-personal" \
  "Initial commit of $VAULT_NAME-personal"

echo "Adding personal as submodule to main"
cd "$VAULT_NAME"
git submodule add git@github.com:$GITHUB_USER/$VAULT_NAME-personal.git 100-Personal
git add .
git commit -m ":tada: Added $VAULT_NAME-personal as submodule"
read -p "Press Enter to push submodule addition" </dev/tty
git push
cd ..

# Workspace submodule
echo "==> Creating workspace vault: $VAULT_NAME-workspace"
bootstrap_repo \
  "git@github.com:Kakudou/Obsidian_Skeleton-Workspace_Vault.git" \
  "$VAULT_NAME-workspace" \
  "Initial commit of $VAULT_NAME-workspace"

echo "Adding workspace as submodule to main"
cd "$VAULT_NAME"
git submodule add git@github.com:$GITHUB_USER/$VAULT_NAME-workspace.git 600-Workspace
git add .
git commit -m ":tada: Added $VAULT_NAME-workspace as submodule"
read -p "Press Enter to push submodule addition" </dev/tty
git push
cd ..

echo "Vault creation complete."
echo "# To secure repositories, run secure_repo.sh on each created directory"

