# Database Review Checklist

Run this for any schema migration, data backfill, or query change against a production data store. Run by the change's author with a reviewer familiar with the database's current load and schema. Pair with [../prompts/database-review.md](../prompts/database-review.md) and [../docs/database-guidelines.md](../docs/database-guidelines.md).

## Compatibility

- [ ] Migration is backward compatible with the currently deployed application version (old code keeps working during rollout)
- [ ] Column/table drops or renames follow an expand-contract pattern instead of happening in one step
- [ ] Default values are provided for new required columns so existing rows remain valid

## Performance & locking

- [ ] Indexing is reviewed for new query patterns introduced by this change
- [ ] Migration's lock behavior is understood — does it lock the table, and for how long, at expected data volume
- [ ] Long-running migrations are batched/chunked rather than run as a single blocking transaction on a large table
- [ ] The migration has been tested against a realistic data volume, not an empty or tiny table

## Safety

- [ ] A rollback path exists for the migration, and it has been thought through, not just assumed
- [ ] The change has been tested in a staging environment with production-like data before running against production
- [ ] Backups/snapshots are current before running a destructive or high-risk migration

## Data handling

- [ ] Data retention requirements are reviewed for any new data being stored
- [ ] PII or other sensitive data introduced by this change is identified and handled per policy (encryption, access control, retention)
- [ ] Data being deleted or backfilled has been confirmed against a source of truth, not run on a guess
