# Contributing to Engineering Toolkit

Thank you for considering a contribution. This repository is a shared asset
for many teams and projects, so changes are held to a higher bar than a
typical application repo: everything here is meant to be copied into someone
else's codebase and trusted at face value.

## Before you start

Read [`docs/engineering-playbook.md`](docs/engineering-playbook.md) to
understand the philosophy this toolkit follows, and skim the
[README](README.md) folder structure so you know where your change belongs.

## What makes a good addition

- **Language- and framework-agnostic.** Nothing here should assume Node.js,
  Python, Java, a specific cloud provider, or a specific CI vendor unless the
  file is explicitly scoped to that (e.g., `scripts/*.sh` vs `scripts/*.ps1`
  pairs, kept in sync). If your content is genuinely stack-specific, it
  probably belongs in the consuming project, not here.
- **No vendor lock-in.** Avoid hard dependencies on a single SaaS tool,
  paid product, or proprietary format. Where a tool is referenced as an
  example (e.g., a specific CI provider), present it as one option among
  several rather than a requirement.
- **Immediately usable.** No placeholder text, no "TODO", no "Coming Soon"
  sections, no Lorem Ipsum. If a document isn't finished, don't merge it.
- **Opinionated but justified.** State a clear recommendation, then explain
  the rationale and tradeoffs. "Do X" without "because Y" is not useful in a
  toolkit that has to serve teams with different constraints.
- **Consistent with existing structure.** Match the tone, heading structure,
  and depth of neighboring files in the same folder before introducing a new
  pattern.

## Branching and commits

- Follow [`docs/branch-strategy.md`](docs/branch-strategy.md) for branch
  naming and lifecycle.
- Follow [`docs/conventional-commits.md`](docs/conventional-commits.md) for
  commit messages. This keeps `CHANGELOG.md` generation and history
  scanning consistent.
- Keep commits scoped to a single logical change (one new template, one doc
  rewrite, one script fix) so review and history stay legible.

## Adding a new file

Each top-level folder has a `README.md` that indexes its contents. When you
add a new file, you must also add it to that index in the same PR:

| Adding a... | Goes in | Update index at |
|---|---|---|
| Process/reference doc | `docs/<kebab-case-name>.md` | `docs/README.md` |
| AI prompt | `prompts/<kebab-case-name>.md` | `prompts/README.md` |
| Checklist | `checklists/<kebab-case-name>.md` | `checklists/README.md` |
| Fill-in-the-blank template | `templates/<kebab-case-name>.md` | `templates/README.md` |
| Worked example | `examples/<kebab-case-name>.md` | `examples/README.md` |
| Automation script | `scripts/<kebab-case-name>.sh` **and** `.ps1` | `scripts/README.md` |
| Claude Code rule | `.claude/rules/<kebab-case-name>.md` | referenced from `.claude/CLAUDE.md` |
| Claude Code slash command | `.claude/commands/<kebab-case-name>.md` | referenced from `.claude/CLAUDE.md` |

Rules of thumb:

- Use kebab-case filenames everywhere (`root-cause-analysis.md`, not
  `RootCauseAnalysis.md` or `root_cause_analysis.md`) — **with one deliberate
  exception**: the nine decision-record templates at the core of `templates/`
  (`ADR.md`, `FEATURE_SPEC.md`, `TECHNICAL_DESIGN.md`, `API_DESIGN.md`,
  `DATABASE_CHANGE.md`, `BUG_REPORT.md`, `POSTMORTEM.md`, `PR_TEMPLATE.md`,
  `CODE_REVIEW.md`) use `SCREAMING_SNAKE_CASE`, matching the convention
  mature engineering orgs and tools (GitHub's own `PULL_REQUEST_TEMPLATE.md`,
  `CODEOWNERS`, `SECURITY.md`) use for standalone, capitalized reference
  documents. If you add a tenth template to that specific set, match its
  casing; every other new file in the repo stays kebab-case.
- Cross-link using **relative Markdown links** (e.g.
  `[ADR guide](../docs/adr-guide.md)` from within `templates/`), never
  absolute URLs into the repo, so the toolkit works whether it's cloned
  directly or vendored into another repo at a different path.
- Scripts that touch the filesystem or run in CI must ship both a `.sh`
  (Bash) and `.ps1` (PowerShell) version so the toolkit stays usable from
  Linux/macOS and Windows.

## Review expectations

- A PR that adds or changes a doc/template/prompt/checklist should explain,
  in the PR description, what gap it fills or what it corrects — reviewers
  are evaluating fitness for reuse across unrelated projects, not just
  correctness for one.
- Reviewers will check: no placeholder content, working relative links,
  index files updated, filename convention followed, and tone/format
  consistency with sibling files.
- Non-trivial structural changes (renaming folders, changing the indexing
  convention) should be proposed as an issue or discussion before the PR so
  the change doesn't conflict with in-flight work.

## Validate before opening a PR

Run the validation scripts locally and fix any reported issues:

```bash
# Bash (Linux/macOS/WSL)
./scripts/validate-links.sh
./scripts/validate-markdown.sh
```

```powershell
# PowerShell (Windows)
./scripts/validate-links.ps1
./scripts/validate-markdown.ps1
```

These are the same checks enforced by the `lint` and `link-check` GitHub
Actions workflows (`.github/workflows/lint.yml`,
`.github/workflows/link-check.yml`); running them locally first avoids a
round trip through CI.

## Pull requests

Use the repository's [pull request template](.github/PULL_REQUEST_TEMPLATE/pull_request_template.md)
and consult [`checklists/before-pull-request.md`](checklists/before-pull-request.md)
before requesting review.

## Code of conduct

Participation in this project is governed by the
[Code of Conduct](CODE_OF_CONDUCT.md).
