---
name: Railway monorepo deploy traps (FastAPI + Postgres)
description: Six concrete Railway gotchas. Apply when deploying any FastAPI/Python service from a pnpm-workspace monorepo to Railway.
type: feedback
---
When deploying a Python (FastAPI) service from a pnpm-workspace monorepo to Railway, these six issues bite in sequence. Diagnose in this order from logs.

**How to apply:**

1. **Watch Paths auto-set wrong** — Railway names the service from the monorepo's auto-detected workspace name, then sets Watch Paths = `/apps/web/**`. Result: every push to `apps/api/**` shows up as `status: SKIPPED, snapshotId: null` in `list-deployments`. Fix: clear/edit Watch Paths to match the actual deployable subdir, or leave empty.

2. **Target Port is 8080, not 8000** — Railway *injects* `PORT=8080` at runtime, overriding any `ENV PORT=8000` in the Dockerfile. External requests get 502 even when internal `/health` returns 200. Fix: set Target Port = 8080, or leave blank for auto-detect.

3. **DATABASE_URL must be a Reference Variable** — Adding Postgres as a service does NOT auto-attach `DATABASE_URL` to other services. You must add it as a Reference: `+ New Variable → Add Reference → Postgres → DATABASE_URL`. Without this, alembic falls through to the pydantic-settings default and crashes.

4. **Railway-injected `DATABASE_URL` is driver-less** — Form is `postgresql://user:pass@host/db` with no driver suffix. SQLAlchemy then defaults to the `psycopg2` driver, which projects using asyncpg/psycopg3 don't ship → `ModuleNotFoundError: No module named 'psycopg2'`. Fix: normalize at the settings layer:
   ```python
   def _normalize_db_url(raw: str, *, driver: Literal["asyncpg", "psycopg"]) -> str:
       if raw.startswith("postgres://"):
           raw = "postgresql://" + raw[len("postgres://"):]
       target = f"postgresql+{driver}://"
       for prefix in ("postgresql+asyncpg://", "postgresql+psycopg://", "postgresql://"):
           if raw.startswith(prefix):
               return target + raw[len(prefix):]
       return raw
   ```

5. **SKIPPED deployments come back as `redeploy` errors** — `redeploy` MCP tool refuses with "Cannot redeploy without a snapshot" because SKIPPED deployments have `snapshotId: null`. To force a real build: push a tiny new commit via `mcp__github__push_files`.

6. **Diagnose from `get-logs` first, not from prior session memory** — Always pull `mcp__railway__get-logs` for the latest FAILED deployment with `types=["build","deploy"]` BEFORE trusting any prior diagnosis.

**Order of attack** when a Railway deploy fails:
1. `list-deployments` → status of latest. SKIPPED → Watch Paths issue (#1).
2. If FAILED → `get-logs types=["deploy"]` → look at last 30 lines.
3. If healthy build but external 502 → Target Port mismatch (#2).
