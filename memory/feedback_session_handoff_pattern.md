---
name: Hand off mid-feature work to a new session via plan + memory + prompt
description: When current session's context fills mid-feature, write three artifacts so the next session can resume cleanly.
type: feedback
---
Long features sometimes outgrow a single session's context window. Don't keep pushing — hand off cleanly.

**The three artifacts:**

1. **PLAN-XXX.md in the repo** (per [feedback_plan_doc_anchor.md](feedback_plan_doc_anchor.md)) — locked decisions, phase breakdown, files-to-touch, commit messages, risks. Pushed via `mcp__github__push_files`.

2. **`project_phaseN_<topic>.md` memory file** — short summary of: what's queued, why this approach, what's locked, what's out of scope. Lives in `~/.claude/projects/-home-$(whoami)/memory/`. Update `MEMORY.md` index with a one-line entry.

3. **Copy-paste prompt for new session** — give the user a code-fenced prompt block they paste into a fresh `claude` session. The prompt:
   - Opens with "我是用戶。延續 <project> 的工作。"
   - Lists 3–4 files to read in order, the PLAN doc first
   - Asks for a smoke check (`curl <endpoint>`) to confirm backend state
   - Asks for a one-line summary back to confirm understanding
   - Tells the agent to enter auto mode and start Phase Na
   - Mentions current deployment state (last commit SHA, last Vercel deploy ID)
   - Lists out-of-scope items that are tempting but rejected

**Trigger to use this pattern:**
- Token usage > 60% for the session
- 5+ commits already pushed in current feature
- User explicitly says "看你要不要開新的 session"
- Backend is at a clean stopping point (deploy SUCCESS, all green)

Don't hand off mid-commit or mid-build. Stop at a green checkpoint.
