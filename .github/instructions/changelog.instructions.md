---
description: "Use when updating docs/changelog.md, release notes, version sections, or upcoming version entries. Covers changelog structure, release heading rules, and entry placement for this repository."
applyTo: "docs/changelog.md"
---

# Changelog Instructions

- Update `docs/changelog.md` when a change is user-facing, adds a feature, changes flags or behavior, or otherwise affects release notes.
- Keep entries focused on user-visible outcomes. Internal refactors can be omitted unless they materially affect release or maintenance workflows.
- Keep the newest section at the top of the file.
- Use these section names when they apply: `### New features`, `### Improvements`, `### Bug fixes`.
- Write concise bullet points in past tense, matching the existing changelog style.

## Development Entries

- During normal development, prefer `## Upcoming new version` at the top of `docs/changelog.md`.
- If `## Upcoming new version` already exists, add new bullets under the appropriate subsection instead of creating a duplicate heading.
- If the latest changelog version does not yet match the latest repository tag, treat that top version section as the in-progress section and append to it instead of creating `## Upcoming new version`.

## Release Entries

- For release-ready changelog updates, rename the top section to the exact format `## vMAJOR.MINOR.PATCH - Month DD, YYYY`.
- Use SemVer tags with a leading `v`, such as `v0.4.3`.
- Keep the date in the same human-readable style already used in the file, such as `April 26, 2026`.
- Ensure the top release version progresses correctly from the next versioned section below it. Valid progressions are next patch, next minor with patch reset to `0`, or next major with minor and patch reset to `0`.
- Keep enough detail under the version heading for `scripts/extract-release-notes.sh` to use the section body as release notes.

## Agent Checks

- Before adding a new top section, inspect the existing top heading in `docs/changelog.md` and the latest repository tag so the entry lands in the correct section.
- When preparing a release or changes targeting `master`, make sure the first `##` heading is a concrete versioned release heading because `scripts/check-release.sh` requires it.
- Preserve blank-line spacing and heading levels already used in `docs/changelog.md`.