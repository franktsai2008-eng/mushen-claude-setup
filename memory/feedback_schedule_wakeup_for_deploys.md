---
name: Use ScheduleWakeup or background until-loop for deploy waits — never tight poll
description: Vercel builds take ~3 min, Railway ~1–2 min. ScheduleWakeup with delaySeconds=120–180 or background `until` loop are the right tools.
type: feedback
---
Vercel and Railway deploys are slow enough that synchronously waiting on them burns context window and tool budget. Background it.

**How to apply:**

1. **For "tell me when deploy READY" with one notification:**
   ```
   Bash(run_in_background=true, command="until curl -sI <url> 2>/dev/null | head -1 | grep -qE 'HTTP/2 200'; do sleep 8; done; echo DONE")
   ```
   The runtime fires a single completion notification when the loop exits.

2. **For "check back in 3 min" when you also want to keep working:**
   `ScheduleWakeup(delaySeconds=180, prompt="continue Phase F: get dpl_<id> state, verify alias rotation, summarize")` — the prompt becomes the next user-side input when fired.

3. **Don't:**
   - Foreground `sleep 60 && check` — wastes the cache window (Anthropic prompt cache TTL is 5 min).
   - Repeated `mcp__claude_ai_Vercel__get_deployment` polls in a loop.
   - Poll on 1-second intervals for remote APIs. Use ≥30s.

4. **Notification etiquette:** when a background bash task completes, the user sees `task-notification` system message — DO NOT interpret it as a user reply.

5. **Choose ScheduleWakeup vs Bash background:**
   - Background bash: condition-driven, single notification, ends in seconds-to-minutes. Right for "wait for deploy".
   - ScheduleWakeup: time-driven, fires once at delaySeconds, brings back the prompt. Right when there's a known wait but the bash check isn't ergonomic.
