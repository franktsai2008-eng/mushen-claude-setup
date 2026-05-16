---
name: Push PLAN-XXX.md to repo as resumption anchor before starting multi-phase work
description: Before any multi-phase feature (>1 hour, >3 commits expected), write a PLAN-XXX.md to repo and push it as the very first commit.
type: feedback
---
For features that span 3+ commits or might overrun a session's context window, the first action is to push a plan doc to the repo BEFORE writing any code.

**Why:** When a session gets cut off mid-build, the plan doc lets the next session pick up cleanly. Without it, each restart is a re-discovery exercise — slow + error-prone.

**How to apply:**
- File: `PLAN-<FEATURE-NAME>.md` at repo root (e.g. `PLAN-DASHBOARD-WIRING.md`, `PLAN-CHAT-SESSIONS.md`).
- Sections: Goal · Decisions (locked, with date) · Phase A/B/C... files-to-touch + commit message + done-when · Risks · Out of scope · Pre-flight where-to-read pointers.
- First commit message: `docs: PLAN-XXX.md — Phase N build plan (anchor for resumption)`.
- Push via `mcp__github__push_files` so the anchor lands on GitHub even if local git state diverges later.
- Subsequent commits use phase-numbered prefixes: `(Phase 8a)`, `(Phase 8b/2)`, etc. — see [feedback_phase_split_commits.md](feedback_phase_split_commits.md).
- Add a `## Source of truth (resume from here if interrupted)` section listing the exact mcp tool calls a new session should run (`list_commits`, `list_deployments`) to identify which phase to resume from.

If the user later changes scope mid-build, update the plan and re-push. The plan is the contract — both for current session and any successor.
