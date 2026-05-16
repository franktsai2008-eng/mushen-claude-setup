---
name: Resume an interrupted session by parsing the JSONL transcript
description: When the user reports a previous session was cut off, the canonical record is the prior conversation's JSONL file. Parse it before guessing.
type: feedback
---
When a session continues work from a previous one that was interrupted, don't reconstruct from memory observations alone — observations are summaries and miss the last 30–60 minutes of work.

**Why:** claude-mem observations are written incrementally and the last batch may not have been flushed before the cutoff. The JSONL transcript at `~/.claude/projects/-home-$(whoami)/<sessionId>.jsonl` is the ground truth — every tool call, every text block, every timestamp.

**How to apply:**
1. `ls -la --time-style=full-iso ~/.claude/projects/-home-$(whoami)/*.jsonl | sort -k6,7` to find the most-recent file before the current session started.
2. Parse with python: extract user prompts, assistant tool_use names + brief input, text blocks. Filter out `<system-reminder>` and tool_result wrappers.
3. Reconcile with `mcp__github__list_commits` (what got pushed) and the local working tree (what's modified). Don't trust local `git log` alone.
4. Look for the LAST text block from the assistant — usually a status report or "all done" message that pinpoints where the session stopped.

The prior session may have completed more than the user realizes. Check before re-doing.
