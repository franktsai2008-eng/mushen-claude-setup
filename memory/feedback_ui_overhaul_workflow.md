---
name: 4-phase UI overhaul workflow with screenshot gates
description: When user gives a visual reference and asks for a UI redesign, run the work in 4 phases with a screenshot per phase before moving on.
type: feedback
---
For any "redesign this UI" task from user, run the work in 4 phases. Each phase ends with a screenshot delivered back, and user greenlights before the next phase starts. Don't try to ship the whole new design in one diff.

**How to apply:**

**Phase A — Foundation only (≈30 min):** new color tokens in `globals.css` (`:root, .dark` both, OKLCH not hex), font load via `next/font/google`, top nav rewrite, set `<html class="dark">` if going dark-default. NO new sections yet. Screenshot the sign-in or any public page → confirm the vibe is right before touching feature pages.

**Phase B — Main page with MOCK DATA (≈60 min):** build the heart of the app using a single `lib/mock-data.ts` that exports realistic-looking but fake values. Charts, KPIs, lists — all fed from mock. Add a `SectionFrame` helper card. Add interactive animations. Screenshot full page.

**Phase C — Wire real data (≈45 min):** add backend endpoints if missing, update the API client, replace mock imports one section at a time. Skip if backend not blocking.

**Phase D — Polish remaining surfaces (≈30 min):** restyle other pages to match. Type-check + lint + production build before declaring done.

**Set up a `/preview/*` route in Phase A** (NODE_ENV-gated public in `middleware.ts`) so you can screenshot without going through auth. Don't push past Phase A without it.

**Hard rules:**
- Never start Phase B with a different palette than Phase A delivered
- Never skip the screenshot — even one phase without visual verification compounds into rework
- Treat formatter post-write as a feature — re-Read before Edit if hook flagged a reformat
