# Installation

## One-Liner Installation (Recommended)

Install the latest release with a single command:

**Using curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash
```

**Using wget:**
```bash
wget -qO- https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash
```

**What the one-liner does:**
- Downloads the installer from the repository
- Fetches the pre-built `bkp` binary from the latest GitHub Release
- Installs via symlink: `/usr/local/bin/bkp -> bkp-v0.2.0`
- Installs bash completion to `/usr/share/bash-completion/completions/bkp` when `bash-completion` is available
- Previous versions are kept alongside new ones for rollback
- Uses `sudo` automatically if needed

## Install a Specific Release Tag

Use `--version` to install an exact tagged release:

```bash
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash -s -- --version v0.2.0
```

## Direct Download (No Installer)

Download the pre-built binary directly from GitHub Releases:

```bash
curl -fsSL https://github.com/CaglayanDokme/simple-backup/releases/latest/download/bkp | sudo install /dev/stdin /usr/local/bin/bkp
```

This skips the symlink versioning but is useful for minimal environments.
It also skips automatic bash-completion installation.

## Developer: Clone and Install

For development or code review, use the developer installer:

```bash
git clone https://github.com/CaglayanDokme/simple-backup.git
cd simple-backup
bash scripts/dev-install.sh
```

This will:
- Use the local `src/backup.sh` from your checkout
- Embed the version from `git describe --tags --dirty --always`
- Install via symlink, same as the release installer
- Install bash completion when `/usr/share/bash-completion/completions` exists

## Symlink Versioning

Both installers use symlink-based versioning:

```
/usr/local/bin/bkp          -> bkp-v0.2.0   (symlink, current)
/usr/local/bin/bkp-v0.2.0                    (binary)
/usr/local/bin/bkp-v0.1.0                    (previous, kept)
```

Upgrading installs the new version alongside the old one and updates the symlink.
To roll back, manually re-point the symlink:

```bash
sudo ln -sf bkp-v0.1.0 /usr/local/bin/bkp
```

## Bash Completion

Both installers try to install Bash completion to:

```text
/usr/share/bash-completion/completions/bkp
```

If that directory does not exist, the installer skips completion setup and still installs `bkp` normally.

On Debian and Ubuntu, install the package first if you want completion support:

```bash
sudo apt install bash-completion
```

After installation, start a new shell or source the completion file manually:

```bash
source /usr/share/bash-completion/completions/bkp
```

## Verification

After installation, verify `bkp` is working:

```bash
which bkp          # Should show: /usr/local/bin/bkp
bkp --help         # Should display help message
bkp --version      # Should display the installed release or local checkout version
ls -l $(which bkp) # Should show symlink target
complete -p bkp    # Should show the registered bash completion function
```