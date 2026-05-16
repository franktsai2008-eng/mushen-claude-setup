---
name: chat-no-silent-tool-rule
description: When an LLM agent is wired to tools producing side effects, system prompt MUST require text reply alongside every tool call — otherwise UI shows "ghost responses".
type: feedback
---

When a system prompt says "do the side-effect via tool X" without also requiring a text reply, Claude treats the tool call as the complete response. From the chat UX side this looks like the bot ignored the user — even though work was done.

**Why:** Hit on a chat product. The prompt said "Do NOT inline a finished script in chat — write it to the script library." Claude obeyed: write_script() fired, the library got a new row, but the assistant message had zero text. UI rendered a tiny ⚙ chip with no body. Looked broken; was actually working-as-prompted.

**How to apply:** For any tool-using agent intended for human consumption (chat surface, not headless pipeline):

1. Add a hard rule in the system prompt: "**Every turn ends with a text reply.** Tool calls never replace acknowledgement. After any tool fires you MUST write a 1-2 sentence summary of what just happened and the next step."
2. In the UI, render tool calls as readable breadcrumbs (icon + label + key field) — not just `⚙ write_script`.
3. Prefer artifact-in-chat patterns over tool-only saves for human-iterable work (drafts, edits): output the artifact as a fenced JSON block the UI parses + renders as a card with explicit commit button.

This is the second class of silent-chat bug. The first was the [[claude-agent-sdk-non-root-in-containers]] CLI hard-stop (no text, no tools, exit 1). Both show up as "chat doesn't reply" — diagnose by hitting the SSE endpoint directly with curl: text events present? if no, infra problem (e.g. non-root). text events missing but tool_use events fire? then prompt steering tool-only turns.
