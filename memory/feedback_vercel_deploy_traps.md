---
name: Vercel monorepo deploy traps (Next.js + pnpm)
description: Five Vercel gotchas hit during monorepo deploy. Apply when deploying Next.js from a pnpm-workspace monorepo to Vercel where the root lockfile isn't bundled.
type: feedback
---
When CLI-deploying a Next.js app from a subdir of a pnpm monorepo (and the root lockfile isn't pushed to GitHub), these five issues bite.

**How to apply:**

1. **Force pnpm 9.15.4 via installCommand** — Vercel's bundled pnpm v8 hits `ERR_PNPM_META_FETCH_FAIL` on current Node.js. The `packageManager` field in package.json does NOT help unless a lockfile is bundled. Use:
   ```json
   {
     "installCommand": "npx --yes pnpm@9.15.4 install --no-frozen-lockfile"
   }
   ```

2. **Override stored buildCommand explicitly in vercel.json** — On the first `vercel link`, Vercel stores whatever `buildCommand` was in vercel.json AT THAT MOMENT into project settings. Keep `buildCommand` in vercel.json explicitly (e.g. `"buildCommand": "next build"`), don't rely on auto-detect once a project is linked.

3. **Make `apps/web/package.json` self-contained** — Don't reference workspace siblings. With Vercel's rootDirectory pointing to `apps/web`, the workspace context is gone.

4. **Use `vercel link --yes --project <explicit-name> --scope <team-slug>`** — Otherwise the project gets named after cwd ("web") which is ugly.

5. **Rely on `vercel deploy --prod --yes --no-wait` + polling** — `--no-wait` returns the URL immediately so you can poll status.

**Canonical first-time vercel.json for a Next.js subdir-of-monorepo deploy:**
```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": "nextjs",
  "installCommand": "npx --yes pnpm@9.15.4 install --no-frozen-lockfile",
  "buildCommand": "next build"
}
```

**Order of attack** when a Vercel build fails:
1. Read build logs via `mcp__claude_ai_Vercel__get_deployment_build_logs` → look for `Error:` lines.
2. `ERR_PNPM_META_FETCH_FAIL` → fix #1 (pin pnpm).
3. Build runs unexpected command → fix #2 (project-stored buildCommand override).
4. `pnpm --filter` errors → fix #3 (workspace context missing).
