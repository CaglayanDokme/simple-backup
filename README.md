# bkp

A simple, robust backup utility for the command line.

## Quick Start

Install the latest stable `bkp` release with a single command:

**Using curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/main/install.sh | bash
```

**Using wget:**
```bash
wget -qO- https://raw.githubusercontent.com/CaglayanDokme/simple-backup/main/install.sh | bash
```

This downloads the pre-built release artifact from GitHub Releases and installs it
via symlink (`bkp -> bkp-v0.2.0`), keeping previous versions for rollback.

Once installed, verify it works:
```bash
bkp --help
bkp --version
```

## Features

- **Copy or Move:** Backup by copying (default) or moving (`-m`).
- **Compression:** Create `.tar.gz` archives with `-c` when you want a single compressed backup artifact.
- **Multiple Targets:** Backup multiple files or directories in one go.
- **Recursive:** Support for backing up folders with `-r`.
- **Pattern Exclusions:** Skip matching files or folders with repeatable `-e` glob patterns.
- **Symlink Awareness:** Safely handle symbolic links. Force resolution with `-s`.
- **Timestamps:** Add unique timestamps to backup filenames with `-t`.
- **Custom Destinations:** Specify a target directory for backups with `-d`.
- **Safety First:** Prevents accidental overwrites unless `-f` is used.
- **Version-Aware Installs:** Release installs print exact tags, while dev checkouts report `git describe` output.

### Why does it exist / Is it beneficial?

`bkp` fills a narrow but genuine gap: a one-command, opinionated "snapshot in place" for files and directories. The alternatives are:

- **Manual `cp file file.bkp`** — no safety checks, no symlink awareness, no timestamps, verbose for multiple targets.
- **Full backup systems** (rsync, borgbackup, restic, duplicity, timeshift) — designed for scheduled/incremental/remote backups; overkill for "save this before I edit it."
- **VCS snapshots** (`git stash`, `git commit`) — only works for tracked files, not arbitrary paths like `/etc/nginx/nginx.conf`.

**Verdict: Yes, it's useful.** The niche is small but real — especially for sysadmins editing config files in etc or developers quickly snapshotting something outside version control.

### What's superior vs. existing solutions?

- **Symlink-safe by default** — refuses to silently break/dereference symlinks without `-s`
- **Safety-first** — won't overwrite existing backups without `-f`; requires explicit `-r` for directories
- **Lean defaults** — regular backups only need bash + coreutils; compression additionally uses `tar` and `gzip` when requested

## Verified on
- Ubuntu (20.04, 22.04, 24.04)
- Debian 12 (bookworm)
- Fedora 42
- Alpine 3.21

---

See [docs](docs) for further details on installation, usage, and more.