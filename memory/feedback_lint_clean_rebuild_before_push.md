---
name: Vercel runs ESLint with clean cache; rm -rf .next + rebuild before claiming success
description: Local `pnpm build` can pass on cached ESLint state and miss errors Vercel catches.
type: feedback
---
Local Next.js builds incrementally cache the ESLint phase. If a previous build ran lint clean, re-running `pnpm build` may skip some checks even after edits that introduce new lint violations.

**Why this bit us:** Adding `/chat/[id]` as a dynamic route made existing `<a href="/chat">` calls trip the `@next/next/no-html-link-for-pages` rule. Local `pnpm build` PASSED. Vercel build FAILED. Diff: Vercel wipes the cache.

**How to apply:**

1. Before the final push of any frontend phase, run:
   ```
   cd apps/web && rm -rf .next && pnpm build
   ```
2. When adding a new dynamic route (`/foo/[id]`): the `no-html-link-for-pages` rule re-evaluates all `<a href>` in the codebase. Grep for `<a href="/foo` after the route lands.
3. At minimum run `pnpm lint` separately — it has its own cache but doesn't piggyback on the build cache.

**Recovery when Vercel fails on lint:** read the build log via `mcp__claude_ai_Vercel__get_deployment_build_logs` (look for `Error:` lines), fix locally, push a `fix(web): ...` commit on top.
