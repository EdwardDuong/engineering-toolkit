# Before Release Checklist

Run this before cutting and shipping a release, by whoever owns the release process. A release ships everything merged since the last one to real users at once — this is the last point where a bundling or sequencing mistake is still cheap to fix.

## Content

- [ ] Changelog is updated with all user-facing changes since the last release
- [ ] Version is bumped following semantic versioning (major.minor.patch matches the actual nature of the changes)
- [ ] Release notes are drafted, using [../templates/release-notes.md](../templates/release-notes.md)
- [ ] Breaking changes are prominently called out, with migration guidance

## Safety

- [ ] Migration plan is documented for any schema, config, or data change (see [../docs/database-guidelines.md](../docs/database-guidelines.md))
- [ ] Rollback plan is documented and has been sanity-checked, not just assumed to work
- [ ] Release has been tested in a staging or pre-production environment that mirrors production
- [ ] Feature flags for incomplete or risky work are confirmed off by default

## Communication

- [ ] Stakeholders (support, sales, downstream teams) are notified ahead of the release, not after
- [ ] On-call/support is briefed on what's shipping and what to watch for
- [ ] Release window avoids known high-risk periods (e.g., Friday afternoon, peak traffic, other concurrent releases) unless there's a specific reason not to
