---
name: Clerk-protected actions — hand user a one-line fetch for browser DevTools console
description: When an action needs a Clerk JWT, the Linux session can't authenticate. Don't ask user to click through UI. Hand them a one-liner they paste into DevTools console.
type: feedback
---
Backend protected routes require Clerk JWT auth. The Linux Claude Code session has no Clerk cookie / session, so server-side curl can't trigger them.

**Why this matters:** several useful operations are auth-gated. Asking user to navigate UI to trigger them violates the [MCP-first principle](feedback_mcp_first_principle.md). Browser DevTools console hits the API directly using user's already-valid session cookie.

**How to apply:**

When a backend action is needed and requires auth, give user a copy-paste one-liner like:

```js
await fetch('/api/sync/ig', {method:'POST', headers:{'content-type':'application/json'}}).then(r=>r.json())
```

Conventions:
- Always use a **relative URL** (no host) — runs on the deployed origin so the Clerk cookie comes along.
- POST/PATCH/DELETE bodies as JSON: `body: JSON.stringify({...})` with `'content-type':'application/json'`.
- Wrap in `await` so the response is logged synchronously in console.
- Tell user exactly which dashboard tab to be on (they must already be authenticated on the production alias).

Don't try to harvest the JWT and curl from the Linux side — token TTL is short, paste-token-into-curl is fragile, and Clerk dev session tokens rotate. Browser console is the cheapest path.
