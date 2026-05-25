#!/bin/bash
# AgentCrow PreToolUse hook — auto-inject agent persona into subagent prompt
# Safe no-op if agentcrow command is not installed (so Agent dispatch still works).

INPUT=$(cat)

if command -v jq &>/dev/null; then
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
else
  if ! echo "$INPUT" | grep -q '"tool_name"[[:space:]]*:[[:space:]]*"Agent"'; then
    exit 0
  fi
  TOOL="Agent"
fi

[ "$TOOL" != "Agent" ] && exit 0

# If agentcrow isn't installed, skip silently — don't block the Agent call.
if ! command -v agentcrow &>/dev/null; then
  exit 0
fi

echo "$INPUT" | agentcrow inject 2>/dev/null
exit 0
