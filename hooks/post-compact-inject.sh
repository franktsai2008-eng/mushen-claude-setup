#!/bin/bash
# PostCompact hook — re-inject dynamic context after Claude compresses history

set -uo pipefail

INPUT=$(cat)
TEMPLATE="$HOME/.claude/compaction-context.md"
BRIEF_DIR="$HOME/.claude/project-briefs"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/post-compact.log"

mkdir -p "$LOG_DIR" "$BRIEF_DIR"

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$CWD" ] && CWD="$PWD"

PROJECT_NAME=$(basename "$CWD")
GIT_BRANCH=$(cd "$CWD" 2>/dev/null && git branch --show-current 2>/dev/null || echo "(not a git repo)")
RECENT_COMMITS=$(cd "$CWD" 2>/dev/null && git log --oneline -3 2>/dev/null | sed 's/^/  - /' || echo "  (no commits)")

RECENT_FILES=$(cd "$CWD" 2>/dev/null && {
  changed=$(git status --short 2>/dev/null | head -10 | sed 's/^/  /')
  if [ -n "$changed" ]; then
    echo "$changed"
  else
    find . -maxdepth 3 -type f -mmin -120 \
      ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/.next/*' ! -path '*/__pycache__/*' \
      2>/dev/null | head -5 | sed 's/^/  - /' || echo "  (no recent changes)"
  fi
}) || RECENT_FILES="  (n/a)"
[ -z "$RECENT_FILES" ] && RECENT_FILES="  (no recent changes)"

PROJECT_BRIEF=""
if [ -f "$BRIEF_DIR/${PROJECT_NAME}.md" ]; then
  PROJECT_BRIEF=$(head -40 "$BRIEF_DIR/${PROJECT_NAME}.md")
elif [ -f "$CWD/CLAUDE.md" ]; then
  PROJECT_BRIEF=$(head -25 "$CWD/CLAUDE.md")
  PLAN=$(ls -t "$CWD"/PLAN-*.md 2>/dev/null | head -1)
  if [ -n "$PLAN" ]; then
    PROJECT_BRIEF="$PROJECT_BRIEF

**Active PLAN doc**: $(basename "$PLAN")
$(head -10 "$PLAN")"
  fi
else
  PROJECT_BRIEF="(no project brief found)"
fi

EXTRA_HINTS=""
if [ -d "$HOME/.claude/hints.d" ]; then
  for hint in "$HOME/.claude/hints.d"/*.sh; do
    [ -f "$hint" ] && [ -x "$hint" ] || continue
    out=$("$hint" "$CWD" 2>/dev/null) || true
    [ -n "$out" ] && EXTRA_HINTS+="
$out"
  done
fi
[ -z "$EXTRA_HINTS" ] && EXTRA_HINTS="(none)"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

export CWD PROJECT_NAME GIT_BRANCH RECENT_COMMITS RECENT_FILES PROJECT_BRIEF EXTRA_HINTS TIMESTAMP

if ! command -v envsubst &>/dev/null; then
  RENDERED=$(cat "$TEMPLATE" 2>/dev/null) || RENDERED="(template missing)"
else
  RENDERED=$(envsubst < "$TEMPLATE" 2>/dev/null) || RENDERED="(template render failed)"
fi

{
  echo "=== $TIMESTAMP ==="
  echo "CWD: $CWD / Project: $PROJECT_NAME / Branch: $GIT_BRANCH"
  echo "Bytes injected: $(echo -n "$RENDERED" | wc -c)"
} >> "$LOG_FILE"

jq -n --arg ctx "$RENDERED" '{hookSpecificOutput: {hookEventName: "PostCompact", additionalContext: $ctx}}'

exit 0
