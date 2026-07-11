# Before Coding Checklist

Run this before writing the first line of a nontrivial change. Applies to the engineer or agent about to start implementation, not just at project kickoff — re-run it for any new task or ticket. The goal is to avoid discovering mid-implementation that the requirements were wrong, the design was avoidable, or someone else already did this work.

## Requirements

- [ ] Requirements and acceptance criteria are documented and unambiguous (see [../docs/definition-of-ready.md](../docs/definition-of-ready.md))
- [ ] Success is defined in terms that can be objectively verified (a test, a metric, a demo — not "it feels right")
- [ ] Out-of-scope items are explicitly noted (prevents scope creep from being discovered only at review time)
- [ ] Open questions have been raised with the requester, not silently assumed away

## Design

- [ ] For nontrivial work, a design approach has been considered and, where warranted, written down (see [../templates/adr.md](../templates/adr.md))
- [ ] At least one alternative approach was considered and rejected for a stated reason (protects against the first idea being the only idea)
- [ ] The blast radius of the change is understood (what breaks if this is wrong)
- [ ] Any new dependency (library, service, API) has been justified, not just convenient

## Context

- [ ] The existing code this change touches has actually been read, not just skimmed
- [ ] Existing tests around this area are understood — what they cover and what they don't
- [ ] Related conventions in the codebase (naming, error handling, folder structure) have been identified and will be followed
- [ ] No one else is already doing this work (checked open PRs, branches, and in-flight tickets)
- [ ] If this duplicates or conflicts with in-flight work, it's been flagged before starting
