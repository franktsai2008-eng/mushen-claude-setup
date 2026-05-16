---
name: dashboard imports from mock-data.ts (not the API)
description: Trap that wasted a debugging session — backend was returning real data but the dashboard never asked for it.
type: feedback
---
When the dashboard shows numbers that don't change after a backend sync, **check `apps/web/src/components/dashboard/*.tsx` for imports from `@/lib/mock-data`** before assuming the backend is broken. Dashboard components may still pull hardcoded values from `mock-data.ts` — the backend can be returning user's real numbers and the page will still render fake data.

**Why:** Dashboard was built mock-first during UI iteration so visuals could be polished without backend coupling. The wiring step was deliberately deferred.

**How to apply:** Before debugging "data isn't updating," `grep -rn 'from "@/lib/mock-data"' apps/web/src/components/dashboard/`. If any hits exist, the dashboard is rendering fake data regardless of API state. Fix path is per-component swap to the `api.*` namespace in `apps/web/src/lib/api.ts`.
