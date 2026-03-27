# Bash MV Auto Backup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0+-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![GitHub Stars](https://img.shields.io/github/stars/setuju/bash-mv-auto-backup?style=social)](https://github.com/setuju/bash-mv-auto-backup/stargazers)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-ff69b4)](https://github.com/sponsors/setuju)

**A smart wrapper for `mv` that automatically creates numbered backups when overwriting files inside your home directory.**

No more accidental data loss! This script enhances the standard `mv` command by detecting name collisions and preserving old files with `.001.bak`, `.002.bak`, etc. It works only where you need it – inside `$HOME` – and respects Python virtual environments.

## ✨ Features

- **Automatic Backup** – When moving a file into a directory that already contains a file with the same name, the existing file is renamed to `filename.ext.001.bak` (or the next available number).
- **Safe by Default** – Only active inside `$HOME`. Outside home, the original `mv` behavior is used (no backups, no surprises).
- **Virtual Environment Aware** – Automatically disables backup when moving files inside an active Python virtual environment (`$VIRTUAL_ENV`).
- **Preserves All `mv` Options** – Supports `-i` (interactive), `-f` (force), `-n` (no clobber), `-v` (verbose), `--` (end of options), and any other standard options.
- **Only Regular Files** – Directories, symlinks, and special files are moved untouched.
- **Clean Numbering** – Backups use three‑digit zero‑padded numbers (001, 002, …) for easy sorting.

## 📦 Installation

### Prerequisites

- Bash 4.0+ (any modern Linux, macOS, or WSL)
- Git (optional, for cloning)

### Option 1: Clone the Repository

```bash
git clone https://github.com/setuju/bash-mv-auto-backup.git
cd bash-mv-auto-backup
```

### Option 2: Download the Script Directly

```bash
curl -O https://raw.githubusercontent.com/setuju/bash-mv-auto-backup/main/mv-auto-backup.sh
```

Activate the Wrapper
Add the following line to your `~/.bashrc` or `~/.bash_profile`:`

```bash
source /path/to/mv-auto-backup.sh
```

Replace `/path/to/` with the actual location of the script (e.g., `~/bash-mv-auto-backup/mv-auto-backup.sh`).

Then reload your shell:

```bash
source ~/.bashrc
```

or open a new terminal.

## 🚀 Usage

Once installed, the mv command works exactly as usual, with the added backup logic.

### Basic Example

Create a directory and a file:

```bash
mkdir ~/archive
echo "First version" > ~/archive/doc.txt
```

Move a new file with the same name:

```bash
echo "Second version" > doc.txt
mv doc.txt ~/archive/
```

Now ~/archive contains

```bash
doc.txt          (the new file)
doc.txt.001.bak  (the old file)
```

### Multiple Backups

```bash
echo "Third version" > doc.txt
mv doc.txt ~/archive/          # Old doc.txt becomes doc.txt.002.bak
```

### Handling Different Extensions

#### For file.py

```bash
mv file.py ~/simpan/           # Existing file.py becomes file.py.001.bak
```

#### For files without extension

```bash
mv README ~/simpan/            # Existing README becomes README.001.bak
```

### Using Standard mv Options

#### Verbose mode

```bash
mv -v file.txt ~/destination/
```

#### Interactive (prompt before overwrite)

```bash
mv -i important.txt ~/backup/
```

#### Force (overwrite without backup - but backup will still happen if allowed)

```bash
mv -f data.log ~/logs/
```

Where the Backup Does NOT Activate
Outside `$HOME:` e.g., `sudo mv /etc/config /etc/config.bak` → no backup (original mv behavior)

Inside a Python virtual environment (when VIRTUAL_ENV is set): e.g., while `source myenv/bin/activate is active`, moves inside `myenv/`are not backed up.

When the destination is a file (not a directory) or when the source is not a regular file.

## ⚙️ Customization

You can easily add or modify exclusion rules by editing the `_is_in_venv` function or adding more conditions inside the `allow_backup` check.

For example, to also exclude a specific folder:

```bash
if [[ "$target_dir_abs" == "/path/to/exclude"* ]]; then
    allow_backup=false
fi
```

## ❓ Why Not Just Use mv -b?

The standard mv -b creates a backup with a tilde suffix (e.g., `file~`), but it does not support numbered backups for multiple collisions. This wrapper gives you clean, numbered backups and integrates seamlessly with your daily workflow.

## 📝 License

This project is licensed under the MIT License – see the LICENSE file for details.

## 👤 Author

Jack MainHack BrotherHood  

GitHub: [@setuju](https://github.com/setuju)

Telegram: [passwords.t.me](https://t.me/passwords.t.me)

## 🙏 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the issues page.

## ⚠️ Disclaimer

This script overrides the default `mv` command. While it is designed to be safe, always keep backups of critical files. The author is not responsible for any data loss. Use at your own risk.
