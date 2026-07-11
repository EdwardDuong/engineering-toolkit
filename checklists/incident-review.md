# Incident Review Checklist

Run this during an active production incident, by the incident commander or first responder. This is a during-the-fire checklist — the goal is to stabilize the system and keep everyone informed, not to find root cause yet. See [../docs/incident-response.md](../docs/incident-response.md) for the full process.

## Triage

- [ ] Impact and severity are assessed (who/what is affected, how badly, is it growing)
- [ ] An incident commander is assigned and is not also the sole person heads-down fixing it
- [ ] The incident is declared/logged in the tracking system, not just handled in a side channel

## Communication

- [ ] Initial comms are sent to stakeholders/status page within the expected time window
- [ ] Updates go out at a regular cadence even when there's no new information ("still investigating" is a valid update)
- [ ] Comms use plain language for affected users, technical detail for the internal channel

## Response

- [ ] A timeline is being captured as events happen, not reconstructed afterward from memory
- [ ] Mitigation (rollback, feature flag off, failover, scaling) is applied to stop the bleeding, even before root cause is fully known
- [ ] Actions taken are logged with who did what and when, in case they need to be undone
- [ ] Escalation to additional responders or vendors happens promptly if the incident commander is out of their depth

## Closure

- [ ] Resolution is confirmed against the actual user-facing symptom, not just an internal metric returning to normal
- [ ] Stakeholders are notified when the incident is resolved
- [ ] A postmortem is scheduled before the incident channel goes quiet (see [postmortem.md](postmortem.md))
