# Improvement Roadmap

## Feature Enhancements
- Backup by compressing (e.g. `tar.gz`) instead of copying — add `--archive` flag to backup.sh, implement with `tar` and `gzip`
- Add `--exclude` flag to backup.sh — support multiple exclusions, implement with `rsync` or `tar --exclude`
- Add `--dry-run` flag to backup.sh — show what would be backed up without actual action
- `install.sh` shall warn and ask for confirmation if `bkp` is already installed before overwriting (It shall also print whether updating or downgrading, and the existing vs new version numbers.)