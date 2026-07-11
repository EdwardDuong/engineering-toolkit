# Before Push Checklist

Run this before `git push` to a shared remote, by whoever owns the branch. Pushing is where a purely local mistake becomes everyone else's problem — CI queues, review requests, and other branches all start depending on what's now visible upstream.

## Branch state

- [ ] Local branch is rebased on (or merged with) the latest target branch (avoids a foreseeable conflict landing on someone else during review)
- [ ] History is reasonably clean — no "wip", "fix typo", "asdf" commits left unsquashed if the project's convention expects clean history
- [ ] Force-push, if needed, targets only your own feature branch and not a shared branch

## Verification

- [ ] Full local test suite has been run, not just tests touching the changed files (catches unexpected breakage elsewhere)
- [ ] Linter and formatter pass clean with no suppressed warnings added to get there
- [ ] Build succeeds from a clean state, not just an incrementally cached one

## Hygiene

- [ ] No accidental large files, build artifacts, or dependency directories included
- [ ] No local-only config, IDE files, or machine-specific paths included
- [ ] Diff was reviewed end-to-end one more time (`git diff <target>...HEAD`) before pushing
