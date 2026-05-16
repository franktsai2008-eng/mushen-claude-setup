---
name: MCP-first principle (no manual dashboard clicks)
description: If MCP can do it, use MCP. Manual dashboard clicks are last resort.
type: feedback
---
Use MCP tools aggressively for any infra/SaaS operation. Never tell user to "click around in the dashboard" if an MCP path exists, even an awkward one.

**Why:** Manual dashboard work drains users fast and breaks flow.

**How to apply:**

1. **Default to MCP**, even if rate-limited. A retry on `railway-agent` after 5–10 min beats a 6-step dashboard walkthrough.
2. **Available MCP surface area:**
   - Railway: `list-projects`, `list-services`, `list-deployments`, `get-logs`, `redeploy`, `railway-agent` (most powerful)
   - Vercel: `list_teams`, `list_projects`, `deploy_to_vercel`
   - GitHub: `push_files`, `create_or_update_file`, `get_file_contents`
3. **When MCP can't do it** (e.g. setting Railway env vars, Clerk session token customization): give user screenshot-precision instructions — exact menu path, exact field, exact value. No "go explore Settings".
4. **Never make user do something an agent could do.** If agent is rate-limited, tell them so and offer to retry rather than dumping into dashboard.
5. **For tools that need values from user** (API keys): collect once, pipe through CLI/MCP, never ask them to paste the same value into multiple dashboards.
6. **Minimum tool set first.** When starting a new project, begin with the 1-2 most critical MCPs and ship a working slice. Only add more after the first slice runs.
