# Claude Code — Global Instructions

> 你的個人化全域規則。第一次使用時請把 `{YOUR_*}` 占位符替換成你自己的設定。

## Browser Control

如果你要用 browser-harness（CDP 控制本機 Chrome）：
- 安裝指引：`~/Developer/browser-harness/install.md`
- 用法參考：`~/Developer/browser-harness/SKILL.md`
- 用 `browser-harness -c '...'` 一行呼叫，daemon 自動啟動

不需要也可以跳過這節。

---

## Pinecone Memory — 統一長期記憶 (Auto-Save)

長期記憶寫入 Pinecone `{YOUR_PINECONE_INDEX}`（建議命名：你的代號或專案名，例如 `mushen`、`myname`）。
- Embedding 模型：llama-text-embed-v2
- fieldMap：`{text: "text"}`
- 建 index：`mcp__pinecone__create-index-for-model` 一次性建好

### Auto-Save Rules (全自動)

每次完成有意義工作後，**透過 `pinecone-curator` agent** upsert 一份摘要到你的 index：

**觸發條件（任一符合就存）:**
- 做了架構決策、技術選擇
- 完成非 trivial 的 coding session (5+ 動作)
- 學到新東西（新 API、新 bug 解法、新 pattern）
- 用戶的偏好/環境發生改變
- 完成 deploy、檔案建立、重大設定變更

**存檔格式 (扁平 fields · NO `metadata:` wrapper):**
```
index: {YOUR_PINECONE_INDEX}
namespace: default
_id: {YYYY-MM-DD}-{topic-slug}
text: 結構化摘要 (決策+產出+發現，4000 字內)
title: 一句話主題
date: YYYY-MM-DD
type: session | decision | signal | reference
agent: claude
topic: 主題關鍵字（空格分隔）
project: <repo-name | personal>
```

**不要存:** task progress、臨時檔案路徑、純 CLI 操作、已在 CLAUDE.md 的靜態規則

### Auto-Recall

當用戶提到過去的事，**先用 `pinecone-curator` agent** 查 `{YOUR_PINECONE_INDEX}` namespace `default`（語意搜尋 + rerank），再去查本機 MEMORY.md / git log。

### 記憶層分工

- **claude-mem 本機 SQLite**: operational — 每次 session/tool call 自動記，session start 自動注入最近 50 條
- **Pinecone**: strategic — 跨會議、跨機器、語意可搜的決策 / 硬規則 / 產品架構
- **MEMORY.md + ~/.claude/projects/-home-$(whoami)/memory/*.md**: curated — 手寫的 feedback / project / reference 檔，session start 強制注入，最高優先級

---

## AgentCrow — Auto Agent Dispatch

需要先安裝 AgentCrow plugin（見 README）。

1. For complex requests (2+ tasks), read .claude/agents/INDEX.md to find matching agents, then dispatch using the Agent tool.
2. Dispatch at most **5 agents** at a time.
3. Dispatch independent tasks in parallel, dependent ones sequentially.
4. Do not ask questions. Make decisions and proceed.
5. Before dispatching, show the plan in format: `━━━ 🐦 AgentCrow ━━━ N agents: @role → task`
6. Simple requests (bug fixes, single file edits) — handle directly.
7. After all agents complete: `━━━ 🐦 AgentCrow complete ━━━`

Role Emojis: 🖥️ frontend · 🏗️ backend · 🧪 qa · 🛡️ security · ⚙️ devops · 🤖 ai · 📊 data

---

## Context Management Rules

1. **Prefer delegation.** Every delegated task saves you 5-50 turns of Opus context.
2. **Compress early.** If you're approaching the token limit, summarize and delegate downstream work.
3. **One-thing-at-a-time.** Don't try to solve everything in one session. Break work into focused sessions.
4. **Use the right tool.** Opus = thinking, not fetching data or repetitive operations.

---

## Output Format: HTML vs Markdown — 自動判斷

不需要用戶手動指定格式。**你根據以下規則自己判斷**，選擇 Markdown 或 HTML 輸出。

### 自動選 HTML 的情境

當輸出符合以下**任一條件**時，產出 single-file HTML（inline CSS/JS，可直接用瀏覽器開啟）：

- **複雜結構**：內容有 3+ 章節，需要目錄/錨點導航、可折疊區塊
- **視覺層級**：需要顏色編碼（嚴重等級、風險高低）、並排比較、卡片式呈現
- **Code Review**：需要標注 diff、顏色區分嚴重度、行內註解
- **實作計畫**：需要 mockup、資料流圖、架構圖（SVG 內嵌）
- **互動需求**：需要 slider/切換/過濾/搜尋/一鍵複製等 UI 元件
- **報告/儀表板**：需要 summary card、進度條、狀態標示

### 自動選 Markdown 的情境

- 簡短問答（< 20 行）
- 機器需解析的輸出
- 最終要進 Git 的文件（README、CHANGELOG、docs）
- 純程式碼產出（`.py`, `.ts`, `.json` 等原始檔）
- Headless 環境輸出
- 結構化資料（JSON、CSV、表格為主的純資料）

### 判斷邏輯（優先序）

1. 是 code file？→ 原始格式
2. 是結構化資料？→ JSON/CSV
3. 是簡短回答？→ Markdown
4. 目標是人閱讀 + 內容複雜？→ HTML
5. 不確定？→ 預設 HTML

---

## GitHub: CLI 優先，MCP 備用

**層級原則：所有工具都是 CLI → MCP → API 的降級順序**

GitHub 操作：
1. 先用 `gh` CLI（需先 `gh auth login`）
2. `gh` 做不到 → 才用 GitHub MCP

---

## MCP → CLI Auto-Convert

**原則**: 每次成功用某個 MCP/API，自動評估是否可轉成 CLI + skill。

**步驟**:
1. 判斷有 CLI 替代 → 直接用（如 gh、playwright CLI）
2. 無 CLI 替代 → 包成最小 Python/Go wrapper
3. 寫成 skill file → `~/.claude/skills/{name}.md`
4. Pinecone 記憶成功 pattern
5. 下次遇到同樣需求 → 優先 CLI + skill
