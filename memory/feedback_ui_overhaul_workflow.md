---
name: 4-phase UI overhaul workflow with screenshot gates
description: When given a visual reference and asked for a UI redesign, run the work in 4 phases with a screenshot per phase before moving on.
type: feedback
---
For any "redesign this UI" / "rebuild this dashboard" task, run the work in 4 phases. Each phase ends with a screenshot delivered back, and the user greenlights before the next phase starts. Don't try to ship the whole new design in one diff — the user wants to redirect early.

**How to apply:**

**Phase A — Foundation only (≈30 min):** new color tokens in `globals.css` (`:root, .dark` both, OKLCH not hex), font load via `next/font/google`, top nav rewrite, set `<html class="dark">` if going dark-default. NO new sections yet. Screenshot a public page → confirm the vibe is right before touching feature pages.

**Phase B — Main page with MOCK DATA (≈60 min):** build the heart of the app using a single `lib/mock-data.ts` that exports realistic-looking but fake values. Charts, KPIs, lists — all fed from mock. Screenshot full page.

**Phase C — Wire real data (≈45 min):** add backend endpoints if missing, update the API client, replace mock imports one section at a time. Skip if backend not blocking.

**Phase D — Polish remaining surfaces (≈30 min):** restyle secondary pages to match. Type-check + lint + production build before declaring done.

**Set up a `/preview/*` route in Phase A** (NODE_ENV-gated public in `middleware.ts`) so you can screenshot without going through auth.

**Hard rules:**
- Never start Phase B with a different palette than Phase A delivered
- Never skip the screenshot — even one phase without visual verification compounds into rework
