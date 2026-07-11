# Repository Audit — Engineering Toolkit

**Audit date:** 2026-07-11
**Auditor:** Automated engineering audit (Claude), read-only review
**Scope:** Full repository as of commit `891bfeb` ("feat: initial production-ready engineering toolkit"), 142 tracked files across `README.md`, `.github/`, `.claude/`, `docs/`, `templates/`, `prompts/`, `checklists/`, `examples/`, `scripts/`, `assets/`.
**Method:** Automated link/markdown validation (`scripts/validate-links.sh`, `scripts/validate-markdown.sh`, `scripts/repository-audit.sh`), a corpus-wide scan for AI-generated boilerplate phrasing and formulaic repetition, and close reading of a representative sample across every folder (root governance docs, `.claude/CLAUDE.md`, `docs/engineering-playbook.md`, `templates/adr.md`, `checklists/before-merge.md`, `prompts/root-cause-analysis.md`, `examples/good-postmortem.md`, `.github/workflows/*.yml`). No file was modified as part of this audit except the creation of this document.

---

## Executive Summary

This repository is substantially above the bar for a typical "AI-generated documentation dump." The content is specific, opinionated, internally consistent, and consequential — it reads like it was written by someone who has actually run an incident review or rejected a premature ADR, not like a restatement of Wikipedia definitions. Cross-linking between `docs/`, `templates/`, `checklists/`, `prompts/`, and `examples/` is deliberate and (after one fix applied during this audit) fully intact: all 557 relative links in the repository resolve.

The repository was built by eight parallel content-generation passes against a shared file manifest, then reconciled by a human-directed consistency pass (commit `891bfeb`). That process left one real defect (a filename collision between `templates/README.md` and `templates/readme.md` on this case-insensitive filesystem, resolved by renaming to `templates/project-readme.md` and repairing two stale cross-references) and one documented false-positive class in the markdown linter (nine legitimate uses of the words "TODO" / "Coming Soon" inside prose *about* those anti-patterns, not actual placeholder content). Both are called out below rather than swept under the rug.

The most significant real gap is that **the repository's one piece of actually executable content — `scripts/*.sh` and `scripts/*.ps1` — has no automated test coverage or static analysis of its own**, despite gating CI for every consumer of this toolkit. A second gap: `CODE_OF_CONDUCT.md` points enforcement contact at a `CODEOWNERS` file that does not exist in the repository. Neither is a content-quality problem; both are structural completeness gaps a v2 pass should close before this is handed to outside contributors.

## Current Score: 8.5 / 10

**Rationale:** Content depth, specificity, and cross-referencing integrity are at or above the standard of a well-run internal platform team's wiki — genuinely rare for a repository of this size built in a single pass. The score is not higher because of two categories of unfinished work: (1) the executable scripts are unverified by anything other than one-time manual smoke-testing reported by the agent that wrote them, and (2) a handful of structural loose ends (missing `CODEOWNERS`, no self-review cadence for the toolkit's own docs) mean this is "ready to publish and use" but not yet "ready to onboard external contributors at scale" without a short follow-up pass.

## Strengths

- **Specificity over genericity.** `examples/good-postmortem.md` names a concrete failure mode (TLS handshake failures against pooled SMTP connections after a provider certificate rotation) with a real five-whys chain that bottoms out in an organizational cause (an inherited retry-policy default nobody reviewed), not a generic "communication could be improved." This pattern holds across the sampled files — `docs/engineering-playbook.md`'s phased-adoption plan gives concrete triggers for introducing each phase ("write the incident response process after the first real incident makes clear nobody knew who was in charge, not speculatively beforehand") rather than a generic maturity ladder.
- **Zero AI-boilerplate tells.** A corpus-wide scan for common generated-content markers ("it's worth noting," "in today's fast-paced environment," "leverage," "seamlessly," "robust and scalable," "delve into," "game-changer") returned one incidental hit, and it was a legitimate use of "highest-leverage" as an engineering term, not filler. A check of opening sentences across all 37 `docs/` files found zero repeated or templated openings — each document leads with a distinct, substantive claim.
- **Working cross-reference graph.** 557 relative Markdown links across the repository resolve correctly (verified via `scripts/validate-links.sh` after this audit's one fix). Docs point to templates, templates point to worked examples, checklists point to the docs that justify each line item, and `.claude/rules/` summarizes-and-links rather than duplicating `docs/` content wholesale.
- **Language/framework neutrality is actually maintained**, not just claimed. No sampled file assumes a specific language, package manager, or cloud vendor as a requirement; illustrative examples (e.g., "a Postgres-like relational store") are clearly framed as illustrative.
- **The adoption story is realistic.** `docs/engineering-playbook.md` explicitly warns against adopting all 37 docs at once and gives a five-phase rollout tied to team size and pain signals rather than a calendar. This is the kind of guidance that only shows up when someone has actually watched a process rollout fail from being too much, too soon.
- **AI-assistant integration is genuinely three-way**, not Claude-only with Cursor/Copilot as an afterthought — the README gives a working shell snippet to mirror `.claude/rules/` into Cursor's `.mdc` format and concrete, honest guidance on Copilot's more limited single-file model, including where the analogy breaks down (no folder-based slash commands).
- **Governance artifacts are tailored, not templated.** `SECURITY.md` correctly scopes itself to what's actually risky in a documentation-and-scripts repo (malicious scripts, unsafe CI workflows) rather than copy-pasting a SaaS-product security policy; `CONTRIBUTING.md`'s file-placement table and validation-before-PR instructions are specific to this repo's actual structure.

## Weaknesses

1. **No test coverage for `scripts/*.sh` / `scripts/*.ps1`.** These scripts are wired into `.github/workflows/lint.yml` and `link-check.yml` as the actual CI gate for every future contribution, but there is no fixture-based regression test (e.g., a small directory with a known-broken link and a known-good one) proving `validate-links.sh` and its PowerShell twin keep agreeing with each other as they evolve. The building agent reported manual smoke-testing, which is not repeatable or CI-enforced.
2. **No static analysis on the scripts themselves.** Nothing in `.github/workflows/` runs ShellCheck or PSScriptAnalyzer. For a repo whose only executable surface is ~1,440 lines of Bash/PowerShell that consumers are told to run in their own environments (per `SECURITY.md`'s own advice to "review scripts... before running them"), shipping without self-linting is inconsistent with the bar the toolkit sets for everyone else.
3. **`CODE_OF_CONDUCT.md` references a `CODEOWNERS` file that does not exist.** Line 63 directs enforcement reports to "the maintainers listed in the repository's `CODEOWNERS` file," but no `.github/CODEOWNERS` or root `CODEOWNERS` was created. This is a real broken reference — it wasn't caught by `validate-links.sh` because it's prose, not a Markdown link.
4. **The parallel-generation process left one filesystem-fragility defect.** `templates/readme.md` (a generic project-README template) and `templates/README.md` (the folder's index) collided on this case-insensitive filesystem; the second write silently overwrote the first. It was caught and fixed (renamed to `templates/project-readme.md`, two stale references in `examples/` repaired) as part of this audit's final consistency pass, but it's worth naming explicitly: any future addition to `templates/`, `docs/`, or elsewhere must avoid a same-name-different-case collision with that folder's own `README.md`, since Windows/macOS default filesystems won't catch it locally the way Linux CI would.
5. **`validate-markdown.sh`'s placeholder-content check has a precision gap.** It correctly enforces "no leftover TODO/Coming Soon/Lorem Ipsum," but does a naive string match with no awareness of prose *discussing* those terms as concepts. Nine violations across five files (`CONTRIBUTING.md`, `docs/clean-code.md`, `docs/technical-debt.md`, `checklists/before-commit.md`, the PR template) trip this check legitimately — every hit was manually verified during this audit to be intentional, correct content (e.g., "TODO comments are allowed only if they reference an owner"). This document you're reading now trips the same false-positive class for the same reason (it discusses the markers by name in this very paragraph), bringing the live count to sixteen violations across six files — which is itself the clearest demonstration that the heuristic needs the fix recommended below rather than the content needing to change. This doesn't block anything today since the check isn't currently wired to fail a human-reviewed merge, but if `lint.yml` is ever made a hard-required check, these will need either an inline suppression convention or a smarter heuristic (e.g., only flag the marker at the start of a line or inside a raw code comment).
6. **No review-cadence policy for the toolkit's own content.** `docs/documentation-standards.md` recommends a staleness-review cadence for *consumers'* documentation, but `CONTRIBUTING.md` doesn't say how often this repository's own 37 docs get re-validated against reality (e.g., does `docs/engineering-metrics.md`'s DORA-metrics guidance get revisited as industry practice shifts?). Minor, but the toolkit should dogfood its own advice.
7. **Four governance docs sit close together in scope** (`decision-making.md`, `architecture-review.md`, `rfc-process.md`, `adr-guide.md`) — each is individually justified (who decides / when review happens / a document's lifecycle / a decision's permanent record, respectively) and none is redundant on close reading, but a small team adopting this toolkit may need `docs/engineering-playbook.md`'s Phase 3 framing to understand why there are four separate entry points here rather than one. Not a defect; worth a forward-pointer in that phase's description so it doesn't read as sprawl at first glance.
8. **No shipped starter file for GitHub Copilot.** The README explains, correctly, how to hand-summarize `.claude/rules/` into `.github/copilot-instructions.md`, but (reasonably, since it's stack-specific) doesn't ship an example. A `docs/audit`-adjacent `examples/good-copilot-instructions.md` would close the loop the way `examples/` already does for READMEs, ADRs, and PRs.

## Delete Candidates

**None identified.** Every file sampled and every file's presence in its folder's index earns its place — there is no dead weight, no stub, no duplicate-in-substance file to remove. `scripts/repository-audit.sh` independently confirms this structurally: zero empty directories, zero markdown files under 5 lines, zero orphaned or stub content. This is a meaningfully different (and better) finding than "no obvious deletions" — an explicit corpus-wide check ran and came back clean.

## Rewrite Candidates

- **`CODE_OF_CONDUCT.md` (enforcement section, ~line 63):** either create `.github/CODEOWNERS` and let the reference stand, or soften the reference to not assume a file that doesn't exist yet (e.g., "contact a maintainer via a private security advisory" until `CODEOWNERS` exists). Small, high-value fix.
- **`scripts/validate-markdown.sh` / `.ps1` (placeholder-marker check):** tighten the heuristic so it doesn't flag prose discussing "TODO"/"Coming Soon" as concepts — e.g., only flag the literal patterns `TODO:`/`TODO(` at the start of a trimmed line or inside a fenced code block meant to represent source code, which is where a *real* leftover placeholder would actually appear.
- **`docs/engineering-playbook.md` (Phase 3 section):** add one sentence distinguishing `decision-making.md` / `architecture-review.md` / `rfc-process.md` / `adr-guide.md` from each other up front, since a reader hitting all four in one phase may not immediately see why they're not overlapping.

No file requires a full rewrite. The above are targeted, small edits to already-strong documents.

## Missing Components

Ranked by how much they'd reduce real risk or friction for the first external contributor:

1. **`.github/CODEOWNERS`** — referenced by `CODE_OF_CONDUCT.md` but absent; also would let GitHub auto-request the right reviewers on PRs touching specific folders.
2. **A test fixture suite for `scripts/`** — e.g. `scripts/tests/` with a tiny sample tree containing one intentionally broken link and one intentionally malformed heading, run in CI to prove `validate-links.sh`/`.ps1` and `validate-markdown.sh`/`.ps1` still agree and still catch real problems as they're modified over time.
3. **ShellCheck + PSScriptAnalyzer CI job** — self-linting the one executable surface in the repo, consistent with the bar `docs/security-guide.md` and `checklists/security-review.md` set for everyone else.
4. **`examples/good-copilot-instructions.md`** — closes the worked-example loop for the third AI-assistant integration path the README documents.
5. **A doc-staleness review cadence**, stated in `CONTRIBUTING.md` (e.g., "each doc's last-reviewed date is tracked; docs untouched for 12 months get a lightweight accuracy pass").

## Recommended v2 Roadmap

**Milestone 1 — Close the structural gaps (fast, low-risk):**
- Add `.github/CODEOWNERS` and fix the `CODE_OF_CONDUCT.md` reference to match.
- Tighten `validate-markdown.sh`/`.ps1`'s placeholder-marker heuristic to eliminate the nine known false positives.
- Add the one-sentence disambiguation to `docs/engineering-playbook.md` Phase 3.

**Milestone 2 — Make the scripts trustworthy, not just tested-once (highest engineering-risk item in the repo):**
- Add a minimal fixture-based test suite under `scripts/tests/` covering all five script pairs.
- Wire ShellCheck (Bash) and PSScriptAnalyzer (PowerShell) into `.github/workflows/lint.yml` as a new job, scoped to `scripts/`.
- Once both are green, consider making `lint.yml` and `link-check.yml` required status checks on the default branch (they are not currently marked as required anywhere in this repo, since no branch protection config is version-controlled here — that's a GitHub repo setting, not a file, and out of this audit's file-only scope).

**Milestone 3 — Complete the AI-assistant integration story:**
- Add `examples/good-copilot-instructions.md`.
- Consider a `scripts/generate-cursor-rules.sh` that turns the README's manual bash snippet for mirroring `.claude/rules/` into `.cursor/rules/*.mdc` into a first-class, tested script, matching the level of polish `bootstrap-project.sh` already gives the direct-copy integration path.

**Milestone 4 — Dogfood the toolkit on itself:**
- Add a doc-staleness review cadence to `CONTRIBUTING.md`.
- Once this repository has taken a few real external contributions, retroactively write an ADR (using `templates/adr.md`) for any non-obvious structural decision made during this initial build (e.g., "why eight content-generation passes instead of one," "why kebab-case everywhere") — not because it's needed today, but because `docs/adr-guide.md`'s own advice is that decisions worth explaining should be recorded once, not re-explained from memory later.

**Explicitly not recommended for v2:** don't add a CI job that cuts GitHub Releases or tags automatically. `docs/release-process.md` and the "no vendor lock-in" principle in `CONTRIBUTING.md` both argue for a deliberately manual release process for a template repository with infrequent, high-review-bar changes — automating that would add complexity this repo's actual release cadence doesn't justify.
