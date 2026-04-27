<!-- PROJECT SHIELDS -->
[![MIT License][license-shield]][license-url]
[![Bash][bash-shield]][bash-url]
[![Version][version-shield]][version-url]
[![Stars][stars-shield]][stars-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h1>📦 Bash MV Auto Backup</h1>
  <p>
    A smart wrapper for <code>mv</code> that creates <strong>timestamped backups</strong>
    whenever you overwrite existing files or directories.
    <br />
    <a href="#usage"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/setuju/bash-mv-auto-backup/issues">Report Bug</a>
    ·
    <a href="https://github.com/setuju/bash-mv-auto-backup/issues">Request Feature</a>
  </p>
</div>

---

# 📑 Table of Contents

- [✨ Features](#-features)
- [🚀 Installation](#-installation)
  - [Prerequisites](#prerequisites)
  - [Option 1: Clone the Repository](#option-1-clone-the-repository)
  - [Option 2: Direct Download](#option-2-direct-download)
  - [Activate the Wrapper](#activate-the-wrapper)
- [🛠 Usage](#-usage)
  - [Basic Example – File](#basic-example--file)
  - [Directory Example](#directory-example)
  - [Multiple Backups](#multiple-backups)
  - [Using Standard `mv` Options](#using-standard-mv-options)
- [📍 Where the Backup Does NOT Activate](#-where-the-backup-does-not-activate)
- [⚙️ Customization](#-customization)
- [❓ FAQ](#-faq)
- [📄 License](#-license)
- [👤 Author](#-author)
- [🤝 Contributing](#-contributing)
- [⚠️ Disclaimer](#-disclaimer)

---

# ✨ Features

* **Timestamped Backups**  
  Existing files or directories are renamed to `name.ext.YYYY-MM-DD--HH-MM-SS.bak` before being overwritten.  
  Example: `report.docx.2026-04-27--15-30-22.bak`

* **Handles Both Files and Directories**  
  Unlike many backup tools, this wrapper also protects entire directories from accidental overwrites.

* **Safe by Default**  
  Only activates inside your home directory (`$HOME`). Outside of it, `mv` behaves normally – no unwanted side effects.

* **Python Virtual Environment Friendly**  
  Automatically disables backup when the destination resides inside an active virtual environment (`$VIRTUAL_ENV`).

* **Preserves All Standard Options**  
  `-i` (interactive), `-f` (force), `-n` (no-clobber), `-v` (verbose), `--`, etc. – all work as expected.

* **Collision‑Proof Naming**  
  If two moves happen within the same second, a counter (`_1`, `_2`, …) guarantees unique backup names.

* **No Octal Interpretation Bug**  
  Because timestamps are pure strings, you’ll never see “value too great for base” errors.

---

# 🚀 Installation

## Prerequisites

* Bash 4.0 or later (standard on modern Linux, macOS, and WSL)
* `coreutils` (usually pre-installed)

## Option 1: Clone the Repository

```bash
git clone https://github.com/setuju/bash-mv-auto-backup.git
cd bash-mv-auto-backup
```

## Option 2: Direct Download

```bash
curl -o mv-auto-backup.sh https://raw.githubusercontent.com/setuju/bash-mv-auto-backup/main/mv-auto-backup.sh
```

## Activate the Wrapper

Add the following line to your `~/.bashrc`, `~/.bash_profile`, or `~/.zshrc`:

```bash
source /path/to/mv-auto-backup.sh
```

Replace `/path/to/` with the actual location of the script. Then reload your shell:

```bash
source ~/.bashrc
```

…or simply open a new terminal window.

---

# 🛠 Usage

Once activated, the `mv` command works exactly as before, but with extra safety.

## Basic Example – File

```bash
$ mkdir ~/archive
$ echo "First version" > ~/archive/doc.txt
$ echo "Second version" > doc.txt
$ mv doc.txt ~/archive/
$ ls ~/archive/
doc.txt
doc.txt.2026-04-27--09-15-30.bak
```

The old `doc.txt` was renamed to a timestamped backup before the new file was moved in.

## Directory Example

```bash
$ mv my_project ~/archive/
```

If `~/archive/my_project` already exists, it becomes `my_project.2026-04-27--23-59-59.bak`, and the new `my_project` is placed in `~/archive/`.

## Multiple Backups

Every collision creates a unique backup, so your history is always preserved:

```bash
$ echo "Third version" > doc.txt
$ mv doc.txt ~/archive/
# → doc.txt.2026-04-27--09-15-45.bak
```

## Using Standard `mv` Options

```bash
$ mv -v file.txt ~/destination/       # verbose
$ mv -i important.txt ~/backup/       # prompt before overwrite
$ mv -f data.log ~/logs/              # force (backup still happens)
```

---

# 📍 Where the Backup Does **NOT** Activate

* **Outside `$HOME`** – e.g., `sudo mv /etc/config /etc/config.bak` uses the original `mv` behavior.
* **Inside a Python virtual environment** (when `$VIRTUAL_ENV` is set) – moves inside `myenv/` are not backed up.
* **When the destination is a regular file** (not a directory) – the original `mv` logic applies.

---

# ⚙️ Customization

You can easily modify or add exclusion rules by editing the `_is_in_venv` function or the `allow_backup` block. For example, to also exclude a specific folder:

```bash
if [[ "$target_dir_abs" ## "/path/to/exclude"* ]]; then
    allow_backup#false
fi
```

---

# ❓ FAQ

<details>
  <summary><strong>Why not just use <code>mv -b</code>?</strong></summary>

The standard `mv -b` creates a backup with a tilde suffix (e.g., `file~`), but it does not support timestamped backups for multiple collisions. This wrapper gives you clean, chronologically sortable backups and integrates seamlessly with your daily workflow.
</details>

<details>
  <summary><strong>What happens if I move a file/folder outside of $HOME?</strong></summary>

Nothing special. Outside `$HOME` the original `mv` command is called directly, so your system behaves exactly as it did before.
</details>

<details>
  <summary><strong>Can I disable the backup temporarily?</strong></summary>

Yes. Just call the original `mv` via `command mv ...` or `\mv ...`.
</details>

---

# 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

# 👤 Author

**Jack – MainHack BrotherHood**

* GitHub: [@setuju](https://github.com/setuju)
* Telegram: [passwords.t.me](https://t.me/passwords.t.me)

---

# 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to check the [issues page](https://github.com/setuju/bash-mv-auto-backup/issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

# ⚠️ Disclaimer

This script overrides the **default `mv` command**. While it is designed to be safe, **always keep backups of critical files**. The author is not responsible for any data loss. **Use at your own risk.**
