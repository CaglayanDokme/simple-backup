# Improvement Roadmap

## Coding Guidelines & Copilot Instructions

- **Create shell coding guidelines** (`docs/coding-guidelines.md`) — ShellCheck compliance, `set -euo pipefail`, `readonly`/`local` conventions, snake_case naming, quoting rules, error handling patterns
- **Add Copilot instructions** (`.github/copilot-instructions.md`) — project context, patterns, test conventions, reference to coding guidelines

## Versioning System

- **Add `--version` flag** to backup.sh — `VERSION` variable at top of script, `-v`/`--version` in parser
- **Tag-based SemVer** — start at `v0.1.0`, document policy in CONTRIBUTING.md
- **Add `CHANGELOG.md`** — [Keep a Changelog](https://keepachangelog.com/) format, backfill from git history
- **Create first GitHub Release** (`v0.1.0`) — update install.sh to optionally fetch a specific version tag instead of `master`

## CI/CD — GitHub Actions

- **Test runner script** (`test/run-all.sh`) — discovers and runs all tests, reports pass/fail summary, exits non-zero on any failure
- **ShellCheck lint workflow** (`.github/workflows/lint.yml`) — runs ShellCheck on all `.sh`/`.bash` files on push and PR
- **Multi-distro test matrix** (`.github/workflows/test.yml`) — containers: Ubuntu 22.04, Ubuntu 24.04, Debian 12 (bookworm), Fedora latest, Alpine latest. Runs `test/run-all.sh` on each
- **Install verification** — test install.sh works on each distro, verify `bkp --help` succeeds post-install (can be part of step 13)

## Test Improvements

- **Add `fail_test()` helper** to testlib.bash — currently only `pass_test()` exists; failures use raw `exit 1`
- **Expand test coverage** — `--help` output, `--version` output, combined `-d -t`, invalid arguments, spaces in filenames, empty directories, `--` separator, permission errors
- **Cross-platform portability tests** — specifically test `cp`/`mv` flag compatibility (the `--update` issue)

## Code Quality Hardening

- **ShellCheck compliance pass** — fix all warnings, add directive comments for justified exceptions
- **Portability fix for `--update`** — runtime feature-detect `--update=none` vs `--update` vs `cp -n` in backup.sh; document minimum coreutils version
- **Harden install.sh** — optional checksum verification of downloaded script, `--uninstall` support