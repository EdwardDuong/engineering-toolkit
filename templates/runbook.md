<!--
Template: Operational Runbook
Use this when: documenting a repeatable operational procedure for a service (deploy, failover,
maintenance, restart, key rotation, etc.).
Write it so that someone unfamiliar with the service, at 3am, during an incident, can follow it
without needing to ask questions.
-->

# Runbook: [Procedure Name]

| | |
|---|---|
| **Service** | [Service/system name] |
| **Owner Team** | [Team name] |
| **Last Reviewed** | [YYYY-MM-DD] |

## Service Overview

<!-- Brief description of what the service does and how this procedure fits into operating it. -->

[What the service is and what this runbook covers.]

## Prerequisites / Access Needed

<!-- Everything the operator needs before starting: permissions, tools, credentials, VPN, etc.
     Link to the process for requesting access if the operator doesn't already have it. -->

- [ ] Access to [system/dashboard/repo]
- [ ] [Required tool or CLI installed]
- [ ] [Any required permission/role]

## Step-by-Step Procedure

<!-- Numbered, unambiguous steps. Include exact commands. Note expected output where it helps
     confirm the operator is on track. -->

1. [Step, including exact command if applicable]

   ```bash
   [command]
   ```

2. [Step]
3. [Step]

## Verification Steps

<!-- How does the operator confirm the procedure succeeded? -->

- [ ] [Check to confirm success, e.g. "Service health endpoint returns 200"]
- [ ] [Check]

## Rollback Procedure

<!-- What to do if something goes wrong mid-procedure or verification fails. -->

1. [Rollback step]
2. [Rollback step]

## Escalation Contacts

<!-- Who to contact if the operator gets stuck. Prefer roles/on-call rotations over individual
     names so this doesn't go stale. -->

| Role | Contact |
|---|---|
| [Primary on-call] | [Contact method] |
| [Service owner / escalation] | [Contact method] |
