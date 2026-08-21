# Portable-scripts verification status

This checklist records tests that were actually performed. Presence in the
repository is not evidence that a command works.

## Status vocabulary

- **verified** — exercised successfully in the listed environment.
- **partially verified** — only the stated subset or path was exercised.
- **known failure** — exercised and failed; the failure is recorded in follow-up.
- **not tested** — no meaningful execution has been performed yet.

## Migration and installation

| Command/script | Purpose/category | Prerequisites or risky side effects | Platform/environment | Date | Result | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| `setup` | Migration and installation | Changes home links; use a disposable home or `--dry-run` first | macOS | 2026-07-28 | not tested | Test fresh clone, legacy symlink, protected XDG data, `MOVEALL`, collision, and repeat runs |
| `setup` | Migration and installation | Same as above; avoid assumptions about GNU utilities | Linux/Cocalc-like | 2026-07-28 | not tested | Repeat the macOS fixture scenarios with restricted user-owned paths |
| `bin/bootstrap` | Bootstrap helper | May create or inspect user configuration | macOS/Linux | 2026-07-28 | not tested | Determine whether it remains needed after the new setup contract |

## Shell initialization

| Command/script | Purpose/category | Prerequisites or risky side effects | Platform/environment | Date | Result | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| `dotfiles/bash_aliases` | Bash aliases and sourced functions | Sources other repository files | macOS/Linux | 2026-07-28 | not tested | Source in a clean shell with `PORTABLE_SCRIPTS_HOME` set |
| `dotfiles/env` | `PATH`, library, and template environment | Changes exported shell variables | macOS/Linux | 2026-07-28 | not tested | Verify no duplicate path entries and correct repository root |
| `dotfiles/bash_setup` | Bash startup setup | Changes startup path ordering | macOS/Linux | 2026-07-28 | not tested | Verify with a non-interactive shell |
| `dotfiles/bash_paths` | Manual-page and path setup | Changes `MANPATH` and related variables | macOS/Linux | 2026-07-28 | not tested | Verify repository manuals remain discoverable |

## Command families

| Command/script | Purpose/category | Prerequisites or risky side effects | Platform/environment | Date | Result | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| `bin/*` | Portable command-line utilities | Individual tools may require external programs | macOS/Linux | 2026-07-28 | not tested | Add entries only after representative commands are exercised |
| `scripts/*` | Sourced shell functions and helpers | Intended for interactive shells; may assume Bash | macOS/Linux | 2026-07-28 | not tested | Test by practical command family, not by file presence |
| `lib/*` | Libraries and support files | Consumers and language runtimes vary | macOS/Linux | 2026-07-28 | not tested | Record prerequisites with each tested consumer |
| `man/*` | Manual pages | Requires `MANPATH` configuration | macOS/Linux | 2026-07-28 | not tested | Verify representative pages with `man -w` |
| `apps/*` and templates | Project/application templates | May create files or require toolchains | macOS/Linux | 2026-07-28 | not tested | Test templates individually before claiming support |

## Checklist workflow

After a real manual or automated test, update the relevant row with the command,
purpose, prerequisites, platform/environment, date, result, and follow-up notes.
Link a repeatable fixture or test script when one exists. Keep failures and
environment-specific limitations visible; do not convert an untested entry to
verified merely because it is present in Git.
