---
name: Backend before frontend — schema → repo → route → frontend types → frontend UI
description: For any feature touching both layers, ship the backend phase first and verify endpoints respond before writing frontend that consumes them.
type: feedback
---
Multi-layer features consistently work better when the backend is deployed and curlable before the frontend types are written.

**Why:**
- Pydantic schemas evolve during backend work. If the frontend was already built against an early shape, every backend tweak forces a frontend re-edit.
- Railway deploys auto-run alembic migrations. Confirming SUCCESS means schema and routes are real before the frontend assumes them.
- Real-world response shapes (NULLs, edge cases) are visible via curl — saves frontend from defensive code that turns out unnecessary.

**How to apply:**

1. **Phase ordering:** alembic migration + ORM model + repo (Phase Na) → schemas + route (Phase Nb) → push to GitHub → wait Railway SUCCESS → curl `/openapi.json` → frontend api.ts types + hooks (Phase Nc) → frontend UI (Phase Nd) → Vercel deploy.

2. **Smoke between phases:** after backend deploy, `curl https://.../openapi.json` to list new paths. Hit each endpoint once via DevTools fetch to verify shape matches the schema.

3. **One exception:** if the backend phase is small (<3 files) and you're confident in the contract, frontend in parallel is OK. But still wait for SUCCESS before pushing frontend commit.

4. **When the backend can't reach the production database, don't push frontend** that depends on the new endpoint. The user will see broken UI.
