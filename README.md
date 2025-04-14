# 🕰️ gat

> **Timetravel through your Git history**
> Backdate your commits, merges, tags, cherry-picks and more —
safely, consistently, and with style.

---

## ✨ Overview

🧭 `gat` is a flexible and extensible toolkit
for applying custom dates to Git-native operations.

With full support for relative/absolute/human-friendly dates, seamless Git integration,
and a clear modular structure, it lets you:

- 🕳️ Write history like a time traveler
- 🧽 Clean up messy timelines
- 📆 Simulate workflows for testing, demos, and storytelling

---

## ⚡ Installation

### One-liner via `curl`

```bash
curl -s https://raw.githubusercontent.com/siguici/gat/main/install.sh | sh
```

> Installs `gat` into `~/.local/bin` (or globally if run with `sudo`).

### Manual Installation

```bash
git clone https://github.com/siguici/gat.git
cd gat
./install.sh
```

---

## 🧠 Philosophy

`gat` wraps your existing Git commands while allowing you to:

- Specify the **date** in flexible formats
- Use **natural aliases** (like `yesterday`, `last week`, `-2d`, `+1d`)
- Apply dates to commits, merges, tags, cherry-picks, and more
- Keep **your current time** (or override it)

No history rewriting. No rebase shenanigans. Just scoped, intentional backdating.

---

## 📦 Command Syntax

```bash
gat <date> <git-subcommand> [options]
```

### Example Usages

```bash
# Commit with yesterday's date and current time
gat yesterday commit -am "Fix for Monday"

# Commit from 3 days ago
gat -3d commit -m "Old feature work"

# Merge a branch with custom date
gat 2024-03-21 merge feature-branch

# Tag with relative date
gat -1d tag v1.0.1 -m "Hotfix release"

# Cherry-pick a commit with date override
gat -2d cherry-pick abc123
```

---

## 🗓️ Date Syntax

| Format        | Meaning                            | Examples                |
|---------------|------------------------------------|-------------------------|
| `-1d`, `+3d`  | Relative day offset                | `-2d` (2 days ago)      |
| `0`           | Today                              | `gat 0 commit ...`      |
| `yesterday`   | Shortcut for `-1d`                 | `gat yesterday ...`     |
| `tomorrow`    | Shortcut for `+1d`                 | `gat tomorrow ...`      |
| `YYYY-MM-DD`  | Absolute date                      | `gat 2023-12-31 ...`    |
| `now`         | Use current date & time            | `gat now ...`           |
| `--time`      | Time override (HH:MM[:SS])         | `--time 14:30`          |

### 🧠 Defaults

- If no `--time` is passed: uses current time
- All Git commands supported: `commit`, `merge`, `tag`, `cherry-pick`, etc.
- Aliases auto-recognized: `-1`, `-1d`, `yesterday` are equivalent

---

## ✅ Supported Git Commands

| Command        | Description                            |
|----------------|----------------------------------------|
| `commit`       | Date-aware commit                      |
| `merge`        | Merge with custom date                 |
| `tag`          | Annotated tag with date                |
| `cherry-pick`  | Cherry-pick commit with new date       |
| `revert`       | Revert commit with specified date      |

---

## 🛠️ Core Options

| Option          | Description                           |
|------------------|----------------------------------------|
| `--time`         | Set a custom time (e.g., `--time 08:30`) |
| `--debug`        | Show resolved date/time                |
| `--dry-run`      | Print command but don’t execute         |
| `--no-color`     | Disable colored output (CI-friendly)   |

---

## 📂 Project Structure

```tree
gat/
├── bin/
│   ├── gat         # Git CLI interface
│   └── common.sh   # Shared shell logic
├── install.sh      # One-liner installer
├── tests/          # Integration tests
├── README.md       # This file
└── LICENSE         # MIT License
```

---

## 📚 Examples

### Commit with absolute date

```bash
gat 2023-12-25 commit -am "🎄 Christmas commit"
```

### Tag with `yesterday` alias

```bash
gat yesterday tag v1.2.3 -m "Hotfix pushed"
```

### Merge with exact time

```bash
gat 2024-03-01 merge feature --no-ff --time 10:45
```

### Preview command without running

```bash
gat -2d commit -am "Check this" --dry-run
```

---

## 🔒 License

[MIT License](./LICENSE.md) - Open source and free to use.  
Crafted with care by [@siguici](https://github.com/siguici)

---

## 👥 Contributing

- ⭐ Star the repo
- 🐛 Report bugs
- 💡 Suggest features
- 🙌 PRs welcome!

---

> "History is written by the victors. Git history is written by you." — `gat`
