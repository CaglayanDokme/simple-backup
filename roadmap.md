### Current State Assessment

| Aspect                | Status                                             |
| --------------------- | -------------------------------------------------- |
| Core functionality    | Working, ~250 LOC bash                             |
| Tests                 | 10 scripts + testlib; good coverage of features    |
| CI/CD                 | **None**                                           |
| Versioning            | **None** (no tags, no releases, no `--version`)    |
| LICENSE file          | **Missing** (README says MIT but no actual file)   |
| .gitignore            | **Missing**                                        |
| Contributing guide    | **Missing**                                        |
| Coding guidelines     | **Missing**                                        |
| Copilot instructions  | **Missing**                                        |
| ShellCheck compliance | **Unknown**                                        |
| Cross-distro compat   | Known issues (`cp --update` on Ubuntu 22.04)       |
| Test runner           | Manual — no harness, no summary, no CI integration |

---

### Improvement Roadmap

#### Phase 1: OSS Foundation (no code changes)

1. **Add `LICENSE` file** — MIT text at repo root (README already declares MIT)
2. **Add `.gitignore`** — ignore `*.swp`, `*~`, `.DS_Store`, etc.
3. **Add `CONTRIBUTING.md`** — fork/branch/PR workflow, test requirements, coding standards reference
4. **Add `CODE_OF_CONDUCT.md`** — standard Contributor Covenant

#### Phase 2: Coding Guidelines & Copilot Instructions

5. **Create shell coding guidelines** (`docs/coding-guidelines.md`) — ShellCheck compliance, `set -euo pipefail`, `readonly`/`local` conventions, snake_case naming, quoting rules, error handling patterns
6. **Add Copilot instructions** (`.github/copilot-instructions.md`) — project context, patterns, test conventions, reference to coding guidelines

#### Phase 3: Versioning System

7. **Add `--version` flag** to backup.sh — `VERSION` variable at top of script, `-v`/`--version` in parser
8. **Tag-based SemVer** — start at `v0.1.0`, document policy in CONTRIBUTING.md
9. **Add `CHANGELOG.md`** — [Keep a Changelog](https://keepachangelog.com/) format, backfill from git history
10. **Create first GitHub Release** (`v0.1.0`) — update install.sh to optionally fetch a specific version tag instead of `master`

#### Phase 4: CI/CD — GitHub Actions (*depends on Phases 2-3*)

11. **Test runner script** (`test/run-all.sh`) — discovers and runs all tests, reports pass/fail summary, exits non-zero on any failure
12. **ShellCheck lint workflow** (`.github/workflows/lint.yml`) — runs ShellCheck on all `.sh`/`.bash` files on push and PR
13. **Multi-distro test matrix** (`.github/workflows/test.yml`) — containers: Ubuntu 22.04, Ubuntu 24.04, Debian 12 (bookworm), Fedora latest, Alpine latest. Runs `test/run-all.sh` on each
14. **Install verification** — test install.sh works on each distro, verify `bkp --help` succeeds post-install (can be part of step 13)

#### Phase 5: Test Improvements (*parallel with Phase 4*)

15. **Add `fail_test()` helper** to testlib.bash — currently only `pass_test()` exists; failures use raw `exit 1`
16. **Expand test coverage** — `--help` output, `--version` output, combined `-d -t`, invalid arguments, spaces in filenames, empty directories, `--` separator, permission errors
17. **Cross-platform portability tests** — specifically test `cp`/`mv` flag compatibility (the `--update` issue)

#### Phase 6: Code Quality Hardening (*depends on Phases 4-5*)

18. **ShellCheck compliance pass** — fix all warnings, add directive comments for justified exceptions
19. **Portability fix for `--update`** — runtime feature-detect `--update=none` vs `--update` vs `cp -n` in backup.sh; document minimum coreutils version
20. **Harden install.sh** — optional checksum verification of downloaded script, `--uninstall` support

---

### Relevant Files

- backup.sh — add `--version`, portability fixes
- install.sh — version-aware install, uninstall support
- testlib.bash — add `fail_test()`, improve helpers
- `test/run-all.sh` — **new**; test runner/harness
- `.github/workflows/lint.yml` — **new**; ShellCheck CI
- `.github/workflows/test.yml` — **new**; multi-distro test matrix
- `.github/copilot-instructions.md` — **new**; Copilot context
- `LICENSE` — **new**
- `.gitignore` — **new**
- `CONTRIBUTING.md` — **new**
- `CHANGELOG.md` — **new**
- `docs/coding-guidelines.md` — **new**; shell coding standards

### Verification

1. `shellcheck backup.sh install.sh test/*.sh test/*.bash` passes cleanly
2. `test/run-all.sh` passes locally
3. GitHub Actions green on all 5 distros (Ubuntu 22.04, 24.04, Debian 12, Fedora, Alpine)
4. `bkp --version` prints version matching the git tag
5. install.sh succeeds in CI containers

### Decisions

- Start versioning at **`v0.1.0`** (pre-1.0 signals early stage)
- **SemVer** (major.minor.patch)
- **MIT license** (already declared)
- **Custom test runner** over bats-core — keeps it consistent with existing test style; bats is a future option if the suite grows
- Multi-distro testing via **Docker containers in GitHub Actions**

### Further Considerations

1. **bats-core vs. custom test runner** — bats gives TAP output, lifecycle hooks, and better IDE integration. But the project already has a working test pattern. Recommendation: custom runner for now, consider bats later.
2. **man page** — A `bkp.1` man page would be a polished touch for a tool installed to bin. Low priority.
3. **Homebrew/apt packaging** — Future option if the project gains traction. Out of scope now.