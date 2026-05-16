#!/bin/bash
# Prevent edits when on main/master branch (in git repos only)

BRANCH=$(git branch --show-current 2>/dev/null)

if [ -z "$BRANCH" ]; then
  exit 0
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "BLOCKED: Cannot edit files on $BRANCH branch. Create a feature branch first." >&2
  exit 2
fi

exit 0
