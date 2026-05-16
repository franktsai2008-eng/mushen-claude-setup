---
name: Cross-session push completeness check
description: When committing work started in another session, verify ALL files (modified + untracked) match the original session's intent before push.
type: feedback
---
When a Claude session writes a feature across N files (some new, some modified) and a *different* session commits + pushes the work, the second session often misses files. Hit this with Phase 14: 6 new files + 2 modified files were missing from the push, taking 4 fix commits to recover production.

**Why:** `git add -u` only stages tracked modifications. IDE partial-staging UIs only stage what you ticked. Both silently skip new files and forgotten modifications.

**How to apply (mandatory before any cross-session push):**
1. `git status -s` — list everything (modified `M` + untracked `??`)
2. `git diff --stat origin/main..HEAD` after staging — confirm staged set matches the feature's full surface
3. If the original session left a PLAN doc or summary, cross-check the file list against it
4. If in doubt, `git add -A` (everything) > `git add -u` (modifications only)

**Concrete fingerprint of this failure:** Railway shows "Build failed" email but logs say `Healthcheck failed!` with `1/1 replicas never became healthy` — the actual cause is a Python `ImportError` at uvicorn startup pointing to a module that exists locally but not in the GitHub commit.
