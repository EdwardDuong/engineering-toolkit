# Release Process

A release turns code that's merged into value that's actually delivered. This doc covers how to
choose a release cadence, the checklist entry point for shipping, and how to plan for the release
going wrong before it does.

## Release cadence models

- **Continuous deployment** — every change that passes CI and review deploys to production
  automatically, typically within minutes of merging to trunk. Lowest lead time, smallest
  per-release blast radius (since each release is a single small change, isolating a regression's
  cause is close to trivial), and requires the most mature automated testing and monitoring to be
  safe — without strong automated verification, continuous deployment just means shipping unverified
  changes faster.
- **Scheduled/batched releases** — changes accumulate on trunk and are released together on a fixed
  cadence (daily, weekly, or per sprint). Easier to coordinate around (a known release window that
  stakeholders, support, and on-call can prepare for) but increases blast radius per release (more
  changes bundled together makes it harder to isolate which change caused a regression) and
  increases lead time (a merged fix waits for the next scheduled window instead of shipping
  immediately).
- **Manual/gated releases** — a release requires explicit sign-off (QA pass, stakeholder approval,
  compliance review) before shipping, regardless of cadence. Appropriate when regulatory,
  contractual, or safety requirements demand a documented approval step — but should be the
  exception applied where genuinely required, not the default, since it adds latency and human
  bottleneck to every release regardless of the actual risk of the specific change.

Choose based on the system's actual risk profile and the team's testing maturity, not by default
inheritance from a previous project. A team with strong automated test coverage and monitoring
should generally lean toward continuous deployment — it reduces risk by making each release smaller,
not just faster. A team without that foundation should invest in the foundation rather than
compensating with heavier manual gates indefinitely; gates are a mitigation for weak automated
verification, not a substitute for building it.

## Release checklist entry point

Every release, regardless of cadence model, should pass through
[`../checklists/before-release.md`](../checklists/before-release.md) before going out. That
checklist is the single source of truth for release-gating criteria (tests passing, changelog
updated, rollback plan confirmed, stakeholders notified where required) — this doc explains the
reasoning behind the process; the checklist is what actually gets executed.

For releases significant enough to warrant it (a major version, a change to a critical system,
anything following the [`risk-assessment.md`](./risk-assessment.md) criteria for elevated risk),
also run through [`../checklists/production-readiness.md`](../checklists/production-readiness.md).

## Staged rollout

Even within a chosen cadence model, prefer rolling a release out progressively rather than to 100%
of traffic/users instantly, whenever the platform supports it:

- Deploy to a small percentage of traffic or a canary environment first, and watch the SLIs defined
  in [`observability-guide.md`](./observability-guide.md) before continuing.
- Expand progressively (e.g., canary → 25% → 100%) with an explicit bake time at each stage, rather
  than jumping straight to full traffic once the canary looks clean for a few minutes — some
  regressions only manifest under load or after enough time has passed for a slow leak to show up.
- Automate the promotion/rollback decision where possible, based on the same SLO thresholds used for
  alerting — a human watching a dashboard for the entire rollout window doesn't scale and is prone
  to missing a slow-building regression that an automated threshold would catch immediately.

## Rollback strategy

A release without a pre-planned rollback path is a bet, not a release.

- **Every release should have a known, tested way to revert** before it ships — not a rollback plan
  improvised for the first time during an active incident. See
  [`../templates/runbook.md`](../templates/runbook.md) for documenting the rollback procedure for a
  given system.
- **Prefer rollback mechanisms that don't depend on a fresh deploy**, since the deploy pipeline
  itself may be part of what's degraded during an incident — a feature flag kill-switch (see
  [`configuration-management.md`](./configuration-management.md)) or a one-command
  revert-to-previous-artifact are faster and more reliable under pressure than re-running a full
  build-and-deploy pipeline.
- **Understand what rollback does and doesn't undo.** Rolling back code doesn't roll back a
  completed data migration or a message already sent to an external system — plan the
  schema/migration strategy so that the previous version of the code can still run correctly against
  the current schema (see the expand-contract pattern in
  [`database-guidelines.md`](./database-guidelines.md)). A release that isn't safely
  rollback-compatible needs a different, explicit mitigation plan, decided before shipping, not
  discovered while trying to roll back.
- **Practice rollback, don't just document it.** A rollback procedure that's never been executed
  outside of an actual emergency carries meaningful risk of having silently drifted out of date or
  containing an untested assumption — periodically exercise it (e.g., as part of a game day) the
  same way you'd test a backup restore.

## When a release goes wrong

If a release causes a production issue, follow [`incident-response.md`](./incident-response.md) for
the immediate response, and [`postmortem-guide.md`](./postmortem-guide.md) afterward to understand
what let it through the release process undetected — treat every release-caused incident as a signal
to strengthen the checklist or the automated gates that should have caught it, not as an isolated,
unlucky event.
