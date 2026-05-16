---
name: Vercel monorepo deploy traps (Next.js + pnpm)
description: Five Vercel gotchas. Apply when deploying Next.js from a pnpm-workspace monorepo to Vercel.
type: feedback
---
When CLI-deploying a Next.js app from a subdir of a pnpm monorepo, these five issues bite. Skip the trial-and-error and start with this config.

**How to apply:**

1. **Force pnpm 9.15.4 via installCommand** — Vercel's bundled pnpm v8 hits `ERR_PNPM_META_FETCH_FAIL`. The `packageManager` field in package.json does NOT help unless a lockfile is bundled. Use:
   ```json
   { "installCommand": "npx --yes pnpm@9.15.4 install --no-frozen-lockfile" }
   ```

2. **Override stored buildCommand explicitly in vercel.json** — On first `vercel link`, Vercel stores whatever `buildCommand` was in vercel.json AT THAT MOMENT into project settings. The OLD value persists. Fix: keep `buildCommand` in vercel.json with the desired value (e.g. `"buildCommand": "next build"`).

3. **Make `apps/web/package.json` self-contained** — Don't reference workspace siblings. With Vercel's rootDirectory pointing to `apps/web`, the workspace context is gone. Make every dep explicit in apps/web/package.json.

4. **Use `vercel link --yes --project <explicit-name> --scope <team-slug>`** — Otherwise the project gets named after cwd. Pick the name yourself.

5. **Rely on `vercel deploy --prod --yes --no-wait` + `vercel inspect <url>` polling** — `--no-wait` returns the URL immediately. Don't try to block the CLI on the build.

**Canonical first-time vercel.json:**
```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": "nextjs",
  "installCommand": "npx --yes pnpm@9.15.4 install --no-frozen-lockfile",
  "buildCommand": "next build"
}
```

**Order of attack** when a Vercel build fails:
1. `vercel inspect <url> --logs --scope <slug>` → look at last 30 lines.
2. `ERR_PNPM_META_FETCH_FAIL` → fix #1 (pin pnpm).
3. Build runs unexpected command → fix #2 (project-stored buildCommand override).
4. `pnpm --filter` errors → fix #3 (workspace context missing).
