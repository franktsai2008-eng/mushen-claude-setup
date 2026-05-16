#!/bin/bash
# macOS notification when Claude finishes work
terminal-notifier \
  -title "Claude Code" \
  -subtitle "Done" \
  -message "Finished in $(basename "$PWD")" \
  -sound default \
  -timeout 10 2>/dev/null || \
osascript -e "display notification \"Finished in $(basename "$PWD")\" with title \"Claude Code\" sound name \"Glass\"" 2>/dev/null

exit 0
