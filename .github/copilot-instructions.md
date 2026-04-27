# copilot-instructions.md

## Project Snapshot

- `bkp` is a small Bash CLI for creating local backups with `.bkp` suffixes.
- Core behavior lives in `src/backup.sh`.
- `install.sh` only stages and installs the script to `/usr/local/bin/bkp`.
- User-facing usage and examples live in [README.md](README.md).
- Planned work and future conventions live in [roadmap.md](roadmap.md).

## Important Files

- `src/backup.sh`: main CLI, option parsing, validation, and backup behavior.
- `install.sh`: installer for local checkout and `curl | bash` usage.
- `test/run-all.sh`: unified test runner for the full shell test suite.
- `test/testlib.bash`: shared temp-directory test helpers.
- `test/*.sh`: scenario-based shell tests; each script validates one behavior.

## Working Conventions

- Use Bash, not POSIX sh. Match the existing `#!/bin/bash` and `set -euo pipefail` style.
- Prefer `readonly` for globals, `local` for function variables, quoted expansions, and arrays for command assembly.
- Keep the implementation dependency-light: current code assumes Bash plus common coreutils.
- Preserve the tool's safety-first behavior unless the task explicitly changes it:
  - directories require `-r` or `--recursive`
  - symlinks require `-s` or `--symbolic`
  - overwriting existing backups requires `-f` or `--force`
- Maintain support for combined short flags such as `-mrt`, long flags, and `--` argument termination.

## Validation

- When adding new features or flags, if not already present, add corresponding test scripts that validate the new behavior in isolation.
- Run the full suite with `bash test/run-all.sh`.
- Prefer targeted scenario tests: `bash test/<name>.sh`
- For core CLI checks, prefer `bash src/backup.sh --help` over installing the tool.
- Only run `bash install.sh` when the change is specifically about installation, because it writes to `/usr/local/bin` and may invoke `sudo`.

## Change Scope

- Keep changes narrow and behavior-focused.
- Do not implement roadmap items unless the task asks for them.
- When behavior or flags change, update [README.md](README.md) and [docs](docs) in the same change.
- Add change summary to [docs/changelog.md](docs/changelog.md) when the change is a user-facing behavior change or new feature. For internal refactors, it's optional but helpful to add a brief note.
- If there isn't a new version header in the changelog for the change, add an "Upcoming new version" section at the top with a brief summary of the change. This signals that the change is in progress and not yet released.

```
## Upcoming new version
### Improvements
- <Brief summary of the change here>

### New features
- <Brief summary of the new feature here>

### Bug fixes
- <Brief summary of the bug fix here>
```

- If there is already an "Upcoming new version" section or a relevant version header, add the summary under the appropriate section. You can determine whether to use the existing version header by checking the latest tag in the repository and trying to match it to the latest version in the changelog. If there is no tag matching the latest version from change log, then you can add the change summary to that version header instead of creating a new "Upcoming new version" section.
- After completing a change, run `bash test/run-all.sh` to ensure no regressions. If a test fails, fix the issue before finalizing the change.
- Finalize the change with a commit message draft that includes a concise summary of the change and references any relevant test scripts or documentation updates.
- When all changes are complete and validated, remove leftover files.