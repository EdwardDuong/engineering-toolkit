# Cleanup Pass — 2026-07-11

**Trigger:** a follow-up request to [`docs/audit/repository-audit.md`](../audit/repository-audit.md) asking for a credibility-focused cleanup — deletion or consolidation of duplicate documents, generic tutorials, AI-generated filler, repeated best-practice explanations, and content that doesn't help engineers make decisions, subject to two hard constraints: do not delete valuable engineering knowledge, and prefer fewer high-quality documents over many shallow ones.

**Outcome: zero deletions, zero merges.** Every candidate examined turned out to be intentionally differentiated content, not redundancy. This document records what was checked and why each candidate was kept, so the absence of changes is verifiable rather than a claim taken on faith.

## Why this audit didn't start from a blank slate

[`docs/audit/repository-audit.md`](../audit/repository-audit.md) had already run a corpus-wide scan for AI-boilerplate phrasing (found one incidental, non-filler hit across the entire repository) and for templated/repeated opening sentences across all 37 `docs/` files (found zero repetition), and concluded explicitly: *"Delete candidates: none identified... there is no dead weight, no stub, no duplicate-in-substance file to remove."* This cleanup pass re-tested that conclusion by targeting the specific categories requested — duplication, generic tutorials, filler, repeated explanations, non-decision-relevant content — rather than re-running the same general scan.

## Candidates examined

Each of the following was chosen because it was the *most likely* place this repository would have redundancy, given how it was built (eight parallel content-generation passes against a shared manifest, which structurally risks two agents covering adjacent ground without realizing it).

### 1. The four governance docs sitting closest in scope

`docs/decision-making.md`, `docs/architecture-review.md`, `docs/rfc-process.md`, `docs/adr-guide.md` — flagged by the prior audit as "close together in scope" and the single most plausible merge candidate in the repository. Read in full.

**Finding:** each answers a distinct question in the same decision's lifecycle, and each is explicit about the boundary:
- `decision-making.md` — *who* decides and *when* escalation applies (the reversibility framework: two-way door vs. one-way door).
- `architecture-review.md` — *when* a review gate triggers and *what* reviewers evaluate (a process, not a document format).
- `rfc-process.md` — how a proposal is drafted and debated *before* a decision is finalized (a specific document's lifecycle: draft → review → accepted/rejected → implemented).
- `adr-guide.md` — how a decision is recorded *after* it's made, including the immutability discipline (supersede, don't edit) that has no equivalent in the other three.

Each doc cross-references the others precisely at the point where the reader's question shifts (e.g., `rfc-process.md`'s "Relationship to ADRs" section explains exactly where one ends and the other begins) rather than restating the neighboring content. **Kept as four separate documents.**

### 2. `.claude/rules/` vs. `docs/` principle guides

Compared `.claude/rules/no-unnecessary-abstractions.md` against `docs/yagni-principle.md` and `docs/kiss-principle.md` — the pairing most likely to be a machine-facing copy of a human-facing doc.

**Finding:** the rule file is a short (62-line), directive, actionable version — a "rule of three" heuristic and a self-check question ("if I deleted this, would anything be worse today?"). The docs are longer (65–84 lines) prose treatments covering *why* the principle holds, where it interacts with other principles (YAGNI vs. architecture-first), and a worked contrast (simple vs. simplistic vs. over-engineered). `docs/yagni-principle.md` explicitly labels the rule file as its "Machine-enforced version" in its own closing section. **Kept as-is** — this is a deliberate two-tier design (short directive + long rationale), not duplication.

### 3. `.claude/commands/` vs. `prompts/`

Compared `.claude/commands/implement-feature.md` against `prompts/implement-feature.md` — the pairing most likely to be the same content pasted into two formats.

**Finding:** the command is a terse, numbered procedure written for Claude Code specifically (YAML frontmatter, `$ARGUMENTS` substitution, direct file-path references like `.claude/rules/architecture-first.md` that only resolve inside this toolkit). The prompt is a portable, standalone `{{placeholder}}`-based block designed to work when pasted into *any* AI assistant, including ones with no access to this repository's file structure. The command's closing line explicitly defers detail to the prompt ("consult that file... if you need more detail on any step") instead of re-explaining it. **Kept as two separate files** — they serve different delivery mechanisms and audiences, confirmed by re-reading both in full rather than comparing headlines.

### 4. Template-embedded checklists vs. standalone checklists

Checked whether `templates/pull-request.md`'s "Checklist" section duplicates `checklists/before-pull-request.md`.

**Finding:** the template's checklist section is three lines — a pointer to the full checklist plus two PR-specific spot-checks (scoped-and-sized, docs updated) that aren't in the standalone checklist at all. **No change** — this is a correct summary-with-pointer pattern, not an inlined copy.

### 5. A widely-tutorialized topic, as the highest-risk case for generic AI filler

`docs/solid-principles.md` was read in full on the theory that SOLID — heavily covered in generic programming tutorials everywhere — is the single topic in this repository most likely to have been written as textbook restatement rather than decision-relevant guidance.

**Finding:** every principle states a concrete *threshold* for when to apply it, not just a definition — e.g., Open/Closed Principle: "the threshold for applying OCP is evidence: you've already added two or three variants and each one required editing the same conditional. Apply it retroactively once that pattern shows up, not preemptively for a single case." The doc explicitly cross-links to `yagni-principle.md` to guard against overapplying OCP as speculative generality, and closes with a section connecting all five principles to non-OOP contexts (services, APIs, message schemas) rather than stopping at class-based examples. **Kept, unmodified** — this is exactly the "helps engineers make decisions" bar the cleanup request asked to protect, not the genericity it asked to remove.

### 6. Exact-duplicate checklist items across all 13 checklists

Ran an automated check (`grep -h "^- \[ \]" checklists/*.md | sort | uniq -c`) for checklist bullet lines repeated verbatim across different checklist files — the most objective, least-judgment-dependent test available for copy-paste duplication.

**Finding:** zero identical lines across any pair of checklists. `checklists/before-commit.md`, `checklists/before-push.md`, `checklists/before-pull-request.md`, and `checklists/before-merge.md` all touch on "tests," but each phrases and scopes it differently for what's actually being verified at that specific gate (tests pass locally vs. the full suite was run vs. tests were added for new behavior vs. CI is green on the current commit) — progressive verification at different lifecycle stages, not repeated content. **No change.**

## What this cleanup pass did not do, and why

It did not touch the three small, already-identified issues from [`docs/audit/repository-audit.md`](../audit/repository-audit.md)'s Rewrite Candidates section (the dangling `CODEOWNERS` reference in `CODE_OF_CONDUCT.md`, the placeholder-marker linter's precision gap, and the missing disambiguating sentence in `docs/engineering-playbook.md` Phase 3). Those are factual-accuracy and tooling fixes, not instances of the duplicate/filler/generic-tutorial content this cleanup pass was scoped to find — they remain open items on the v2 roadmap in the audit document, tracked separately so this record stays focused on what it actually covers.

## Summary

| Category requested | Instances found | Action |
|---|---|---|
| Duplicate documents | 0 | None |
| Generic tutorials | 0 | None |
| Obvious AI-generated filler | 0 (reconfirms the audit's corpus-wide scan) | None |
| Repeated best-practice explanations | 0 (verified via exact-match checklist scan + close reading of the highest-risk pairs) | None |
| Content that doesn't help engineers decide | 0 | None |

**Deleted files:** none.
**Merged files:** none.
**Files changed:** none — this document is the only addition.

The repository's credibility problem, to the extent one exists, is not excess or redundant content — it's the two structural gaps already named in the audit (a broken `CODEOWNERS` reference and untested automation scripts). Padding this record with cosmetic trims to demonstrate activity would itself be the kind of low-substance change this cleanup was meant to guard against.
