#!/bin/bash
# Guard against catastrophic Bash commands

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$CMD" ] && exit 0

if echo "$CMD" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+(/|~|\$HOME|/Users|/System|/Library|/etc|/var)\b'; then
  echo "BLOCKED: rm -rf on protected path" >&2
  exit 2
fi

if echo "$CMD" | grep -qE '^\s*sudo\s+rm\b'; then
  echo "BLOCKED: sudo rm is not allowed" >&2
  exit 2
fi

if echo "$CMD" | grep -qiE '(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE|DELETE\s+FROM\s+\w+\s*;)'; then
  echo "BLOCKED: destructive SQL detected" >&2
  exit 2
fi

if echo "$CMD" | grep -qE 'git\s+push\s+.*--force.*\s+(main|master)\b'; then
  echo "BLOCKED: force push to main/master" >&2
  exit 2
fi

exit 0
