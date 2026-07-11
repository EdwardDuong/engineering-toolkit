# Application Security

[`../security-guide.md`](../security-guide.md) states this toolkit's security principles and
vulnerability-class overview in a page. This folder is the deeper, practitioner-level layer beneath
it — written from the perspective of an application security engineer reviewing real systems, not
a general awareness primer. Each document follows the same shape: common vulnerabilities, review
questions, worked examples, and prevention strategies, so once you know how to use one you know how
to use all of them.

| Doc | Focus |
|---|---|
| [`security-principles.md`](security-principles.md) | The AppSec mental model underneath the specific topics below — risk-based thinking, attacker framing, and the recurring shapes security failures take. |
| [`secure-development-checklist.md`](secure-development-checklist.md) | A practical, stage-by-stage checklist spanning design through post-deploy — broader than the single pre-release gate in [`../../checklists/security-review.md`](../../checklists/security-review.md). |
| [`authentication-and-authorization.md`](authentication-and-authorization.md) | AuthN vs. AuthZ, credential storage, session management, and the IDOR/broken-access-control pattern responsible for most real-world authorization bugs. |
| [`dependency-management.md`](dependency-management.md) | The supply-chain-attack lens on third-party dependencies — distinct from [`../dependency-management.md`](../dependency-management.md)'s broader lifecycle guidance — including a real finding and fix from this repository's own CI. |
| [`secrets-management.md`](secrets-management.md) | How credentials actually get committed by accident, why removing one from history isn't sufficient, and what prevention and response look like in practice. |
| [`threat-modeling.md`](threat-modeling.md) | When the lightweight four-question model in [`../security-guide.md`](../security-guide.md) is enough, when to escalate to a structured STRIDE pass, and a fully worked example. |

## How this folder fits the rest of the toolkit

- Every document here cross-links to the checklist, template, agent, or command that operationalizes
  it — [`../../checklists/security-review.md`](../../checklists/security-review.md),
  [`../../.claude/agents/security-engineer.md`](../../.claude/agents/security-engineer.md),
  [`../../.claude/commands/security-audit.md`](../../.claude/commands/security-audit.md), and
  [`../../templates/API_DESIGN.md`](../../templates/API_DESIGN.md) /
  [`../../templates/TECHNICAL_DESIGN.md`](../../templates/TECHNICAL_DESIGN.md) for where a threat
  model or security review gets recorded.
- [`../workflows/api-change.md`](../workflows/api-change.md) and
  [`../workflows/database-change.md`](../workflows/database-change.md) both point back here for the
  security dimension of those specific change types.
- None of these documents assume a specific language, framework, or cloud provider — examples use
  illustrative pseudocode, consistent with the rest of this toolkit.
