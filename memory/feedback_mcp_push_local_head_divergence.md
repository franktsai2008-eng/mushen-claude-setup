---
name: mcp__github__push_files doesn't update local git HEAD — treat list_commits as truth
description: After mcp__github__push_files commits to GitHub, local HEAD doesn't move and `git status` shows pushed files as modified.
type: feedback
---
`mcp__github__push_files` writes a commit directly to the GitHub branch via API. It bypasses local git entirely.

**Why this trips us up:** After pushing, `git status` reports the same files as still modified or untracked because the local working tree wasn't committed locally. `git log` shows the old HEAD, not the new tip on origin. A new session looking at git state thinks nothing has been pushed and is tempted to re-push — wrong.

**How to apply:**
1. **Authority order for "what's on main":** `mcp__github__list_commits(owner, repo)` > GitHub web UI > local `git log`.
2. **Don't `git fetch && git reset` impulsively.** It can clobber untracked files. The safe move when local state confuses you is *do nothing* — keep editing files, push via mcp again.
3. **Don't commit locally then push** unless `git push` actually works for this repo.
4. **Vercel CLI quirk:** `vercel deploy` from cwd uploads filesystem content but tags the deployment with local `git log`'s sha + `gitDirty: 1`. The build is correct (uses uploaded files); only the metadata SHA is misleading.
5. **Confirm after each push:** call `mcp__github__list_commits(perPage=5)` to verify the new SHA appears at the top.

If you need to align local HEAD with origin: `git fetch && git reset --soft origin/main` is safest — moves HEAD without touching working tree.
