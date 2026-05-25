#!/usr/bin/env bash
# Motion Claude Code Setup — One-shot installer
#
# 用法（Motion 端 Claude Code 會跑這個）:
#   1) git clone https://github.com/franktsai2008-eng/mushen-claude-setup ~/motion-claude-setup
#   2) bash ~/motion-claude-setup/INSTALL.sh
#
# 跑完後請 Claude Code 讀 AFTER-INSTALL.md，照著對話帶你過 API 設定。

set -euo pipefail

BUNDLE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="$(whoami)"
MEM_DIR="$HOME/.claude/projects/-home-${USER_NAME}/memory"
TS="$(date +%Y%m%d-%H%M%S)"

say() { printf "\033[1;36m▸ %s\033[0m\n" "$*"; }
ok()  { printf "\033[1;32m✓ %s\033[0m\n" "$*"; }
warn(){ printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }

say "Bundle: $BUNDLE"
say "Target user: $USER_NAME"
say "Memory dir: $MEM_DIR"
echo

# 1. 備份既有 ~/.claude/ 重要檔（如果有的話）
if [ -f "$HOME/.claude/CLAUDE.md" ] || [ -f "$HOME/.claude/settings.json" ]; then
  BAK="$HOME/.claude-backup-${TS}"
  mkdir -p "$BAK"
  [ -f "$HOME/.claude/CLAUDE.md" ]    && cp "$HOME/.claude/CLAUDE.md"    "$BAK/" && ok "backup CLAUDE.md → $BAK"
  [ -f "$HOME/.claude/settings.json" ] && cp "$HOME/.claude/settings.json" "$BAK/" && ok "backup settings.json → $BAK"
fi

# 2. 建目錄
mkdir -p "$HOME/.claude/hooks" "$HOME/.claude/skills" "$MEM_DIR"
ok "Created ~/.claude/{hooks,skills} + $MEM_DIR"

# 3. 複製全域檔案
cp "$BUNDLE/CLAUDE.md"               "$HOME/.claude/CLAUDE.md"
cp "$BUNDLE/settings.json"           "$HOME/.claude/settings.json"
cp "$BUNDLE/auto-recall-keywords.txt" "$HOME/.claude/"
cp "$BUNDLE/compaction-context.md"   "$HOME/.claude/"
ok "Installed CLAUDE.md / settings.json / auto-recall-keywords.txt / compaction-context.md"

# 4. Hooks
cp "$BUNDLE/hooks/"*.sh "$HOME/.claude/hooks/"
chmod +x "$HOME/.claude/hooks/"*.sh
ok "Installed 7 hooks (chmod +x done)"

# 5. Skills (optional — not bundled in repo to keep clone fast)
if [ -d "$BUNDLE/skills" ] && [ "$(ls -A "$BUNDLE/skills" 2>/dev/null)" ]; then
  cp -r "$BUNDLE/skills/"* "$HOME/.claude/skills/" 2>/dev/null || true
  SKILL_COUNT="$(ls "$HOME/.claude/skills/" 2>/dev/null | wc -l | tr -d ' ')"
  ok "Installed $SKILL_COUNT skills (from local bundle)"
else
  SKILL_COUNT=0
  warn "Skills not in this clone — they're optional and can be added later."
  warn "Ask Frank for the skills tarball if you want them, or install individually from their sources."
fi

# 6. Memory (universal engineering lessons)
cp -r "$BUNDLE/memory/"* "$MEM_DIR/"
MEM_COUNT="$(ls "$MEM_DIR/" 2>/dev/null | wc -l | tr -d ' ')"
ok "Installed $MEM_COUNT memory files → $MEM_DIR"

# 7. 標記 install 完成
cat > "$HOME/.claude/.motion-bundle-installed" <<EOF
installed_at: $TS
bundle_path: $BUNDLE
user: $USER_NAME
memory_dir: $MEM_DIR
skills_count: $SKILL_COUNT
memory_count: $MEM_COUNT
EOF
ok "Installation marker written"

echo
say "════════════════════════════════════════════════"
say "  Bundle installed. Next step:"
say "  ► 把 AFTER-INSTALL.md 貼給 Claude Code，他會帶你過剩下的 API 設定"
say "  ► 路徑: $BUNDLE/AFTER-INSTALL.md"
say "════════════════════════════════════════════════"
