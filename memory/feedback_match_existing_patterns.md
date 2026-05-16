---
name: Read existing patterns before writing new files — match the codebase
description: Before adding a new model/route/repo/component, read 2–3 sibling files in the same directory and match their conventions exactly.
type: feedback
---
Each established codebase has style choices (decorator placement, import ordering, doc-string voice, error-message phrasing) that aren't documented but are consistent. New files should be indistinguishable from existing ones.

**Example (FastAPI + Next.js project):**
- All ORM models inherit `Base` — except one-off tables where no tenant scope is intentional. Check a sibling first before deciding a new model inherits Base too.
- Repos are in `app/repositories/<table_name>.py`, named like the table, with read-side helpers as module-level async functions taking `session` first.
- Routes are in `app/routes/<resource>.py` with `router = APIRouter(prefix="/api/<resource>")`.
- Frontend components in `apps/web/src/components/<area>/` are `"use client"` if they use hooks, use `motion/react` for animation, consistent class chrome.

**How to apply:**

1. **Before creating a new file:** `ls` the destination directory and `Read` the most-recently-modified sibling. For complex types, read 2–3.
2. **Imports:** match the order existing files use.
3. **Doc-string voice:** terse, declarative, mentions the *why* not the *what*.
4. **Error messages and empty states:** look up how the project speaks. Match the existing voice.
5. **Visual style**: see [reference_design_patterns_terminal_dashboard.md](reference_design_patterns_terminal_dashboard.md). Don't invent new chrome — keep wrapping components consistent.

If a "right" pattern is genuinely missing for your new feature, pause and ask before inventing it.
