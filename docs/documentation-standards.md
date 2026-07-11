# Documentation Standards

Undocumented behavior is a liability that compounds: every engineer who touches the code again has
to re-derive intent that someone already had and lost. This doc defines what must be documented,
how, and how documentation stays trustworthy over time.

## What must be documented

Not everything needs documentation — code that's genuinely self-explanatory doesn't need a paragraph
restating it (see [`clean-code.md`](./clean-code.md) on comment philosophy). These categories always
do:

- **Public interfaces** — any API, library function, CLI, or configuration surface consumed by
  another team, another service, or an external user. If you can't see every caller, document it as
  if a stranger will read it. See [`api-design-guide.md`](./api-design-guide.md).
- **Architecture decisions** — anything that changes a system boundary, introduces a new dependency,
  or would confuse a future engineer asking "why is it built this way." See
  [`adr-guide.md`](./adr-guide.md).
- **Runbooks for operational procedures** — anything an on-call engineer needs to do under time
  pressure (restart a service, roll back a deploy, rotate a credential) belongs in
  `../templates/runbook.md`, not in someone's memory or a Slack thread.
- **Non-obvious setup and local development steps** — anything a new engineer needs that isn't
  discoverable by reading the code (environment variables, required local services, a specific tool
  version).
- **Deliberate deviations from this toolkit's defaults** — if a team adopts a non-default threshold,
  process, or exception to a documented standard, that deviation itself needs a record (typically an
  ADR) so it isn't mistaken for an oversight later.

What does *not* need a dedicated doc: internal implementation detail that's fully visible by reading
the code, and anything that would go stale faster than it would be re-read (avoid documenting exact
line numbers or internal variable names, for example).

## Doc-as-code principles

Documentation that lives outside the codebase drifts from it silently, because nothing forces the
two to change together. This toolkit treats docs as a build artifact of the same process as code:

- **Docs live in the same repository as the code they describe**, versioned alongside it. A doc
  describing a v2 API should be readable at the git ref that has the v2 API, and not before.
- **Docs go through the same review process as code.** A PR that changes documented behavior should
  update the doc in the same PR — see
  [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md). A reviewer should
  treat an undocumented behavior change as incomplete work, not a follow-up.
- **Docs use plain text formats (Markdown) that diff cleanly** in version control, rather than
  binary or externally-hosted formats that can't be reviewed as part of a code change.
- **Prefer docs adjacent to the code they describe** — a README next to the module it documents,
  inline doc-comments on a public function — over a single monolithic wiki that nobody remembers to
  check when they touch the code.

## Keeping documentation adjacent to code

- Directory-level READMEs for any component whose purpose isn't obvious from its name and file
  listing alone.
- Doc comments on every public function, type, and API endpoint — parameters, return values, error
  conditions, and any non-obvious behavior (idempotency, side effects, ordering requirements).
- Configuration options documented where they're defined (a comment or accompanying doc next to the
  schema/defaults file), not only in a separate ops wiki that can drift out of sync with what the
  code actually reads.
- Architecture-level docs (system diagrams, service ownership) belong in this `docs/` folder or its
  equivalent, cross-linked from the READMEs of the components they describe.

## Review cadence for stale docs

Documentation rot is the default outcome unless something actively fights it:

- **Tie doc updates to the change that invalidates them.** The PR that changes behavior is
  responsible for updating the doc describing that behavior — this is far cheaper than a later audit
  trying to reconstruct what changed.
- **Schedule a periodic doc audit** (quarterly is a reasonable default) for high-traffic docs —
  onboarding guides, architecture overviews, runbooks — specifically checking for claims that no
  longer match the system. Assign an owner per doc or per area; a doc with no owner is a doc nobody
  will notice going stale.
- **Treat a runbook that fails during an actual incident as a bug**, not a footnote — file it and
  fix it as part of the postmortem action items (see
  [`postmortem-guide.md`](./postmortem-guide.md)), since a runbook that doesn't work when needed is
  worse than no runbook (it costs time during the incident before someone realizes it's wrong).
- **Delete stale docs rather than leaving them "just in case."** An outdated doc that's still
  discoverable actively misleads; deleting it and relying on the git history to recover it if ever
  needed is safer than leaving misinformation live.

## Format and structure conventions

- Use `##` headings consistently within a doc so tools that build a table of contents render
  correctly.
- Keep each doc self-contained: a reader should be able to open exactly one doc and get value, with
  cross-links for related context rather than requiring several docs open at once to make sense of
  any one of them.
- Prefer concrete examples over abstract description wherever the concept has a natural example —
  see the worked examples in `../examples/`.
- Avoid marketing language, hedging, or filler ("this is a very important step!"). State the
  guidance and the rationale plainly.
