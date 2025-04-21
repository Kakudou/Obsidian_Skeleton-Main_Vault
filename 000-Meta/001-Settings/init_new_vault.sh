
VAULT_NAME=$1
GITHUB_USER=$2

if [ -z "$VAULT_NAME" ]; then
  echo "Usage: $0 <vault_name>"
  exit 1
fi

if [ -z "$GITHUB_USER" ]; then
  echo "Usage: $0 <vault_name> <github_user>"
  exit 1
fi

## Base Vault ##
echo "Creating new vault: $VAULT_NAME"
echo "Pulling based skeleton vault from GitHub: git@github.com:Kakudou/Obsidian_Skeleton-Main_Vault.git"
git clone git@github.com:Kakudou/Obsidian_Skeleton-Main_Vault.git $VAULT_NAME
cd $VAULT_NAME
echo "Removing old git history"
rm -rf .git
echo "Initializing new git repository"
git init
echo "Adding all files to the new repository"
git add .
echo "Committing all files"
git commit -m ":tada: Initial commit of $VAULT_NAME"
echo "Configuring remote repository"
git remote add origin git@github.com:$2/$VAULT_NAME.git

echo "Create private repository on GitHub: $VAULT_NAME"
read -p "Press Enter to continue" </dev/tty
echo "Pushing to remote repository"
git push -u origin main
echo "Base vault created successfully"

cd ..

## Personal Vault ##

echo "Create Personal vault from skeleton personal vault"
echo "Pulling personal skeleton vault from Github git@github.com:Kakudou/Obsidian_Skeleton-Personal_Vault.git"
git clone git@github.com:Kakudou/Obsidian_Skeleton-Personal_Vault.git $VAULT_NAME-personal
cd $VAULT_NAME-personal
echo "Removing old git history"
rm -rf .git
echo "Initializing new git repository"
git init
echo "Adding all files to the new repository"
git add .
echo "Committing all files"
git commit -m ":tada: Initial commit of $VAULT_NAME-personal"
echo "Configuring remote repository"
git remote add origin git@github.com:$2/$VAULT_NAME-personal.git

echo "Create private repository on GitHub: $VAULT_NAME-personal"
read -p "Press Enter to continue" </dev/tty
echo "Pushing to remote repository"
git push -u origin main

echo "Personal vault created successfully"

echo "Adding it as submodule to the main vault"
cd ../$VAULT_NAME
git submodule add git@github.com:$2/$VAULT_NAME-personal.git 100-Personal
echo "Committing the submodule addition"
git add .
git commit -m ":tada: Added $VAULT_NAME-personal as submodule"

echo "Pushing the submodule addition"
read -p "Press Enter to continue" </dev/tty
echo "Pushing to remote repository"
git push -u origin main

echo "Submodule added successfully, removing the repository folder of the personal vault"
cd ..
rm -rf $VAULT_NAME-personal
echo "Done, main vault with personal vault as submodule created successfully"

## Workspace Vault ##

echo "Create Workspace vault from skeleton workspace vault"
echo "Pulling Workspace skeleton vault from Github git@github.com:Kakudou/Obsidian_Skeleton-Workspace_Vault.git"
git clone git@github.com:Kakudou/Obsidian_Skeleton-Workspace_Vault.git $VAULT_NAME-workspace
cd $VAULT_NAME-workspace
echo "Removing old git history"
rm -rf .git
echo "Initializing new git repository"
git init
echo "Adding all files to the new repository"
git add .
echo "Committing all files"
git commit -m ":tada: Initial commit of $VAULT_NAME-workspace"
echo "Configuring remote repository"
git remote add origin git@github.com:$2/$VAULT_NAME-workspace.git

echo "Create private repository on GitHub: $VAULT_NAME-workspace"
read -p "Press Enter to continue" </dev/tty
echo "Pushing to remote repository"
git push -u origin main

echo "Workspace vault created successfully"

echo "Adding it as submodule to the main vault"
cd ../$VAULT_NAME
git submodule add git@github.com:$2/$VAULT_NAME-workspace.git 600-Workspace
echo "Committing the submodule addition"
git add .
git commit -m ":tada: Added $VAULT_NAME-workspace as submodule"

echo "Pushing the submodule addition"
read -p "Press Enter to continue" </dev/tty
echo "Pushing to remote repository"
git push -u origin main

echo "Submodule added successfully, removing the repository folder of the workspace vault"
cd ..
rm -rf $VAULT_NAME-workspace
echo "Done, main vault with workspace vault as submodule created successfully"

## Finalize ##
