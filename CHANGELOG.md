# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](docs/semantic-versioning.md).
Commit messages follow the [Conventional Commits](docs/conventional-commits.md)
convention, which this changelog is derived from.

## [Unreleased]

No unreleased changes yet.

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

[Unreleased]: https://github.com/your-org/engineering-toolkit/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/engineering-toolkit/releases/tag/v1.0.0
