## Versioning Conventions

- Stable releases use SemVer tags such as `v0.2.0`.
- Pushing a tag triggers `.github/workflows/release.yml`, which calls `scripts/extract-release-notes.sh` and `scripts/build-release.sh` before creating the GitHub Release.
- Pull requests targeting `master` and pushes to `master` trigger `.github/workflows/release-check.yml`, which requires the top changelog section to be a concrete versioned heading (e.g., `## v0.4.3 - April 26, 2026`). The check validates SemVer progression, release note extraction, and artifact build. `Unreleased` headings are rejected.
- `install.sh` downloads pre-built artifacts from GitHub Releases (no install-time version embedding).
- `install.sh --version <tag>` installs a specific tagged release.
- Installed release binaries print the exact embedded tag with `bkp --version`.
- Developer installs via `scripts/dev-install.sh` report `git describe --tags --dirty --always`, so unreleased work includes tag ancestry and a commit hash.
- Both installers use symlink-based versioning: `bkp -> bkp-v0.2.0`.