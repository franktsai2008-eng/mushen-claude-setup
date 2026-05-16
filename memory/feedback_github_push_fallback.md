---
name: GitHub push fallback when `git push` returns 403
description: When local git push fails with Write access not granted, switch to mcp__github__push_files in batches.
type: feedback
---
Local `git push` may 403 even when `mcp__github__get_me` works (the MCP token has write scope, the local credential helper doesn't). Don't try to fix git auth or hunt for tokens — that's a permission denial path. Just push via MCP.

**Why:** `git push origin main` may return `403 Write access to repository not granted` for the HTTPS remote, but `mcp__github__push_files` succeeds immediately. Burning time trying to set up a PAT or `gh auth login` is wasted — user may not be available to interact with an OAuth flow.

**How to apply:**

1. **Detect early.** Before staging a big diff, do a tiny test: `git push --dry-run origin main`. If it 403s, skip git push entirely.

2. **Build a JSON payload of changed files** in Python:
```python
import json, os, subprocess
files = subprocess.check_output(["git", "show", "--diff-filter=AM", "--name-only", "--format=", "HEAD"]).decode().splitlines()
out = [{"path": f, "content": open(f).read()} for f in files if f]
json.dump(out, open("/tmp/push-payload.json", "w"), ensure_ascii=False)
```

3. **Split into batches of ~6 files OR ≤25KB per batch.** Read tool caps at 25K tokens (~80KB). 12 files / 60KB will fail Read; 6 files / 25KB works.

4. **Read batch JSON, then pass parsed array as `files` param** to `mcp__github__push_files`.

5. **Handle deletes separately.** `push_files` is add/update only. Use `mcp__github__delete_file` for `D` files.

6. **Local working tree diverges from origin after.** Local commit hash ≠ remote.

**Hard rule:** when push 403s, don't burn 5 turns trying alternatives — just pivot to MCP within 2 turns.
