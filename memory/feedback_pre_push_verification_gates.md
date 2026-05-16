---
name: Pre-push verification gates for frontend work
description: Always run typecheck + lint + production build before pushing UI changes — catches type drift, JSX comment textnodes, unused imports, orphaned old components.
type: feedback
---
Before pushing any non-trivial frontend diff, run all three gates locally. Don't trust dev-mode "it renders fine" — production build catches things dev hides.

**Why:** The dev server happily ran a new dashboard. Pre-push checks caught:
- 3 Recharts v3 tooltip formatter type mismatches (signature changed from v2)
- 5 `react/jsx-no-comment-textnodes` errors where `// ROUTE` was written directly in JSX
- 1 unused `Clock` import
- 1 orphaned component from a prior dashboard using nonexistent `variant="primary"` on shadcn Button

If you'd pushed without checking, prod build on Vercel would've failed and burned a ~2min deploy cycle.

**How to apply (in order):**

```bash
cd apps/web
pnpm typecheck    # tsc --noEmit
pnpm lint         # next lint — react rules, unused imports
pnpm build        # next build — full bundle
```

**Each must pass with zero errors before push.**

**When typecheck fails on legacy unused files:** delete them.

**JSX gotcha:** `// comment text in JSX` is a lint error. Wrap in braces:
```tsx
// WRONG
<h1>// ROUTE · /LIBRARY</h1>
// RIGHT
<h1>{"// ROUTE · /LIBRARY"}</h1>
```

**Recharts v3 formatter signature:** params are typed as `ValueType | undefined` not `number`. Coerce:
```tsx
formatter={(v) => `${typeof v === "number" ? v : Number(v ?? 0)}%`}
```

**Hard rule:** any UI work that touches >5 files MUST go through all three gates before push.
