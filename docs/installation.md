# Installation

## One-Liner Installation (Recommended)

The quickest way to install `bkp` is using the one-liner above in [Quick Start](#quick-start). This downloads the installer script from GitHub and pipes it directly to bash.

**What the one-liner does:**
- Downloads `install.sh` from GitHub
- Pipes it to bash for execution
- The script resolves the latest published GitHub Release and fetches that tagged `src/backup.sh`
- Embeds the release tag into the installed script so `bkp --version` reports the installed release
- Installs `bkp` to `/usr/local/bin/` (requires `sudo` or running as root)
- Makes the command available system-wide

If no GitHub Release exists yet, the installer fails with a clear error instead of falling back to `master`.

## Install a Specific Release Tag

Use `--version` to install an exact tagged release:

```bash
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash -s -- --version v0.0.2
```

```bash
wget -qO- https://raw.githubusercontent.com/CaglayanDokme/simple-backup/master/install.sh | bash -s -- --version v0.0.2
```

This installs the requested tag and embeds that exact version string into the installed binary.

## Alternative: Clone and Install

If you prefer to review the code first or want to keep the repository locally:

```bash
git clone https://github.com/CaglayanDokme/simple-backup.git
cd simple-backup
./install.sh
```

This will:
- Use the local `src/backup.sh` file if available
- Embed the local checkout version from `git describe --tags --dirty --always`
- Install to `/usr/local/bin/bkp`
- Use `sudo` automatically if needed

## Alternative: Manual Installation

For specific setups or troubleshooting:

```bash
# Download a specific release tag
curl -fsSL https://raw.githubusercontent.com/CaglayanDokme/simple-backup/v0.0.2/src/backup.sh -o bkp

# Make it executable
chmod +x bkp

# Install to system path
sudo mv bkp /usr/local/bin/
```

Manual installs do not embed release metadata. If you want `bkp --version` to report an installed release reliably, use `install.sh` instead.

## Verification

After installation, verify `bkp` is working:

```bash
which bkp          # Should show: /usr/local/bin/bkp
bkp --help         # Should display help message
bkp --version      # Should display the installed release or local checkout version
```