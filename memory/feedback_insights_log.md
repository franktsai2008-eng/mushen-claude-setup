---
name: Log real-use insights to docs/INSIGHTS.md
description: When working in an R&D playground and discovering non-obvious behavior worth carrying back to the SaaS, propose adding a numbered entry to docs/INSIGHTS.md.
type: feedback
---
When working in an R&D playground parallel to a SaaS, if a run, test, or experiment surfaces something **non-obvious** — LLM behavior we didn't expect, a schema field that's missing or misnamed, an edge case the prompt doesn't cover, a deterministic step that drifts in real conditions — propose adding a new numbered entry to `docs/INSIGHTS.md`. Use format: 發現於 (date + which skill/test) / 現象 / 根因 / 對 SaaS 的影響 / Action items.

**Why:** Skills R&D playgrounds parallel to SaaS — their biggest value isn't the code, it's the lived-experience insights that should eventually flow back to the SaaS schema, prompts, and product decisions. If they live only in chat history they evaporate.

**How to apply:**
- Trigger when a result surprises us in a way that has implications beyond just "fix this skill". Pure local bugs don't qualify; cross-cutting findings do.
- Don't silently write the entry — describe the proposed entry first and let the user confirm.
- Skip for routine wins. Only log things that would matter to someone reading this six months later.
- Keep dated structure with "對 SaaS 的影響" and "Action items" — those are the parts that justify the entry's existence.
