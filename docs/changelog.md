# Change Logs

## v0.4.3 - April 26, 2026
### Improvements
- Extracted the release workflow shell bodies into `scripts/extract-release-notes.sh` and `scripts/build-release.sh`.
- Added `scripts/check-release.sh` to orchestrate release validation: version detection, SemVer progression, note extraction, and artifact build.
- Simplified `.github/workflows/release-check.yml` to a single script call; requires a concrete versioned changelog heading before merging to master.
- Added SemVer progression validation to `scripts/extract-release-notes.sh`.

## v0.4.2 - April 26, 2026
### Improvements
- Added `test/run-all.sh` so the full shell test suite can run in a single command locally, in CI, and from VS Code.
- Removed install-specific tests from the default suite and routed CI through the unified test runner.
- Automatically omit top-level `.bkp` and `.bkp.tar.gz` inputs from new backup runs and print a warning for each omitted path.

## v0.4.1 - April 26, 2026
### Improvements
- Reused a single invocation timestamp for all `--timestamp` backups so multi-file runs produce consistent backup names.
- Made compression tool checks configurable via `BKP_TAR_BIN` and `BKP_GZIP_BIN`, which stabilizes missing-tool tests without PATH stubbing.

## v0.4.0 - April 26, 2026
### New features
- Added compression modes: `-c` / `--compress` now defaults to merged archives, while `--compress=separate` preserves the previous one-archive-per-target behavior.
- Added `-a` / `--archive-name NAME` for naming merged archives when backing up multiple targets.

## v0.3.0 - April 24, 2026
### New features
- Added repeatable `-e` / `--exclude PATTERN` glob filtering for copy, move, and compressed backups.

### Improvements
- Simplified `install.sh` to a lean release installer that downloads pre-built artifacts from GitHub Releases.
- Added `scripts/dev-install.sh` for developer installs from local repository checkouts.
- Both installers now use symlink-based versioning (`bkp -> bkp-v0.2.0`) for side-by-side version management and rollback.
- Added `.github/workflows/release.yml`: automated GitHub Release creation on tag push with pre-baked `bkp` artifact and changelog-based release notes.
- Dropped legacy awk-based version injection for pre-v0.2.0 scripts.

## v0.2.0 - April 24, 2026
### New features
- Added `-c` / `--compress` to create `.bkp.tar.gz` backups using `tar` and `gzip`.

### Improvements
- Added workflow files for CI testing on GitHub Actions. See [.github/workflows](.github/workflows) for details.
- Added testing on different Linux distributions: Ubuntu 20.04, 22.04, 24.04; Debian 12; Fedora 42; Alpine 3.21.
- Created coding guidelines in [docs/coding-guidelines.md](docs/coding-guidelines.md) and linked from shell script instructions.

## v0.1.0 - April 23, 2026
- Initial release.
