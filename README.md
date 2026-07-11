<p align="center">
  <img src="assets/logo.svg" alt="Engineering Toolkit logo" width="120" />
</p>

<h1 align="center">Engineering Toolkit</h1>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" /></a>
</p>

<p align="center"><strong>An open-source engineering operating system for AI-assisted software development.</strong></p>

## 1. Vision

An AI coding agent is only as good as the judgment it's given. Left to its own defaults, it will
happily generate code with no tests, an unauthorized endpoint, a migration with no rollback plan,
or a PR description that says "fixed the bug" — not because the model is incapable of better, but
because "better" is context it doesn't have unless something supplies it. A senior engineer
supplies that context by instinct, built from years of watching what goes wrong. A repository with
no written standards gives an AI agent nothing to inherit that instinct from.

This toolkit is that context, written down once and consumed by both humans and agents from the
same source of truth. It is not a prompt library and not a linter — it's the layer that makes an AI
coding agent behave like a competent teammate who already knows how your organization ships
software: how a feature gets planned before it's built, what a database migration's rollback plan
has to account for, when a change needs a security audit instead of a glance, and what "done"
actually means. The same documents that train a new human hire train Claude Code's
[`.claude/`](.claude/CLAUDE.md) configuration, because the standard is the standard regardless of
who — or what — is doing the work.

It is deliberately **not** a framework, a CLI, or a service. It has no build step, no runtime, and
no vendor lock-in — plain Markdown that works whether you copy it into an existing repo, vendor it
as a subtree, or read it as a reference while building your own internal standard from scratch.

## 2. Problems Solved

- **Process knowledge lives in one person's head, or nowhere.** A branching strategy, a definition
  of done, an incident postmortem format, an ADR structure — these usually exist as tribal
  knowledge held by whoever's been on the team longest, rebuilt inconsistently every time a new
  repo or a new team spins up, and lost entirely when that person leaves.
- **AI coding agents default to plausible-looking, unvetted output.** Without an explicit standard
  to work from, an agent has no way to know your team requires a regression test before closing a
  bug, that a new endpoint needs an authorization check per resource (not just a login check), or
  that a schema change needs a rollback plan before it ships. It will produce code that compiles
  and looks reasonable — which is a different thing from code that meets your bar.
- **Standards drift silently across repos and teams.** Without a shared, versioned source, two
  teams' "definition of done" diverge over months of independent small decisions, and nobody
  notices until an incident postmortem or a cross-team PR surfaces the mismatch.
- **Every repo re-invents the same artifacts.** An ADR template, a postmortem structure, a PR
  description format, an incident-report template — this is the same handful of documents,
  rebuilt from scratch (usually worse each time) on every new project.
- **Security and testing discipline erodes exactly when velocity increases.** AI-assisted
  development can produce a working diff faster than a human can independently verify it meets a
  security or test-coverage bar — which makes an explicit, consistently-applied standard *more*
  load-bearing under AI assistance, not less.

## 3. Features

| Folder | What it provides |
|---|---|
| [`docs/`](docs/README.md) | 37 reference guides — architecture, clean code (SOLID/KISS/YAGNI/DRY), git workflow, security, performance, observability, incident response, ADRs/RFCs — plus three practitioner-level deep dives: [`docs/testing/`](docs/testing/README.md), [`docs/security/`](docs/security/README.md), and the narrative operating model in [`docs/workflows/`](docs/workflows/README.md) (feature development, bug fixes, database changes, API changes, production incidents). |
| [`templates/`](templates/README.md) | Fill-in-the-blank artifacts: a nine-document decision-record core (`ADR.md`, `FEATURE_SPEC.md`, `TECHNICAL_DESIGN.md`, `API_DESIGN.md`, `DATABASE_CHANGE.md`, `BUG_REPORT.md`, `POSTMORTEM.md`, `PR_TEMPLATE.md`, `CODE_REVIEW.md`) sharing one Context/Problem/Decision/Alternatives/Risks/Validation/Ownership structure, plus RFCs, epics, user stories, runbooks, and release notes. |
| [`prompts/`](prompts/README.md) | 16 portable prompts for implementing features, investigating bugs, reviewing PRs, security/performance review, refactoring, and generating tests — usable with any LLM-based coding assistant, not just Claude Code. |
| [`checklists/`](checklists/README.md) | 13 gate checklists spanning the delivery lifecycle: before coding, before commit, before PR, before merge, before release, production readiness, security review, architecture review. |
| [`examples/`](examples/README.md) | Worked, realistic examples — a full architecture doc, ADR, API doc, incident report, postmortem, PR, and README — built around one continuous fictional scenario, so "good" isn't left to imagination. |
| [`scripts/`](scripts/README.md) | Cross-platform (Bash + PowerShell) automation: link validation, Markdown linting, project bootstrap, and release checks — the same checks this repository's own CI runs. |
| [`.claude/`](.claude/CLAUDE.md) | Claude Code configuration: 10 rules, 5 slash commands, 7 specialized agent personas, and 3 end-to-end workflows that encode this toolkit's standards directly into an AI coding agent's behavior. See [§6](#6-claude-code-integration). |

## 4. Repository Structure

```text
engineering-toolkit/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── CHANGELOG.md                       # Keep a Changelog + SemVer history
├── CONTRIBUTING.md                    # How to contribute to this toolkit
├── CODE_OF_CONDUCT.md                 # Contributor Covenant v2.1
├── SECURITY.md                        # Vulnerability reporting for this repo
├── .editorconfig / .gitattributes / .gitignore
│
├── .github/
│   ├── ISSUE_TEMPLATE/                # Bug report + feature request forms
│   ├── PULL_REQUEST_TEMPLATE/         # PR template for this repo
│   └── workflows/                     # lint.yml, link-check.yml (CI, SHA-pinned actions)
│
├── .claude/                           # Claude Code configuration — see §6
│   ├── CLAUDE.md                      # Project-level instructions, auto-loaded every session
│   ├── rules/                         # 10 non-negotiable rules (architecture, security, readability, ...)
│   ├── commands/                      # /plan /implement /review /test /security-audit
│   ├── agents/                        # backend/frontend/database/devops/security-engineer, architect, reviewer
│   └── workflows/                     # Feature development, bug fix, release — as agent-executable playbooks
│
├── docs/                              # 37 core reference guides, plus:
│   ├── workflows/                     # The operating model — narrative, human-readable versions of .claude/workflows/
│   ├── security/                      # AppSec deep dive: authN/authZ, secrets, dependencies, threat modeling
│   ├── testing/                       # Testing deep dive: unit/integration/e2e, test review
│   ├── audit/                         # This repo's own self-audit
│   └── changelog/                     # Records of structural changes to this toolkit itself
│
├── templates/                         # 23 fill-in-the-blank artifacts (9-doc decision-record core + more)
├── prompts/                           # 16 portable AI prompts, framework-agnostic
├── checklists/                        # 13 lifecycle gate checklists
├── examples/                          # Worked examples built around one running scenario
├── scripts/                           # validate-links, validate-markdown, bootstrap-project, release-check (.sh + .ps1)
└── assets/                            # Logo and static assets
```

Every folder with content has its own `README.md` index — start there when looking for something
specific (e.g. [`docs/README.md`](docs/README.md), [`templates/README.md`](templates/README.md)).

## 5. How to Use in a New Project

Pick the integration method that fits how tightly you want to track updates to this toolkit.

**Option A — Direct copy (simplest).** Best when you want full control and don't need upstream
updates.

```bash
git clone https://github.com/your-org/engineering-toolkit.git /tmp/engineering-toolkit
cp -r /tmp/engineering-toolkit/{docs,templates,prompts,checklists,examples,scripts,.claude} your-project/
```

**Option B — Git subtree (recommended for staying in sync).** Keeps a copy in your repo's history
but lets you pull upstream updates later without submodule complexity for your contributors.

```bash
git remote add engineering-toolkit https://github.com/your-org/engineering-toolkit.git
git subtree add --prefix=engineering-toolkit engineering-toolkit main --squash

# Later, to pull updates:
git subtree pull --prefix=engineering-toolkit engineering-toolkit main --squash
```

**Option C — Git submodule (strict, pinned reference).** Best when multiple repos should reference
the exact same toolkit version. Requires contributors to run an extra `init`/`update` step — subtree
or direct copy is usually the better default unless that pinning is a hard requirement.

```bash
git submodule add https://github.com/your-org/engineering-toolkit.git engineering-toolkit
git submodule update --init --recursive
```

Replace `your-org` with your actual GitHub namespace once this toolkit is published under your
organization.

### After copying, this toolkit is not yet "yours" — customize it

This toolkit is intentionally generic. Before treating it as your team's actual standard:

- **`.claude/CLAUDE.md`** — add your project name, stack, architecture, and any project-specific
  constraints. This toolkit ships no language/framework specifics by design; Claude Code needs to
  know your actual stack to apply the rules correctly.
- **License holder** — `LICENSE` is copyrighted to "Engineering Toolkit Contributors"; if you fork
  this for internal use, update it to your organization's legal name.
- **Rules vs. team norms** — `.claude/rules/*.md` and the `docs/` guides encode reasonable
  defaults, not universal law. Where your team has a considered, different norm (a different
  branching strategy than [`docs/branch-strategy.md`](docs/branch-strategy.md) recommends), change
  the doc rather than silently ignoring it — a toolkit that doesn't match reality is worse than no
  toolkit, because it trains people to distrust it wholesale.
- **Prune what you don't need.** A five-person startup doesn't need the full RFC process in
  [`docs/rfc-process.md`](docs/rfc-process.md) on day one. Delete or mark folders as "not yet
  adopted" rather than leaving unused process to create false expectations. See
  [`docs/engineering-playbook.md`](docs/engineering-playbook.md) for a phased adoption path instead
  of adopting all 37+ docs, 23 templates, and 13 checklists in one sprint.

## 6. Claude Code Integration

[Claude Code](https://docs.claude.com/en/docs/claude-code) is this toolkit's primary, first-class
integration path — it reads this structure with no adaptation required:

1. Copy (or subtree/submodule) `.claude/` into your repository root.
2. Claude Code automatically loads `.claude/CLAUDE.md` as project instructions at the start of
   every session — engineering principles, coding standards, architecture/testing/security/
   documentation expectations, and the review process, all in one place.
3. **Slash commands** in `.claude/commands/` become available immediately, no registration step:
   `/plan` (requirements, assumptions, architecture impact, implementation steps, risks),
   `/implement` (enforces clean code, tests, and docs as one change set),
   `/review` (correctness, maintainability, security, performance),
   `/test` (works out a test strategy before writing tests), and
   `/security-audit` (scored findings with concrete remediations).
4. **Agent personas** in `.claude/agents/` give Claude Code a domain-specific lens — each with its
   own responsibilities, review checklist, decision principles, and common mistakes to avoid:
   [`backend-engineer`](.claude/agents/backend-engineer.md),
   [`frontend-engineer`](.claude/agents/frontend-engineer.md),
   [`database-engineer`](.claude/agents/database-engineer.md),
   [`devops-engineer`](.claude/agents/devops-engineer.md),
   [`security-engineer`](.claude/agents/security-engineer.md),
   [`architect`](.claude/agents/architect.md), and
   [`reviewer`](.claude/agents/reviewer.md). A change spanning multiple domains (an API change with
   a schema migration) uses more than one.
5. **Workflows** in `.claude/workflows/` chain rules, commands, and agents into end-to-end
   playbooks for feature development, bug fixes, and releases — the agent-executable counterparts
   to the narrative documents in [`docs/workflows/`](docs/workflows/README.md).
6. **Rules** in `.claude/rules/` apply at all times regardless of which command or agent is
   active — they're the floor, not situational advice.

No other setup is required.

### Using this toolkit with other AI assistants

The standards aren't Claude-Code-exclusive; `.claude/` is the first-class integration, not the only
one.

- **Cursor** doesn't read `.claude/` natively, but the content translates directly to
  [Project Rules](https://docs.cursor.com/context/rules) (`.cursor/rules/*.mdc`) or a single
  `.cursorrules` file:
  ```bash
  mkdir -p .cursor/rules
  for f in .claude/rules/*.md; do
    name=$(basename "$f" .md)
    { echo "---"; echo "description: ${name//-/ }"; echo "alwaysApply: true"; echo "---"; echo; cat "$f"; } \
      > ".cursor/rules/${name}.mdc"
  done
  ```
  Cursor has no direct equivalent of a slash-command folder; paste the relevant file from
  `prompts/` into chat instead.
- **GitHub Copilot** supports repository-wide instructions via
  [`.github/copilot-instructions.md`](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot).
  Summarize the load-bearing rules into it — Copilot's instructions file works best as a concise
  set of directives, not a full document dump. Start with
  [`architecture-first.md`](.claude/rules/architecture-first.md),
  [`security-awareness.md`](.claude/rules/security-awareness.md), and
  [`readability.md`](.claude/rules/readability.md), and paste `prompts/*.md` files into chat for
  task-specific work.
- **Any other AI assistant**: [`prompts/`](prompts/README.md) is written to be pasted directly into
  any chat-based coding assistant, with `{{placeholder}}` fields and no dependency on this
  repository's file structure being loaded in context.

## 7. Example Workflow

A concrete walkthrough of building a feature with this toolkit and Claude Code, start to finish —
see [`docs/workflows/feature-development.md`](docs/workflows/feature-development.md) for the full
narrative version of this sequence.

```
$ claude
> /plan Add CSV export for account transaction history

Claude Code checks docs/definition-of-ready.md, produces requirements
(acceptance criteria, explicit out-of-scope items), assumptions, an
architecture-impact assessment (this touches an existing service boundary,
no new one — ordinary review, not a full architecture review), an ordered
implementation plan, and a risk table (e.g. "large accounts could time out
the request — mitigate with async job + polling").

> [Review the plan, confirm the approach]

> /implement the approved plan above

Claude Code applies .claude/rules/understand-before-coding.md, checks for
existing export logic before writing new logic, implements in ordered
steps, and — because this touches the API surface — applies the
backend-engineer.md agent lens: every external input validated, the async
job made idempotent-safe, no internal error detail leaked in the response.
Tests and docs are written inline, not deferred.

> /test

Claude Code works out a strategy before generating tests: unit-level
coverage for the CSV formatting logic and size limits, an integration
test against a real (containerized) database for the query itself, and
confirms no e2e test is needed since this doesn't introduce a new
user-facing flow beyond an existing "export" pattern.

> /security-audit

Because this handles account data leaving the system, a dedicated pass
runs: confirms the export is scoped to the requesting user's own account
(not just "authenticated"), checks the async job doesn't leak the file
to any bucket path guessable by another user, and returns a clean
go/no-go against checklists/security-review.md.

> /review

A final structured pass — correctness, maintainability, security,
performance — each finding marked blocking or non-blocking, checked
against checklists/before-pull-request.md before the PR is opened using
templates/PR_TEMPLATE.md.
```

Every step above is a real command in `.claude/commands/`, not illustrative pseudocode — running
this sequence against this repository produces exactly this behavior.

## 8. Contribution Guide

Contributions to improve this toolkit itself (not just consume it) are welcome — see
[`CONTRIBUTING.md`](CONTRIBUTING.md) for branching, commit conventions, what makes a good addition
(language- and framework-agnostic, no vendor lock-in, immediately usable with no placeholder
content), the file-placement convention for each folder, and how to validate changes
(`scripts/validate-links.sh`, `scripts/validate-markdown.sh`) before opening a PR. Participation is
governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## 9. Roadmap

This toolkit tracks its own gaps the same way it asks consumers to track theirs — the items below
come directly from [`docs/audit/repository-audit.md`](docs/audit/repository-audit.md), not from
aspirational planning:

- **`.github/CODEOWNERS`** — referenced by `CODE_OF_CONDUCT.md`'s enforcement section but not yet
  created.
- **Test coverage for `scripts/`** — the validation scripts that gate this repo's own CI have no
  fixture-based regression tests of their own yet; this is the highest-priority item, since it's
  the one piece of actually executable code in the repository.
- **ShellCheck and PSScriptAnalyzer in CI** — static analysis for the Bash/PowerShell scripts,
  consistent with the bar this toolkit sets for consumers' own code.
- **`examples/good-copilot-instructions.md`** — closes the worked-example loop for the third
  AI-assistant integration path documented in [§6](#6-claude-code-integration).
- **A documented review cadence for this toolkit's own content** — so `docs/` doesn't silently go
  stale the way this toolkit warns consumers' documentation can.

Deliberately **not** on this roadmap: an automated release/tagging pipeline. A template repository
with an infrequent, high-review-bar change cadence doesn't justify that complexity — see
[`docs/release-process.md`](docs/release-process.md).

## License

Released under the [MIT License](LICENSE). You are free to copy, modify, and redistribute this
toolkit, including in proprietary projects, with attribution preserved per the license terms.
