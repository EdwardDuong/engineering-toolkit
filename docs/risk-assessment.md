# Risk Assessment

Not every change carries the same risk, and treating a one-line config tweak with the same process
weight as a data migration on a production-critical table wastes scrutiny on the former and risks
under-scrutinizing the latter. A lightweight, consistent risk scoring approach lets process scale to
actual risk instead of to how cautious any one person happens to feel that day.

## Likelihood x impact scoring

Score risk along two independent axes, each on a simple scale (e.g., low/medium/high):

- **Likelihood** — how probable is it that something goes wrong with this change? Consider: how
  well-understood is the change, how much of the system does it touch, has something similar caused
  problems before, how much test coverage exists for the affected area.
- **Impact** — if something does go wrong, how bad is the outcome? Consider: how many users or how
  much revenue is affected, is the effect reversible or permanent (data loss vs. a bad UI render),
  does it touch a compliance or safety-relevant area, what's the blast radius if it cascades to
  other systems.

Combine the two into an overall risk level — a simple 3x3 grid (low/medium/high on each axis) is
usually sufficient resolution; more granular numeric scoring rarely improves the decision it's meant
to inform and mostly adds false precision to what's fundamentally a judgment call.

| | Low impact | Medium impact | High impact |
|---|---|---|---|
| **Low likelihood** | Low risk | Low risk | Medium risk |
| **Medium likelihood** | Low risk | Medium risk | High risk |
| **High likelihood** | Medium risk | High risk | High risk |

## When a change needs a formal risk assessment

Most changes don't need an explicit, written risk assessment — the process itself has a cost, and
applying it universally trains people to treat it as a rubber stamp rather than a genuine
evaluation. Trigger a written assessment (using
[`../templates/risk-register.md`](../templates/risk-register.md)) when a change has any of:

- **A plausible high-risk score** on the grid above — high impact combined with anything above low
  likelihood, or high likelihood combined with anything above low impact.
- **Irreversibility** — a schema change that can't be cleanly rolled back, a data deletion, an
  action that can't be undone once taken (see the reversible/irreversible framing in
  [`decision-making.md`](./decision-making.md), which this risk lens feeds directly into).
- **Novel territory** — the first time the team is doing something (a new deployment pattern, a new
  third-party integration, a new data classification being handled) where there's no track record to
  lean on for calibrating likelihood.
- **Regulatory, compliance, or safety relevance** — anything where getting it wrong has consequences
  beyond the engineering organization's own judgment to absorb.
- **Explicit request from architecture or security review** — see
  [`architecture-review.md`](./architecture-review.md) and
  [`../checklists/security-review.md`](../checklists/security-review.md), which may flag a change as
  needing a formal assessment even if it wouldn't have been obviously flagged otherwise.

## What a risk assessment produces

A useful risk assessment is short and decision-oriented, not a lengthy document nobody reads before
approving anyway:

- The specific risk(s) identified, each scored on likelihood and impact.
- The mitigation for each risk that's above "low" — what specifically reduces the likelihood or
  contains the impact (a staged rollout, an additional test, a feature-flagged kill-switch, an extra
  reviewer, a rollback rehearsal).
- The residual risk after mitigation — mitigations rarely eliminate risk entirely, and being
  explicit about what's left helps whoever is approving the change make an informed call rather than
  assuming mitigation means zero risk.
- Who accepts the residual risk — see [`decision-making.md`](./decision-making.md) for who has the
  authority to accept risk at a given level, since accepting a high residual risk on a high-impact
  change usually shouldn't rest with a single individual contributor's judgment alone.

## Calibrating the scoring over time

- Revisit past risk assessments against what actually happened. If a change scored "low likelihood"
  and caused an incident anyway, that's useful calibration data — either the scoring criteria need
  adjustment, or there was a systematic blind spot worth naming (see
  [`root-cause-analysis.md`](./root-cause-analysis.md)).
- Avoid letting risk scores become a bureaucratic checkbox exercise disconnected from the actual
  mitigation decisions. If every change gets scored "medium" regardless of its actual profile, the
  scoring has stopped doing its job of differentiating changes that need extra care from ones that
  don't.

## Relationship to other docs

- [`decision-making.md`](./decision-making.md) — how the reversibility dimension of risk feeds into
  who's authorized to decide.
- [`technical-debt.md`](./technical-debt.md) — deliberately accepted debt is itself a form of
  accepted risk, and should be scored with the same lens.
- [`architecture-review.md`](./architecture-review.md) — architecturally significant changes are
  frequently, though not always, also high-risk changes, and the two review triggers often (but
  don't have to) coincide.
