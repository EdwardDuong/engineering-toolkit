# Scripts

Automation for maintaining this toolkit and for adopting it into other
projects. Every tool here ships as a matched pair: a POSIX shell script
(`.sh`, for macOS, Linux, and Git Bash on Windows) and a PowerShell
script (`.ps1`, for Windows, and cross-platform via PowerShell 7+).
Pick whichever matches your shell — both implementations produce the
same checks, the same output format, and the same exit codes, since
this toolkit is meant to be copied into projects on any operating
system.

None of these scripts are destructive. The four validation and
reporting tools are read-only: they inspect the repository and print
results, and never write, move, or delete anything. `bootstrap-project`
is the only tool that writes to disk, and it only ever creates new
files — it refuses to overwrite anything that already exists at the
destination.

## Requirements

- **Shell scripts**: `bash` with the standard GNU/BSD coreutils
  (`find`, `grep`, `sed`, `realpath`, `od`) on the `PATH`. On Windows,
  Git for Windows' Git Bash provides all of this out of the box.
- **PowerShell scripts**: Windows PowerShell 5.1 or PowerShell 7+.

## Tools

### validate-links

Checks that every relative Markdown link in the repository points at a
file or directory that actually exists.

It walks every `*.md` file (skipping `.git/`), extracts inline links of
the form `[text](path)` and image links of the form `![alt](path)`,
ignores links with a URI scheme (`http://`, `https://`, `mailto:`, and
similar) and anchor-only links (`#section`), resolves the remaining
path relative to the directory of the file that contains it (or
relative to the repository root if the link starts with `/`), and
reports every link whose target is missing.

Usage:

```sh
sh scripts/validate-links.sh [path-to-repo-root]
```

```powershell
powershell -File scripts/validate-links.ps1 [path-to-repo-root]
```

`path-to-repo-root` is optional and defaults to the current directory.

Exit codes:

| Code | Meaning                                    |
| ---- | ------------------------------------------- |
| 0    | No broken links found.                      |
| 1    | One or more broken links found.             |
| 2    | Usage error (the given path is not a directory). |

### validate-markdown

Checks basic Markdown hygiene across the repository: no trailing
whitespace (aside from an intentional two-space hard line break), every
file ends with exactly one trailing newline, no more than one blank
line in a row, heading levels never skip a level (for example `#`
followed directly by `###`), and no leftover placeholder text — an
unfinished-work marker, a premature launch notice, or placeholder
filler copy — none of which belong in a production-quality document.

Usage:

```sh
sh scripts/validate-markdown.sh [path-to-repo-root]
```

```powershell
powershell -File scripts/validate-markdown.ps1 [path-to-repo-root]
```

`path-to-repo-root` is optional and defaults to the current directory.

Exit codes:

| Code | Meaning                                    |
| ---- | ------------------------------------------- |
| 0    | No hygiene violations found.                |
| 1    | One or more violations found.               |
| 2    | Usage error (the given path is not a directory). |

### bootstrap-project

Adopts this toolkit into an existing host project by copying the
portable, non-toolkit-specific folders — `.claude/`, `docs/`,
`templates/`, `prompts/`, `checklists/`, and `scripts/` — into a target
directory. Any file that already exists at the destination is left
alone; the script reports it as skipped rather than overwriting it, so
it is always safe to re-run against a project that has already been
bootstrapped once.

Usage:

```sh
sh scripts/bootstrap-project.sh <target-directory>
```

```powershell
powershell -File scripts/bootstrap-project.ps1 <target-directory>
```

`target-directory` is required; the script prints usage and exits if it
is missing. The directory is created if it does not already exist.

Exit codes:

| Code | Meaning                                              |
| ---- | ----------------------------------------------------- |
| 0    | Completed (files copied and/or skipped as needed).    |
| 1    | Usage error (missing `target-directory` argument).    |
| 2    | Target path invalid, or target is the toolkit's own repository root. |

### release-check

A pre-release gate intended to run in CI or locally before tagging a
release. It verifies that `CHANGELOG.md` has a real released version
entry (not just an `[Unreleased]` heading), that `LICENSE` exists and
is non-empty, and then shells out to the sibling `validate-markdown`
and `validate-links` scripts. It prints a `PASS`/`FAIL` line for each
check followed by an overall summary.

Usage:

```sh
sh scripts/release-check.sh [path-to-repo-root]
```

```powershell
powershell -File scripts/release-check.ps1 [path-to-repo-root]
```

`path-to-repo-root` is optional and defaults to the current directory.

Exit codes:

| Code | Meaning                                              |
| ---- | ----------------------------------------------------- |
| 0    | All checks passed.                                   |
| 1    | One or more checks failed.                           |
| 2    | Usage error (bad path, or a sibling script is missing). |

### repository-audit

An informational health report: counts files per top-level folder,
flags empty directories, flags Markdown files under roughly five lines
(likely stubs), flags file names containing spaces, and flags casing
issues that could collide on a case-insensitive filesystem (Windows or
macOS) even though they are distinct on a case-sensitive one (Linux,
and `git` itself) — for example `Readme.md` next to `README.md` in the
same directory, or a file with an uppercase extension like `NOTES.MD`.

This tool never fails the build. It always exits `0`; read the printed
report to see whether anything needs attention.

Usage:

```sh
sh scripts/repository-audit.sh [path-to-repo-root]
```

```powershell
powershell -File scripts/repository-audit.ps1 [path-to-repo-root]
```

`path-to-repo-root` is optional and defaults to the current directory.

Exit codes:

| Code | Meaning                                    |
| ---- | ------------------------------------------- |
| 0    | Always, on a normal run.                    |
| 2    | Usage error (the given path is not a directory). |

## Wiring these into CI

A typical CI job runs `validate-markdown` and `validate-links` on every
pull request, and `release-check` as a required step before a release
tag is pushed. `repository-audit` is meant for humans: run it locally
when you want a quick sense of the repository's shape, not as an
automated gate.
