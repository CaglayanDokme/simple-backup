# Improvement Roadmap

## Feature Enhancements
- Add `--dry-run` flag to backup.sh — show what would be backed up without actual action
- ~~Install with symbolic link so that updates can be done without needing to overwrite the existing file~~ — Done: both installers use `bkp -> bkp-v0.2.0` symlinks.
- ~~Releases shall not include the whole source code, but the program itself and the install script, to avoid confusion and reduce download size.~~ — Done: release workflow attaches a pre-built `bkp` binary.
  - Releasing in DEB/RPM format can also be considered for easier installation and updates.