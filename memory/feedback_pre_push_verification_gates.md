---
name: Pre-push verification gates for frontend work
description: Always run typecheck + lint + production build before pushing UI changes.
type: feedback
---
Before pushing any non-trivial frontend diff, run all three gates locally. Don't trust dev-mode "it renders fine" — production build catches things dev hides.

**Why:** Pre-push checks have caught: Recharts v3 tooltip formatter type mismatches (signature changed from v2), `react/jsx-no-comment-textnodes` errors where `// ROUTE` was written directly in JSX (must be `{"// ROUTE"}`), unused imports, orphaned files using nonexistent shadcn variants.

**How to apply (in order):**

```bash
cd apps/web
pnpm typecheck    # tsc --noEmit
pnpm lint         # next lint
pnpm build        # next build
```

**Each must pass with zero errors before push.** Warnings OK.

**When typecheck fails on legacy unused files:** delete them. Don't tweak them. If a file isn't imported anywhere, `rm` is the right fix.

**JSX gotcha:** `// comment text in JSX` is a lint error. Wrap in braces:
```tsx
// WRONG: <h1>// ROUTE</h1>
// RIGHT: <h1>{"// ROUTE"}</h1>
```

**Recharts v3 formatter signature:** params are typed as `ValueType | undefined` not `number`. Coerce: `formatter={(v) => `${typeof v === "number" ? v : Number(v ?? 0)}%`}`

**Hard rule:** any UI work that touches >5 files MUST go through all three gates before push.
