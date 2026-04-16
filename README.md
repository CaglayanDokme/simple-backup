# bkp

A simple, robust backup utility for the command line.

## Quick Start

Install `bkp` with a single command:

**Using curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash
```

**Using wget:**
```bash
wget -qO- https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash
```

Once installed, verify it works:
```bash
bkp --help
```

## Features

- **Copy or Move:** Backup by copying (default) or moving (`-m`).
- **Multiple Targets:** Backup multiple files or directories in one go.
- **Recursive:** Support for backing up folders with `-r`.
- **Symlink Awareness:** Safely handle symbolic links. Force resolution with `-s`.
- **Timestamps:** Add unique timestamps to backup filenames with `-t`.
- **Custom Destinations:** Specify a target directory for backups with `-d`.
- **Safety First:** Prevents accidental overwrites unless `-f` is used.

### Why does it exist / Is it beneficial?

`bkp` fills a narrow but genuine gap: a one-command, opinionated "snapshot in place" for files and directories. The alternatives are:

- **Manual `cp file file.bkp`** — no safety checks, no symlink awareness, no timestamps, verbose for multiple targets.
- **Full backup systems** (rsync, borgbackup, restic, duplicity, timeshift) — designed for scheduled/incremental/remote backups; overkill for "save this before I edit it."
- **VCS snapshots** (`git stash`, `git commit`) — only works for tracked files, not arbitrary paths like `/etc/nginx/nginx.conf`.

**Verdict: Yes, it's useful.** The niche is small but real — especially for sysadmins editing config files in etc or developers quickly snapshotting something outside version control.

### What's superior vs. existing solutions?

- **Symlink-safe by default** — refuses to silently break/dereference symlinks without `-s`
- **Safety-first** — won't overwrite existing backups without `-f`; requires explicit `-r` for directories
- **Composable flags** — combined short flags (`-mrt`), timestamp naming, custom destination
- **Zero dependencies** — pure bash + coreutils, runs anywhere

## Usage

```bash
bkp [OPTIONS] <path1> [path2] ...
```

### Options

- `-f, --force`: Overwrite existing backup files or directories.
- `-s, --symbolic`: Follow symbolic links. By default, errors if a symlink is encountered.
- `-r, --recursive`: Allow backing up directories.
- `-t, --timestamp`: Add a timestamp to the backup name: `<name>.<timestamp>.bkp`.
- `-m, --move`: Move the resource instead of copying it.
- `-d, --destination DIR`: Specify a target directory for backups.
- `-h, --help`: Show this help message.

## Installation

### One-Liner Installation (Recommended)

The quickest way to install `bkp` is using the one-liner above in [Quick Start](#quick-start). This downloads the installer script from GitHub and pipes it directly to bash.

**What the one-liner does:**
- Downloads `install.sh` from GitHub
- Pipes it to bash for execution
- The script fetches `src/backup.sh` from GitHub
- Installs `bkp` to `/usr/local/bin/` (requires `sudo` or running as root)
- Makes the command available system-wide

### Alternative: Clone and Install

If you prefer to review the code first or want to keep the repository locally:

```bash
git clone https://github.com/CaglayanDokme/simple-backup.git
cd simple-backup
./install.sh
```

This will:
- Use the local `src/backup.sh` file if available
- Install to `/usr/local/bin/bkp`
- Use `sudo` automatically if needed

### Alternative: Manual Installation

For specific setups or troubleshooting:

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/src/backup.sh -o bkp

# Make it executable
chmod +x bkp

# Install to system path
sudo mv bkp /usr/local/bin/
```

### Verification

After installation, verify `bkp` is working:

```bash
which bkp          # Should show: /usr/local/bin/bkp
bkp --help         # Should display help message
```

## Examples

1. **Basic Backup:**
   ```bash
   bkp file.txt # Creates file.txt.bkp
   ```

2. **Move and Timestamp:**
   ```bash
   bkp -mt file.txt # Moves file.txt to file.txt.20231024.bkp
   ```

3. **Recursive Folder Backup:**
   ```bash
   bkp -r my_folder # Creates my_folder.bkp
   ```

4. **Follow Symlinks:**
   ```bash
   bkp -s my_link # Backs up the actual file my_link points to.
   ```
