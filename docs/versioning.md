## Versioning Conventions

- Stable releases use SemVer tags such as `v0.2.0`.
- Pushing a tag triggers `.github/workflows/release.yml`, which bakes the version into the binary and creates a GitHub Release.
- `install.sh` downloads pre-built artifacts from GitHub Releases (no install-time version embedding).
- `install.sh --version <tag>` installs a specific tagged release.
- Installed release binaries print the exact embedded tag with `bkp --version`.
- Developer installs via `scripts/dev-install.sh` report `git describe --tags --dirty --always`, so unreleased work includes tag ancestry and a commit hash.
- Both installers use symlink-based versioning: `bkp -> bkp-v0.2.0`.