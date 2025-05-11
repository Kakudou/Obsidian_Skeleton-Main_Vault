# Obsidian Vault Setup

This document explains the two helper scripts included in this skeleton vault:

1. **`create_vault.sh`**  
   Bootstraps a brand-new Obsidian vault (main + personal + workspace) from predefined skeleton repositories, initializes Git, and pushes to GitHub.

2. **`secure_vault.sh`**  
   Enables transparent AES-256-CBC encryption of all `.md` files via Git’s clean/smudge filters (using PBKDF2 with 100 000 iterations). Your notes stay plaintext locally, but only encrypted blobs ever land on GitHub.

---

## Prerequisites

- **Git**  
- **OpenSSL** (≥ 1.1)  
- A **shared passphrase** that you’ll enter once per clone to unlock encryption.

---

## 1. `create_vault.sh`

### Purpose

- Clone three skeleton repos (main, personal, workspace)  
- Initialize each as a fresh Git repo  
- Commit & push to GitHub under your account  
- Add the personal & workspace vaults as submodules into the main vault  

### Usage

```sh
sh create_vault.sh <vault_name> <github_user>
```

* **`<vault_name>`** — name of your new vault (e.g. `MyNotes`)
* **`<github_user>`** — your GitHub username

The script will prompt you before pushing each repository to GitHub. After it completes, you’ll have:

```
MyNotes/                     ← main vault
└── 100-Personal/            ← personal-vault submodule
└── 600-Workspace/           ← workspace-vault submodule
```

---

## 2. `secure_vault.sh`

### Purpose

* Prompt once for your vault passphrase
* Configure Git filter drivers (`clean` & `smudge`) to:

  * **Encrypt** any changed/new `*.md` with AES-256-CBC + PBKDF2 (100 000 iterations, no salt) on `git add`/`push`
  * **Decrypt** them back on `git checkout`/`pull`
* Commit the needed `.gitattributes` entry so submodules and the main vault all use the same filter

### Usage

```sh
# Inside your vault or submodule folder:
sh /path/to/secure_vault.sh
```

Or, to target another path:

```sh
sh /path/to/secure_vault.sh /abs/path/to/repo
```

1. You’ll be prompted:

   ```
   Enter vault passphrase:
   ```
2. The script writes the filter into `.git/config` and ensures:

   * `.gitattributes` contains:

     ```
     *.md filter=vault
     ```
   * Your commit history and GitHub only see AES-encrypted blobs.
3. Future `git status` will only show files you actually edit.

---

## How It Works

1. **Skeleton cloning**
   `create_vault.sh` pulls from your predefined GitHub skeletons, resets history, and pushes under your account.

2. **Git submodules**
   Personal & workspace vaults become subdirectories tracked as submodules for separation of concerns.

3. **Transparent encryption**
   `secure_vault.sh` sets up:

   ```ini
   [filter "vault"]
     clean  = openssl enc -aes-256-cbc -md sha256 -pbkdf2 -iter 100000 -nosalt -pass pass:<your-passphrase>
     smudge = openssl enc -d -aes-256-cbc -md sha256 -pbkdf2 -iter 100000 -nosalt -pass pass:<your-passphrase>
     required = true
   ```

   * **`-nosalt`** ensures deterministic ciphertext so Git only re-encrypts changed files.
   * **PBKDF2 + 100 000 iterations** avoids deprecated KDF warnings while keeping your passphrase private.

---

## Sharing & Contribution

Feel free to:

* **Adapt** filter settings (cipher, iterations)
* **Extend** `create_vault.sh` for additional submodules or hooks
* **Share** improvements back to the Obsidian community!

