# engineering-toolkit — Agent Instructions

This file is auto-loaded by Claude Code whenever it runs inside a project that
includes this toolkit. Read it before doing anything else.

## What this repository is

`engineering-toolkit` is a language-agnostic, framework-agnostic set of
engineering process docs, templates, checklists, and AI prompts. It is
designed to be dropped into any software project — copied in whole, added as
a git submodule, or vendored selectively — to bring senior-engineering-org
norms to that project without requiring a specific stack, build system, or
team structure.

It is not a library and it is not application code. It ships no runtime. Its
"product" is a consistent way of working: the same definition of done, the
same review bar, the same shape of pull request, whether the host project is
a Python monorepo, a Rust CLI, or a TypeScript web app.

The `.claude/` directory (this directory) is the layer that makes the
toolkit *actionable* for Claude Code specifically: rules the agent always
follows, slash commands for common tasks, and workflows that chain multiple
steps together. Everything else in the repo (`docs/`, `checklists/`,
`templates/`, `prompts/`, `examples/`, `scripts/`) is reference material that
these rules, commands, and workflows point into.

## How to behave when this toolkit is present in a host project

When you (Claude Code) are working in a repository that includes this
toolkit, treat it as your engineering operating system for that session:

1. **Load the rules.** Everything in `.claude/rules/` applies to every
   change you make, regardless of language or framework. They are summarized
   below — read the linked file in full before you need it, not after.
2. **Use the commands.** `.claude/commands/` defines slash commands for the
   engineering tasks you're most often asked to do (implement a feature,
   investigate a bug, review a PR, refactor, generate tests, prepare a
   release). Prefer invoking the matching command over improvising the same
   task from scratch — the command encodes the steps this org expects.
3. **Follow the workflows for multi-step work.** `.claude/workflows/` chains
   commands, rules, and checklists into end-to-end playbooks (feature
   development, bug fix, release). If a task spans more than one step listed
   above, check whether a workflow already describes the sequence before
   inventing your own.
4. **Consult `docs/` for standards.** Before making an architectural,
   security, performance, or style decision, check whether `docs/` already
   has a documented standard (e.g. `docs/architecture-principles.md`,
   `docs/security-guide.md`, `docs/testing-strategy.md`). Don't reinvent a
   position the org has already taken.
5. **Run through `checklists/` before key milestones.** There is a checklist
   for each gate in the delivery lifecycle: `checklists/before-coding.md`,
   `checklists/before-commit.md`, `checklists/before-push.md`,
   `checklists/before-pull-request.md`, `checklists/before-merge.md`,
   `checklists/before-release.md`. Walk the relevant checklist explicitly —
   don't just gesture at having considered it.
6. **Use `templates/` when producing artifacts.** ADRs, pull request
   descriptions, incident reports, release notes, and similar artifacts have
   a template in `templates/`. Start from the template rather than
   free-forming the structure.
7. **Adapt, don't ignore.** If the host project has its own `CLAUDE.md` or
   conventions that conflict with this toolkit, the host project's explicit
   instructions win for project-specific details (naming, tooling,
   directory layout), but the underlying engineering norms in this toolkit
   (test discipline, security awareness, tradeoff transparency) still apply
   unless the user explicitly overrides them.

## AI engineering rules

These live in `.claude/rules/` and apply at all times. Each is short and
written to be actionable, not aspirational.

- [architecture-first.md](rules/architecture-first.md) — think through
  architecture and data flow before writing code; size the design effort to
  the change.
- [understand-before-coding.md](rules/understand-before-coding.md) — read
  surrounding code, tests, and docs before modifying anything; verify your
  understanding before acting on it.
- [no-unnecessary-abstractions.md](rules/no-unnecessary-abstractions.md) —
  don't build interfaces, factories, or config layers for a single concrete
  need.
- [no-duplicated-logic.md](rules/no-duplicated-logic.md) — search for
  existing implementations before writing new logic; know when duplication
  is a deliberate tradeoff vs. accumulating debt.
- [tests-and-documentation.md](rules/tests-and-documentation.md) — every
  behavior change ships with updated tests and updated docs in the same
  change set.
- [explain-tradeoffs.md](rules/explain-tradeoffs.md) — state the
  alternatives considered and why this one was chosen for nontrivial
  decisions.
- [readability.md](rules/readability.md) — prefer readable, boring code over
  clever code.
- [backward-compatibility.md](rules/backward-compatibility.md) — evaluate
  whether a change is breaking; deprecate before removing.
- [performance-awareness.md](rules/performance-awareness.md) — consider
  algorithmic complexity and I/O cost, especially in hot paths.
- [security-awareness.md](rules/security-awareness.md) — treat all external
  input as untrusted; never hardcode secrets; flag security-relevant changes
  for extra review.

## Commands and workflows

- `.claude/commands/` — slash commands for individual engineering tasks
  (`/implement-feature`, `/investigate-bug`, `/review-pr`, `/refactor`,
  `/generate-tests`, `/release-prep`). Each command is a self-contained,
  invokable procedure.
- `.claude/workflows/` — narrative playbooks that chain multiple commands,
  rules, and checklists into an end-to-end process
  (`feature-development.md`, `bug-fix.md`, `release.md`). Use these when
  orienting yourself on a task that spans several steps.

## Non-negotiables

- Never skip or disable tests to make a change land faster. A red test is
  signal, not friction.
- Never bypass the guidance in `docs/security-guide.md` or
  `checklists/security-review.md` for a change that touches auth, input
  handling, secrets, dependencies, or data access.
- Always explain tradeoffs for nontrivial decisions — silent choices are not
  acceptable when there was a real alternative.
- Always keep docs in sync with code in the same change set. Documentation
  debt is still debt.
