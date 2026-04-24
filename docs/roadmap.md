# Improvement Roadmap

## Feature Enhancements
- Add `--dry-run` flag to backup.sh — show what would be backed up without actual action
- `install.sh` shall warn and ask for confirmation if `bkp` is already installed before overwriting (It shall also print whether updating or downgrading, and the existing vs new version numbers.)
- Install with symbolic link so that updates can be done without needing to overwrite the existing file
  - /usr/local/bin/bkp -> /user/local/bin/bkp-v0.2.0
  - /user/local/bin/bkp-v0.1.0 or other versions can be kept for rollback or upgrade if needed