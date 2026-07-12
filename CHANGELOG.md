# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](docs/semantic-versioning.md).
Commit messages follow the [Conventional Commits](docs/conventional-commits.md)
convention, which this changelog is derived from.

## [Unreleased]

No unreleased changes yet.

## [2.0.0] - 2026-07-12

### Changed (breaking)

- **`.claude/commands/`** replaced the prior 6-command set (`implement-feature`,
  `investigate-bug`, `review-pr`, `refactor`, `generate-tests`, `release-prep`)
  with a curated 5: `/plan`, `/implement`, `/review`, `/test`,
  `/security-audit`. Any host project that adopted `v1.0.0`'s command names
  will need to update references to them. Bug-investigation and refactor
  guidance remain available at `prompts/investigate-bug.md` and
  `prompts/refactor-code.md`, referenced directly from
  `.claude/workflows/bug-fix.md` — no capability was dropped, only the
  command surface was re-scoped.
- **`templates/`** renamed and restructured its core decision-record set:
  `adr.md` → `ADR.md`, `bug-report.md` → `BUG_REPORT.md`,
  `pull-request.md` → `PR_TEMPLATE.md`, `postmortem.md` → `POSTMORTEM.md`
  (all `SCREAMING_SNAKE_CASE`, a documented exception to this repo's
  kebab-case convention — see `CONTRIBUTING.md`), plus five new templates:
  `FEATURE_SPEC.md`, `TECHNICAL_DESIGN.md`, `API_DESIGN.md`,
  `DATABASE_CHANGE.md`, `CODE_REVIEW.md`. Any reference to the old template
  paths will need updating.
- **`docs/testing-strategy.md`** moved to `docs/testing/testing-strategy.md`
  as part of a new `docs/testing/` deep-dive folder (`unit-testing.md`,
  `integration-testing.md`, `end-to-end-testing.md`,
  `test-review-checklist.md`).

### Added

- **`.claude/agents/`** — 7 specialized personas (backend-engineer,
  frontend-engineer, database-engineer, devops-engineer, security-engineer,
  architect, reviewer), each with responsibilities, a review checklist,
  decision principles, and common mistakes to avoid.
- **`docs/workflows/`** — the narrative operating model: feature
  development, bug fixes, database changes, API changes, and production
  incidents, end to end. `.claude/workflows/feature-development.md` and
  `bug-fix.md` are the agent-executable counterparts to the first two of
  these; `database-change.md`, `api-change.md`, and `production-incident.md`
  are narrative-only for now — see `docs/reviews/final-review.md`.
- **`docs/security/`** — an application-security deep dive beneath
  `docs/security-guide.md`: security principles, a stage-by-stage secure
  development checklist, authentication/authorization, dependency
  management (supply-chain lens), secrets management, and threat modeling.
  Includes a real finding and fix from this repository's own CI (unpinned
  `actions/checkout`, now pinned to a commit SHA).
- **`docs/audit/`**, **`docs/changelog/`**, and **`docs/reviews/`** —
  this repository's own self-audit, structural-cleanup record, and
  pre-release staff engineer review, kept as dated historical records
  rather than living documents.
- **`.github/CODEOWNERS`** — closes the gap `CODE_OF_CONDUCT.md`'s
  enforcement section referenced since `v1.0.0`.

### Fixed

- Two factual inaccuracies in `README.md` identified in
  `docs/reviews/final-review.md`: an overclaimed 1:1 correspondence between
  `docs/workflows/` and `.claude/workflows/`, and two incorrect file counts
  (both are the correct counts as of this release).

## [1.0.0] - 2026-07-11

### Added

- Initial release of the Engineering Toolkit: a portable, language-agnostic
  set of engineering process docs, templates, checklists, prompts, and
  automation scripts.
- **`docs/`** — engineering playbook and reference guides covering
  architecture, code quality principles (SOLID, KISS, YAGNI, DRY), git
  workflow, testing, security, performance, observability, incident
  response, and decision-making processes (RFCs, ADRs).
- **`templates/`** — ready-to-use Markdown templates for ADRs, RFCs, pull
  requests, bug/feature reports, epics, user stories, runbooks, incident
  reports, postmortems, risk registers, and release notes.
- **`prompts/`** — AI assistant prompts for common engineering workflows:
  feature implementation, bug investigation, code review, security and
  performance review, refactoring, test generation, and release prep.
- **`checklists/`** — gate checklists for the software delivery lifecycle,
  from before-coding through before-release and production readiness.
- **`examples/`** — worked examples of high-quality architecture docs,
  ADRs, API documentation, incident reports, postmortems, and pull
  requests.
- **`scripts/`** — cross-platform (Bash and PowerShell) validation and
  bootstrap scripts for links, Markdown formatting, project bootstrap, and
  release checks.
- **`.claude/`** — Claude Code configuration: `CLAUDE.md` project rules,
  reusable rule files, and slash commands for implementing features,
  investigating bugs, reviewing PRs, refactoring, generating tests, and
  preparing releases.
- **`.github/`** — issue templates, pull request template, and CI
  workflows for Markdown linting and link checking.
- Root-level project governance: `README.md`, `LICENSE` (MIT),
  `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md`.

[Unreleased]: https://github.com/EdwardDuong/engineering-toolkit/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/EdwardDuong/engineering-toolkit/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/EdwardDuong/engineering-toolkit/releases/tag/v1.0.0
