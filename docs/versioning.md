## Versioning Conventions

- Stable releases use SemVer tags such as `v0.0.2`.
- Remote installs with no installer arguments always target the latest published GitHub Release.
- `install.sh --version <tag>` installs a specific tagged release.
- Installed release binaries print the exact embedded tag with `bkp --version`.
- Local checkouts and local installs report `git describe --tags --dirty --always`, so unreleased work includes tag ancestry and a commit hash.