# engineering-toolkit — Agent Instructions

This file is auto-loaded by Claude Code whenever it runs inside a project that includes this
toolkit. Read it before doing anything else.

## What this repository is

`engineering-toolkit` is a language-agnostic, framework-agnostic set of engineering process docs,
templates, checklists, and AI prompts, designed to be dropped into any software project — copied
in whole, added as a git submodule, or vendored selectively — to bring senior-engineering-org norms
to that project without requiring a specific stack, build system, or team structure.

The `.claude/` directory (this directory) is the layer that makes the toolkit *actionable* for
Claude Code specifically. It is built as an internal engineering platform, not a collection of
generic prompts:

- **`rules/`** — non-negotiable engineering discipline that applies to every change, regardless of
  what command or agent is in use.
- **`commands/`** — the five things engineers actually ask for, as reusable, high-bar slash
  commands: plan, implement, review, test, audit for security.
- **`agents/`** — specialized engineering personas (backend, frontend, database, DevOps, security,
  architecture, review) you switch into when a task calls for that lens, each with its own
  responsibilities, checklist, decision principles, and failure modes — not a generic "act as an
  expert" wrapper.
- **`workflows/`** — narrative playbooks that chain rules, commands, and agents into an end-to-end
  process for the recurring shapes of work (shipping a feature, fixing a bug, cutting a release).

Everything else in the repo (`docs/`, `checklists/`, `templates/`, `prompts/`, `examples/`,
`scripts/`) is reference material that this layer points into. `docs/` explains *why* a standard
exists; `checklists/` are the go/no-go gates; `templates/` are the artifacts you fill in;
`prompts/` are portable versions of this toolkit's task prompts for AI assistants other than
Claude Code. Consult them by name below rather than re-deriving guidance that's already written
down.

## How Claude Code should behave with this toolkit present

Treat this as your engineering operating system for the session — the same way a new senior
engineer would treat a well-run team's internal wiki and style guide, not as optional background
reading:

1. **Default to the relevant command.** If the task is "build X," "fix X," "review this," "what
   tests does this need," or "is this safe to ship," use `/plan`, `/implement`, `/review`, `/test`,
   or `/security-audit` respectively (see [Commands](#commands)) instead of improvising the same
   task from scratch. The command encodes the steps this org expects and won't let you skip one by
   accident.
2. **Adopt the right agent persona for the domain.** A change to a database migration should be
   reasoned about with the judgment in [`agents/database-engineer.md`](agents/database-engineer.md)
   in mind, not generic full-stack intuition. See [Agents](#agents) for the full roster and when
   each applies — including when a task spans more than one (e.g., a feature with both an API
   change and a schema change needs both the backend and database lens).
3. **Follow the workflow for multi-step work.** [`workflows/`](workflows/) chains rules, commands,
   and agents into playbooks for feature development, bug fixes, and releases. Check whether one
   already describes the sequence you're about to improvise.
4. **Apply every rule in [`rules/`](rules/), always**, regardless of which command or agent is
   active — they are the floor, not situational advice.
5. **Consult `docs/` before taking a position** on architecture, security, performance, or style
   that this toolkit has already documented. Don't reinvent a stance the org has already taken.
6. **Use `templates/` when producing artifacts** — ADRs, PR descriptions, incident reports, release
   notes. Start from the template rather than free-forming the structure.
7. **Adapt, don't ignore.** If the host project has its own `CLAUDE.md` or conventions that
   conflict with this toolkit, the host project's explicit instructions win for project-specific
   details (naming, tooling, directory layout), but the underlying discipline in this toolkit
   (test coverage, security review, tradeoff transparency) still applies unless the user explicitly
   overrides it.

## Engineering Principles

- **Understand before you change anything.** Read the surrounding code, its tests, and any
  relevant doc in `docs/` before modifying it. A change made without understanding why the code is
  the way it is tends to remove a constraint someone put there on purpose. See
  [`rules/understand-before-coding.md`](rules/understand-before-coding.md).
- **Architecture is decided deliberately, sized to the change.** A one-line fix needs no design
  discussion; a new service boundary does. See
  [`rules/architecture-first.md`](rules/architecture-first.md) and
  [`docs/architecture-principles.md`](../docs/architecture-principles.md).
- **No abstraction without a second concrete case, no duplicated logic without a reason.** Build
  the smallest correct thing for the requirement in front of you. See
  [`rules/no-unnecessary-abstractions.md`](rules/no-unnecessary-abstractions.md) and
  [`rules/no-duplicated-logic.md`](rules/no-duplicated-logic.md).
- **Every nontrivial decision states its alternatives and why they were rejected.** Silence on
  tradeoffs is not acceptable when a real alternative existed. See
  [`rules/explain-tradeoffs.md`](rules/explain-tradeoffs.md).
- **Backward compatibility is a default, not an accident.** Evaluate whether a change is breaking
  before shipping it; deprecate before removing. See
  [`rules/backward-compatibility.md`](rules/backward-compatibility.md).

## Coding Standards

- **Readability outranks cleverness.** Prefer the boring, obvious implementation over the compact,
  clever one — code is read far more often than it is written, by people (and agents) with less
  context than you have right now. See [`rules/readability.md`](rules/readability.md) and
  [`docs/clean-code.md`](../docs/clean-code.md).
- **Comment the non-obvious why, not the what.** Well-named code already says what it does; a
  comment earns its place only when it captures a constraint, a workaround, or a decision a reader
  couldn't otherwise infer.
- **Match existing patterns in the file and module before introducing a new one.** A new pattern
  needs a stated reason (see explain-tradeoffs above), not just personal preference.
- **Delete dead code and stale comments on sight** when you're already touching the area — don't
  let a change grow to include unrelated cleanup, but don't leave what you notice for later either.

## Architecture Expectations

- Every new system boundary, significant new dependency, or one-way-door decision goes through the
  judgment in [`agents/architect.md`](agents/architect.md) and, if it meets the bar, gets recorded
  per [`docs/adr-guide.md`](../docs/adr-guide.md) — not decided silently in a PR description.
  See [`docs/architecture-review.md`](../docs/architecture-review.md) for the specific triggers.
- Favor explicit boundaries and contracts between components over convenient coupling. See
  [`docs/architecture-principles.md`](../docs/architecture-principles.md).
- Design for the change you can already see coming (see `docs/architecture-principles.md`), not
  for hypothetical future flexibility (see `docs/yagni-principle.md`) — the two are easy to
  conflate and the distinction matters.

## Testing Expectations

- **No behavior change ships without a test that fails without it.** This is not negotiable — see
  [`rules/tests-and-documentation.md`](rules/tests-and-documentation.md).
- Run the full relevant test suite before calling a change done, not just the tests you added. See
  [`docs/testing-strategy.md`](../docs/testing-strategy.md) for the test pyramid and coverage
  philosophy this toolkit expects.
- Use `/test` (see [Commands](#commands)) to reason about test *strategy* — what to cover and at
  what level — before writing tests, not just to generate cases after the fact.

## Security Expectations

- **Treat all external input as untrusted** — this applies to HTTP requests, message payloads,
  file uploads, CLI args, and configuration sourced from outside the process, without exception.
  See [`rules/security-awareness.md`](rules/security-awareness.md).
- **Never hardcode a secret, credential, or token**, even temporarily, even in a comment, even in a
  branch you don't intend to push.
- Any change touching authentication, authorization, input handling, secrets, dependencies, or
  data access runs through `/security-audit` and the judgment in
  [`agents/security-engineer.md`](agents/security-engineer.md) before it ships. See
  [`docs/security-guide.md`](../docs/security-guide.md) and
  [`checklists/security-review.md`](../checklists/security-review.md).

## Documentation Expectations

- **Documentation ships in the same change set as the behavior it describes.** Documentation debt
  is still debt — see [`rules/tests-and-documentation.md`](rules/tests-and-documentation.md).
- Update the README, API docs, and any doc in `docs/` whose guidance the change affects. A change
  that makes a doc inaccurate and doesn't fix it is an incomplete change, not a follow-up.
- Follow [`docs/documentation-standards.md`](../docs/documentation-standards.md) for what needs
  documenting and how.

## Review Process

- Every change is reviewed against [`docs/code-review-guide.md`](../docs/code-review-guide.md) and
  [`checklists/before-pull-request.md`](../checklists/before-pull-request.md) before it's
  presented as done — use `/review` to run this pass, adopting
  [`agents/reviewer.md`](agents/reviewer.md)'s checklist explicitly rather than a general "does
  this look okay" pass.
- State findings by severity (blocking vs. non-blocking) and explain *why* something is a problem,
  not just that it is — the same standard this toolkit expects of human reviewers applies to
  AI-assisted review.
- A change is not done when the code is correct; it's done when it meets
  [`docs/definition-of-done.md`](../docs/definition-of-done.md) — tests, docs, and review included.

## Commands

Five commands cover the engineering lifecycle this toolkit is built around. Each is a
self-contained, invokable procedure — prefer the command over improvising the same task freehand.

| Command | Use it for | Produces |
|---|---|---|
| [`/plan`](commands/plan.md) | Feature planning, before any code is written | Requirements, assumptions, architecture impact, implementation steps, risks |
| [`/implement`](commands/implement.md) | Turning an approved plan into working code | Clean, tested, documented code |
| [`/review`](commands/review.md) | Reviewing a diff before it ships | Correctness, maintainability, security, and performance findings |
| [`/test`](commands/test.md) | Deciding what to test and at what level | A test strategy, then the tests themselves |
| [`/security-audit`](commands/security-audit.md) | Security-focused review of a change or surface | A scored list of findings with concrete remediations |

## Agents

Seven specialized personas, each scoped to a specific engineering domain. Switch personas when the
task calls for that lens — a database migration reasoned about with backend intuition alone misses
class of risk a database-engineer lens catches immediately, and vice versa.

| Agent | Domain |
|---|---|
| [`agents/backend-engineer.md`](agents/backend-engineer.md) | Service logic, APIs, business rules, backend reliability |
| [`agents/frontend-engineer.md`](agents/frontend-engineer.md) | UI architecture, state management, client performance, accessibility |
| [`agents/database-engineer.md`](agents/database-engineer.md) | Schema design, migrations, query performance, data integrity |
| [`agents/devops-engineer.md`](agents/devops-engineer.md) | CI/CD, deployment, infrastructure, observability, release safety |
| [`agents/security-engineer.md`](agents/security-engineer.md) | Threat modeling, vulnerability review, secrets, dependency risk |
| [`agents/architect.md`](agents/architect.md) | System boundaries, cross-team decisions, ADRs/RFCs |
| [`agents/reviewer.md`](agents/reviewer.md) | End-to-end diff review before merge |

A task frequently needs more than one agent's judgment — e.g., a new feature with both an API
change and a schema migration needs the backend-engineer and database-engineer perspectives, and
should still pass through `/review` with the reviewer persona regardless of which specialist(s)
were involved in building it.

## Workflows

[`workflows/`](workflows/) chains rules, commands, and agents into end-to-end playbooks for the
recurring shapes of work:

- [`workflows/feature-development.md`](workflows/feature-development.md) — from an approved
  requirement to a merged, tested, documented change.
- [`workflows/bug-fix.md`](workflows/bug-fix.md) — from a bug report to a merged fix with a
  regression test, including when to escalate to an incident.
- [`workflows/release.md`](workflows/release.md) — from a release-ready `main` to a shipped,
  documented release.

## Non-negotiables

- Never skip or disable a test to make a change land faster. A red test is signal, not friction.
- Never bypass `/security-audit` or the guidance in `docs/security-guide.md` for a change that
  touches auth, input handling, secrets, dependencies, or data access.
- Always explain tradeoffs for nontrivial decisions — silent choices are not acceptable when there
  was a real alternative.
- Always keep docs in sync with code in the same change set. Documentation debt is still debt.
