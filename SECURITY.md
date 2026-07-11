# Security Policy

## What this policy covers

This repository is a **template and documentation toolkit** — it is not a
running service, and it does not process user data or handle production
traffic on its own. "Security" here means: could something in this
repository, if copied into a consumer's project, introduce a vulnerability,
run malicious code, or weaken their security posture?

### In scope

- **`scripts/`** — the Bash and PowerShell automation scripts. A
  vulnerability here would be something like: a script that executes
  untrusted input, downloads and runs remote code without verification,
  writes outside its intended directory, or otherwise behaves unsafely when
  a consumer runs it in their own repo.
- **`.github/workflows/`** — the CI workflow definitions. A vulnerability
  here would be something like: a workflow that leaks secrets, runs
  untrusted PR code with write permissions, or uses an unpinned/compromised
  action.
- Any instruction in **`.claude/`**, **`docs/`**, **`templates/`**, or
  **`prompts/`** that, if followed literally, would cause an engineer or an
  AI assistant to introduce an insecure pattern into their own codebase
  (e.g., a code example that suggests disabling certificate validation).

### Out of scope

- **`examples/`** — content here is explicitly illustrative and may contain
  simplified or intentionally imperfect scenarios (e.g., a sample incident
  report) for teaching purposes. It is not meant to be copied verbatim.
- Vulnerabilities in third-party tools, services, or dependencies that this
  toolkit merely *references* (e.g., a CI provider named as an example).
  Report those to the maintainers of that project.
- Findings that require a consumer to have already misconfigured their own
  environment in an insecure way unrelated to this toolkit's content.

## Reporting a vulnerability

Please **do not open a public issue** for a suspected security problem.

Use GitHub's private reporting flow instead:

1. Go to the repository's **Security** tab.
2. Select **"Report a vulnerability"** to open a private security advisory.
3. Include: the affected file(s), the specific concern, and — if
   applicable — a minimal reproduction (e.g., the exact script invocation
   or workflow trigger that demonstrates the issue).

If GitHub Security Advisories are not available for this repository at the
time of your report, open a regular issue with as few sensitive details as
possible and ask a maintainer to open a private channel.

## Response expectations

This is a template repository maintained on a best-effort, volunteer basis —
there is no SLA and no dedicated security team. As a general guide:

- **Acknowledgment**: best-effort within one week.
- **Triage and fix**: depends on severity and maintainer availability. A
  script that could cause data loss or execute arbitrary code on a
  consumer's machine will be prioritized over a documentation nit.
- **Disclosure**: once a fix is available, we will publish an advisory and
  credit the reporter (unless anonymity is requested), consistent with
  responsible disclosure norms.

## Scope reminder for consumers

Because this toolkit is designed to be copied into other repositories,
always review scripts and workflows before running them in your own
environment, the same as you would for any third-party code — cloning this
repository does not constitute an endorsement of its scripts running with
elevated privileges in your CI.
