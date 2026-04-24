# Change Logs

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