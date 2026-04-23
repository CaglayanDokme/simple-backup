# Improvement Roadmap

## CI/CD — GitHub Actions

- **ShellCheck lint workflow** (`.github/workflows/lint.yml`) — runs ShellCheck on all `.sh`/`.bash` files on push and PR
- **Install verification** — test install.sh works on each distro, verify `bkp --help` succeeds post-install (can be part of step 13)

## Test Improvements

- **Add `fail_test()` helper** to testlib.bash — currently only `pass_test()` exists; failures use raw `exit 1`
- **Expand test coverage** — `--help` output, `--version` output, combined `-d -t`, invalid arguments, spaces in filenames, empty directories, `--` separator, permission errors
- **Cross-platform portability tests** — specifically test `cp`/`mv` flag compatibility (the `--update` issue)

## Code Quality Hardening

- **ShellCheck compliance pass** — fix all warnings, add directive comments for justified exceptions
- **Portability fix for `--update`** — runtime feature-detect `--update=none` vs `--update` vs `cp -n` in backup.sh; document minimum coreutils version
- **Harden install.sh** — optional checksum verification of downloaded script, `--uninstall` support

## Feature Enhancements
- Backup by compressing (e.g. `tar.gz`) instead of copying — add `--archive` flag to backup.sh, implement with `tar` and `gzip`
- Add `--exclude` flag to backup.sh — support multiple exclusions, implement with `rsync` or `tar --exclude`
- Add `--dry-run` flag to backup.sh — show what would be backed up without actual action