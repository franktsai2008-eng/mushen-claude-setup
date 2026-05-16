---
name: Vercel may not auto-deploy on git push — verify and trigger manually
description: After pushing to GitHub, always check Vercel deployments to confirm a new build started. If the project isn't Git-connected, trigger manually via CLI.
type: feedback
---
Don't assume `git push origin main` triggers a Vercel build. Some Vercel projects are CLI-deployed only (no Git integration), and pushing to GitHub does nothing. Always verify after push.

**How to apply:**

1. **After every push to main, immediately call:**
```
mcp__claude_ai_Vercel__list_deployments(projectId, teamId)
```
Look at the top deployment's `gitCommitSha` — if it doesn't match HEAD, no auto-deploy happened.

2. **If no auto-deploy, trigger via CLI from local:**
```bash
cd apps/web
vercel deploy --prod --yes --no-wait 2>&1 | tail -3
# captures: dpl_<id> + URL
```
The `--no-wait` returns the deployment ID immediately. Do NOT block the CLI on the build — poll via MCP.

3. **Poll until READY:**
```
mcp__claude_ai_Vercel__get_deployment(idOrUrl="dpl_<id>", teamId="<your-team-id>")
```
Look for `state: "READY"`. Typical Next.js build = 60–120s. Use ScheduleWakeup with delaySeconds=120 to come back instead of polling tightly.

4. **The shorter alias is in the `alias` array of the READY deployment.** Report THAT, not the long deploy URL.

5. **Local git diverged from origin doesn't matter for `vercel deploy`** — CLI bundles the working tree, not git history.

**Same applies to Railway** — don't assume git push triggers it. Verify via `get-logs` after push.
