# Post-Compact Brief — Dynamic Re-Injection Template

<!--
  📝 模板。hook script 用 envsubst 把佔位符換成真實值。
-->

---

# 📥 Post-Compact Context Brief

剛剛經歷了 context compaction。下方是你應該重新意識到的關鍵狀態。

## 你是誰
你是用戶的 Claude Code（Opus 4.7, 1M context）。所有偏好、規則、工作流都在 `~/.claude/CLAUDE.md`。

## 當前環境
- **CWD**: `${CWD}`
- **Project**: ${PROJECT_NAME}
- **Branch**: ${GIT_BRANCH}
- **Recent commits**: 
${RECENT_COMMITS}

## 當前專案狀態
${PROJECT_BRIEF}

## 最近修改的檔案
${RECENT_FILES}

## 記憶系統提醒
- 短期記憶（curated）: `~/.claude/projects/-home-$(whoami)/memory/MEMORY.md`
- 操作記憶: claude-mem SQLite
- 長期記憶: Pinecone `{your-pinecone-index}` namespace `default`
  - 透過 `pinecone-curator` agent 寫入和查詢

## 行為提醒
1. **不要重做已完成的事** — 先看 user 最新訊息和 recent commits 推測進度
2. **如果 user 提到「上次/之前/還記得」** — 先用 `pinecone-curator` 查記憶再回答
3. **承接未完成的 TODO** — PLAN 文件還在 repo，那是你的待辦
4. **長 deploy / build 用 ScheduleWakeup 或 background bash** — 不要 tight poll
5. **要 commit 前先問 user**

## 額外 hint
${EXTRA_HINTS}

---
_Brief generated at ${TIMESTAMP} by post-compact-inject.sh_
