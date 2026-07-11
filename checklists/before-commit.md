# Before Commit Checklist

Run this before every `git commit`, by whoever (human or agent) is authoring the change. A commit is a unit of history other people will read later — it should be safe to revert on its own and easy to understand out of context.

## Scope

- [ ] The change does one thing (a reviewer or `git bisect` shouldn't have to untangle unrelated edits)
- [ ] Unrelated formatting or reformatting changes are excluded (they bury the real diff)
- [ ] Only files intentionally changed are staged (`git status` / `git diff --cached` reviewed, not just `git add -A`)

## Correctness

- [ ] Tests relevant to the change pass locally
- [ ] New behavior has a test covering it, or a documented reason it can't be tested
- [ ] The change was manually exercised at least once, not just compiled/type-checked

## Cleanliness

- [ ] No debug code left in (`console.log`, `print`, `debugger`, temporary flags)
- [ ] No commented-out code left in (delete it — history already has it if it's needed again)
- [ ] No stray TODOs without an owner or ticket reference

## Safety

- [ ] No secrets, API keys, tokens, credentials, or private keys in the diff
- [ ] No `.env` files, credential dumps, or local config with real values staged
- [ ] No large binary or generated files accidentally staged

## Message

- [ ] Commit message follows [../docs/conventional-commits.md](../docs/conventional-commits.md)
- [ ] Message explains *why*, not just *what* (the diff already shows what)
- [ ] Breaking changes are flagged in the message per the convention
