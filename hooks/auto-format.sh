#!/bin/bash
# Auto-format files after Claude edits them

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.css|*.json|*.md|*.html)
    if [ -f ./node_modules/.bin/prettier ]; then
      ./node_modules/.bin/prettier --write "$FILE" 2>/dev/null
    elif command -v npx &>/dev/null && [ -f ./package.json ]; then
      npx prettier --write "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
