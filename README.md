<p align="center">
  <img src="assets/logo.svg" alt="Engineering Toolkit logo" width="120" />
</p>

<h1 align="center">Engineering Toolkit</h1>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" /></a>
</p>

A portable, language-agnostic **engineering operating system** — process
docs, templates, checklists, and AI prompts you can drop into any software
project, regardless of language, framework, or cloud provider.

## Purpose

Most engineering orgs reinvent the same artifacts on every project: a
branching strategy, a definition of done, an incident postmortem template,
an ADR format, a PR checklist, a set of code review norms. These usually
live in one senior engineer's head, a stale wiki page, or nowhere at all —
and they get rebuilt from scratch (inconsistently) every time a new repo or
a new team spins up.

The Engineering Toolkit packages this as a set of plain Markdown files with
no build step, no runtime, and no vendor lock-in, so a team can:

- **Copy it once** into a new or existing repository and immediately have a
  working set of engineering conventions.
- **Adapt it**, not adopt it wholesale — every doc explains its rationale
  and tradeoffs so teams can knowingly deviate where their context differs.
- **Wire it into AI coding assistants** (Claude Code, Cursor, GitHub
  Copilot) so the same standards that live in your docs also shape how AI
  writes and reviews code in your repo.

It is not a framework, a CLI, or a service — it is reference material,
designed to be read by humans and machines alike.

## Features

| Folder | What it provides |
|---|---|
| [`docs/`](docs/README.md) | Reference guides: architecture principles, clean code (SOLID/KISS/YAGNI/DRY), git workflow, testing strategy, security, performance, observability, incident response, ADRs/RFCs, and more. |
| [`templates/`](templates/README.md) | Fill-in-the-blank Markdown templates: ADRs, RFCs, pull requests, bug/feature reports, epics, user stories, runbooks, incident reports, postmortems, risk registers, release notes. |
| [`prompts/`](prompts/README.md) | AI assistant prompts for implementing features, investigating bugs, reviewing PRs, security/performance review, refactoring, generating tests, and more — usable with any LLM-based coding assistant. |
| [`checklists/`](checklists/README.md) | Gate checklists for the delivery lifecycle: before coding, before commit, before PR, before merge, before release, production readiness. |
| [`examples/`](examples/README.md) | Worked, realistic examples of a good architecture doc, ADR, API doc, incident report, postmortem, PR, and README — so "good" isn't left to imagination. |
| [`scripts/`](scripts/README.md) | Cross-platform (Bash + PowerShell) automation: link validation, Markdown linting, project bootstrap, and release checks. |
| [`.claude/`](.claude/CLAUDE.md) | Claude Code configuration: project rules and slash commands that encode this toolkit's standards directly into an AI coding assistant's behavior. |

## Folder Structure

```text
engineering-toolkit/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── CHANGELOG.md                       # Keep a Changelog + SemVer history
├── CONTRIBUTING.md                    # How to contribute to this toolkit
├── CODE_OF_CONDUCT.md                 # Contributor Covenant v2.1
├── SECURITY.md                        # Vulnerability reporting for this repo
├── .editorconfig                      # Cross-editor formatting defaults
├── .gitattributes                     # Line-ending / text normalization
├── .gitignore                         # Generic, language-agnostic ignores
│
├── .github/
│   ├── ISSUE_TEMPLATE/                # Bug report + feature request forms
│   ├── PULL_REQUEST_TEMPLATE/         # PR template for this repo
│   └── workflows/                     # lint.yml, link-check.yml (CI)
│
├── .claude/                           # Claude Code configuration
│   ├── CLAUDE.md                      # Project-level instructions for Claude Code
│   ├── rules/                         # Composable rules (architecture, readability, security, ...)
│   ├── commands/                      # Slash commands (/plan, /implement, /review, /test, /security-audit)
│   ├── agents/                        # Specialized personas (backend, frontend, database, DevOps, security, architect, reviewer)
│   └── workflows/                     # Multi-step workflows (feature dev, bug fix, release)
│
├── docs/                              # Engineering playbook and reference guides
├── prompts/                           # AI prompts for engineering workflows
├── checklists/                        # Lifecycle gate checklists
├── templates/                         # Fill-in-the-blank document templates
├── examples/                          # Worked examples of "good"
├── scripts/                           # Validation and bootstrap automation
└── assets/                            # Logo and static assets
```

Every folder with content has its own `README.md` index — start there when
looking for something specific (e.g. [`docs/README.md`](docs/README.md),
[`templates/README.md`](templates/README.md)).

## Quick Start

Pick the integration method that fits how tightly you want to track updates
to this toolkit.

### Option A — Direct copy (simplest)

Best when you want full control and don't need upstream updates.

```bash
git clone https://github.com/your-org/engineering-toolkit.git /tmp/engineering-toolkit
cp -r /tmp/engineering-toolkit/{docs,templates,prompts,checklists,examples,scripts,.claude} your-project/
cp /tmp/engineering-toolkit/CONTRIBUTING.md your-project/CONTRIBUTING.md  # optional, adapt first
```

Replace `your-org` with your actual GitHub namespace once this toolkit is
published under your organization.

### Option B — Git subtree (recommended for staying in sync)

Keeps a copy in your repo's history but lets you pull upstream updates
later without submodule complexity for your contributors.

```bash
git remote add engineering-toolkit https://github.com/your-org/engineering-toolkit.git
git subtree add --prefix=engineering-toolkit engineering-toolkit main --squash

# Later, to pull updates:
git subtree pull --prefix=engineering-toolkit engineering-toolkit main --squash
```

### Option C — Git submodule (when you want a strict, pinned reference)

Best when multiple repos should reference the exact same toolkit version.

```bash
git submodule add https://github.com/your-org/engineering-toolkit.git engineering-toolkit
git submodule update --init --recursive
```

Note that submodules require contributors to run an extra `init`/`update`
step and can be a source of confusion for teams unfamiliar with them —
subtree or direct copy is usually the better default.

### After copying: adapt `.claude/CLAUDE.md`

`.claude/CLAUDE.md` is written generically. At minimum, update:

- The project name and a one-paragraph description of what the repo does.
- Any language/framework/tooling specifics (this toolkit ships none by
  design — Claude Code needs to know your actual stack).
- Which `.claude/rules/*.md` files apply as-is versus need tightening or
  loosening for your team's norms (see [How to Customize](#how-to-customize)).

## How to use with Claude Code

[Claude Code](https://docs.claude.com/en/docs/claude-code) natively reads
this structure with no adaptation required:

1. Copy (or subtree/submodule) the `.claude/` directory into your
   repository root.
2. Claude Code automatically loads `.claude/CLAUDE.md` as project
   instructions at the start of every session.
3. Slash commands in `.claude/commands/` (`/plan`, `/implement`, `/review`,
   `/test`, `/security-audit`) become available immediately — no
   registration step.
4. Specialized agent personas in `.claude/agents/` (backend, frontend,
   database, DevOps, security, architect, reviewer) give Claude Code a
   domain-specific lens — responsibilities, a review checklist, decision
   principles, and common mistakes to avoid — for the kind of work a change
   actually involves.
5. Rules in `.claude/rules/` are referenced from `CLAUDE.md` and shape how
   Claude Code approaches architecture, testing, security, and code review
   by default, regardless of which command or agent is active.

No other setup is required — this is the toolkit's primary, first-class
integration path.

## How to use with Cursor

Cursor does not read `.claude/` natively, but the content translates
directly. Cursor uses [Project Rules](https://docs.cursor.com/context/rules)
stored in `.cursor/rules/*.mdc`, or a single `.cursorrules` file at the repo
root.

**Recommended approach — mirror `.claude/rules/` into `.cursor/rules/`:**

```bash
mkdir -p .cursor/rules
for f in .claude/rules/*.md; do
  name=$(basename "$f" .md)
  {
    echo "---"
    echo "description: ${name//-/ }"
    echo "alwaysApply: true"
    echo "---"
    echo
    cat "$f"
  } > ".cursor/rules/${name}.mdc"
done
```

This preserves each rule as a separate, individually toggleable Cursor rule
file (Cursor's `.mdc` format supports frontmatter for scoping — e.g.
`globs:` to apply a rule only to certain paths). Adjust `alwaysApply` and
`globs` per rule as needed; not every rule needs to load into every
context window.

**Simpler alternative — single `.cursorrules` file:** concatenate
`.claude/CLAUDE.md` and the contents of `.claude/rules/*.md` into one
`.cursorrules` file at the repo root. This is less flexible (no per-rule
scoping) but requires no tooling and works with older Cursor versions.

Cursor doesn't have a direct equivalent of Claude Code's slash commands
sourced from a folder; the closest analog is prompting Cursor's chat with
the relevant file from `prompts/` open in context (e.g. paste
[`prompts/implement-feature.md`](prompts/implement-feature.md) into the
chat).

## How to use with GitHub Copilot

GitHub Copilot supports repository-wide custom instructions via
[`.github/copilot-instructions.md`](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot).
This file is automatically included in every Copilot Chat request within
the repository.

To adapt this toolkit for Copilot:

1. Create `.github/copilot-instructions.md` in your project (this toolkit
   does not ship one by default, since it's specific to each consuming
   repo's stack).
2. Summarize the most load-bearing rules from `.claude/rules/` into it —
   Copilot's instructions file works best as a concise set of directives
   rather than a full document dump. Prioritize
   [`architecture-first.md`](.claude/rules/architecture-first.md),
   [`security-awareness.md`](.claude/rules/security-awareness.md), and
   [`readability.md`](.claude/rules/readability.md) as a starting set.
3. For task-specific workflows (implementing a feature, investigating a
   bug), paste the relevant file from `prompts/` directly into a Copilot
   Chat session — Copilot doesn't support a slash-command folder the way
   Claude Code does.

Copilot's instructions file has no folder-based rule system, so unlike the
Cursor integration, this is a one-time summarization rather than a
mirrored file structure — keep it updated manually if `.claude/rules/`
changes materially.

## How to Customize

This toolkit is intentionally generic. Before treating it as "yours":

- **License holder**: `LICENSE` is copyrighted to "Engineering Toolkit
  Contributors" — if you fork this for internal use, update the copyright
  holder to your organization's legal name.
- **`your-org` placeholders**: URLs throughout this README and
  `CHANGELOG.md` use `your-org/engineering-toolkit` as a placeholder GitHub
  path — replace with your actual namespace once published.
- **`.claude/CLAUDE.md`**: add your stack, architecture, and any
  project-specific constraints (see [Quick Start](#quick-start) above).
- **Rules vs. team norms**: `.claude/rules/*.md` and the `docs/` guides
  encode reasonable defaults, not universal law. Where your team has a
  considered, different norm (e.g. a different branching strategy than
  [`docs/branch-strategy.md`](docs/branch-strategy.md) recommends), change
  the doc rather than silently ignoring it — a toolkit that doesn't match
  reality is worse than no toolkit.
- **Prune what you don't need.** A five-person startup doesn't need the
  full RFC process in [`docs/rfc-process.md`](docs/rfc-process.md) on day
  one. Delete or mark folders as "not yet adopted" rather than leaving
  unused process to create false expectations.

## Contribution Guide

Contributions to improve this toolkit itself (not just consume it) are
welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md) for branching, commit
conventions, what makes a good addition, and how to validate changes before
opening a PR. Participation is governed by the
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](LICENSE). You are free to copy, modify,
and redistribute this toolkit, including in proprietary projects, with
attribution preserved per the license terms.
