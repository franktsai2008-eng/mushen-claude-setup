---
name: Audit config consumption before syncing across services
description: Before updating an env var or config in N services, grep each codebase to verify it's actually read.
type: feedback
---
When the same env var name (e.g. `CLERK_ALLOWED_EMAILS`) exists in multiple services (Vercel + Railway), don't assume both are load-bearing. Audit each consumer first — vestigial configs from earlier planned phases are common.

**Why:** Started a Railway OAuth flow + hit agent rate limit + tried Railway CLI (interactive only) before pivoting to read the backend code. A 30-second `grep -rn "\.allowed_emails\b" apps/api/` would have shown the backend defines the property in `settings.py` but never reads it — Railway update was unnecessary.

**How to apply (BEFORE asking user to authenticate or starting any infra change):**

1. **Grep each service's source for the config name AND its accessor properties:**
```bash
grep -rn "FOO_BAR\|foo_bar" apps/api/ apps/web/src/ 2>&1 | head -20
grep -rn "\.foo_bar\b" apps/api/ apps/web/src/ 2>&1
```

2. **Match definitions to consumers.** A line in `settings.py` defining the field is just a definition. You need at least one OTHER file referencing it.

3. **Read the auth/middleware/deps files of each service explicitly** — that's where gating typically lives.

4. **Only sync the configs that have at least one real consumer.** Document the vestigial ones.

**Hard rule:** if the config update would require user OAuth or any non-trivial setup, do the grep audit FIRST.

**Related signal:** docstrings like `"Phase N will replace this with..."` usually indicate the surrounding code is the simpler / vestigial form.
