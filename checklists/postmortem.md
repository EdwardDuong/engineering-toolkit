# Postmortem Checklist

Run this while writing and reviewing a postmortem after an incident, by the incident owner together with participants. Use [../templates/postmortem.md](../templates/postmortem.md) as the document template and [../docs/postmortem-guide.md](../docs/postmortem-guide.md) for the full process. A postmortem that doesn't produce owned action items is just a story.

## Framing

- [ ] Blameless framing is confirmed — the document describes what happened in the system and process, not who to blame
- [ ] Language avoids naming individuals for mistakes ("the deploy script skipped validation," not "X forgot to validate")
- [ ] Participants were actually able to speak candidly, including about their own actions

## Timeline

- [ ] Timeline is accurate and reconstructed from logs/metrics/chat history, not just memory
- [ ] Timeline includes detection, escalation, mitigation, and resolution — not just the fix
- [ ] Time-to-detect and time-to-resolve are stated explicitly

## Root cause

- [ ] Root cause(s) are identified, not just the proximate trigger (ask "why" until it stops being useful, not just once)
- [ ] Contributing factors (process, tooling, missing alerts) are captured alongside the technical cause
- [ ] It's acknowledged if there were multiple compounding causes rather than forcing a single narrative

## Action items

- [ ] Every action item has a single named owner
- [ ] Every action item has a target date
- [ ] Action items address root cause and contributing factors, not only the immediate symptom
- [ ] Action items are tracked to completion, not left to close themselves

## Distribution

- [ ] The postmortem is shared broadly enough that others can learn from it, not just filed away
- [ ] Relevant teams outside the immediate responders are made aware if the failure mode could recur elsewhere
