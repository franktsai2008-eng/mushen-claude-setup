#!/bin/bash
# UserPromptSubmit hook — auto-recall trigger

set -uo pipefail

INPUT=$(cat)
KEYWORDS_FILE="$HOME/.claude/auto-recall-keywords.txt"
LOG_FILE="$HOME/.claude/logs/auto-recall.log"
mkdir -p "$(dirname "$LOG_FILE")"

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
[ -z "$PROMPT" ] && exit 0

case "$PROMPT" in
  "<observed_from_primary_session>"*|"Hello memory agent"*|"--- MODE SWITCH:"*) exit 0 ;;
esac

PROMPT_LC=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

[ -f "$KEYWORDS_FILE" ] || exit 0

MATCHED=""
while IFS= read -r kw; do
  [[ -z "${kw// }" || "$kw" =~ ^[[:space:]]*# ]] && continue
  kw_trim=$(echo "$kw" | sed 's/[[:space:]]*$//')
  [ -z "$kw_trim" ] && continue
  if echo "$PROMPT_LC" | grep -qF "$(echo "$kw_trim" | tr '[:upper:]' '[:lower:]')"; then
    MATCHED="$kw_trim"
    break
  fi
done < "$KEYWORDS_FILE"

[ -z "$MATCHED" ] && exit 0

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") matched='$MATCHED' prompt_first_60='${PROMPT:0:60}'" >> "$LOG_FILE"

HINT="🧠 **Auto-recall hint** — User's prompt contains \"${MATCHED}\".

Before answering, consider:
1. Memory file \`~/.claude/projects/-home-\$(whoami)/memory/MEMORY.md\`
2. claude-mem observations (use smart_search or get_observations for older entries)
3. Pinecone long-term memory — use the \`pinecone-curator\` agent on \`{your-pinecone-index}\` namespace \`default\`
4. Git history — \`git log --oneline -20\`
5. Project briefs — \`ls ~/.claude/project-briefs/\`

If after these you still don't know, ASK the user — don't guess."

jq -n --arg hint "$HINT" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $hint}}'

exit 0
