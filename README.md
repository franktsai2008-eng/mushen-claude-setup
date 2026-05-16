# Mushen Claude Code Setup

Frank 整套 Claude Code 記憶系統 + skills 的乾淨副本，已清掉所有 Frank 個人/商業隱私資料。

---

## 🚀 一行安裝（給 Mushen）

**直接複製下面這段，貼給你的 Claude Code：**

```
請照這個 repo 幫我安裝整套設定：

1. git clone https://github.com/franktsai2008-eng/mushen-claude-setup ~/mushen-claude-setup
2. bash ~/mushen-claude-setup/INSTALL.sh
3. 跑完之後讀 ~/mushen-claude-setup/AFTER-INSTALL.md，照著裡面的腳本帶我完成剩下的設定（白話對話、一次一步、等我回應再進下一步）
```

Claude Code 會自動：
1. clone 這個 repo
2. 跑 `INSTALL.sh`（複製檔案到 `~/.claude/`、設好 hooks 權限）
3. 用白話跟你說裝了什麼
4. 帶你過 Pinecone / GitHub CLI / 試跑驗收

全程約 5–10 分鐘。

---

## 內容物

| 項目 | 用途 |
|---|---|
| `CLAUDE.md` | 全域行為規則（Pinecone auto-save、AgentCrow、HTML 自動判斷、GitHub CLI 優先、MCP→CLI 轉換）|
| `settings.json` | Claude Code 設定（hooks、permissions、enabledPlugins）|
| `memory/MEMORY.md` | 記憶 index（手寫摘要、session start 自動注入）|
| `memory/feedback_*.md` | 27 份通用工程經驗（Railway/Vercel/Clerk 陷阱、push/lint/deploy/handoff 等）|
| `memory/reference_*.md` | 1 份通用設計模式（terminal dashboard）|
| `hooks/` | 7 個 shell hook（AgentCrow inject、auto-format、dangerous-cmd guard、notify-done、post-compact、auto-recall）|
| `auto-recall-keywords.txt` | 中英文觸發詞用於 auto-recall hook |
| `compaction-context.md` | Post-compact 重新注入模板 |
| `skills/` | **(未包進此 repo)** Frank 有 36 個 skills，可選擇性。日後可單獨索取 |

---

## 已剔除的隱私資料

- Frank 個人/商業專案記憶（Cow AI / Creator Brain / Creator AI Workflow 等）
- Frank 銷售模型 / proposal 流程 / 設計偏好
- Hermes peer analyst 設定
- 所有 API key、token、credentials
- Frank Pinecone index 名（已替換成 `{your-pinecone-index}` 佔位符）
- Session 歷史、credentials.json、history.jsonl

---

## Mushen 收到後要做的事

安裝完 Claude Code 後，把最上面那段「一行安裝」貼給他，剩下他會帶你過：

1. **Pinecone**（你的跨對話長期記憶）— 開帳號、拿 API key、建 index
2. **GitHub CLI** — `gh auth login`
3. **試跑驗收** — 確認記憶系統有活、Pinecone 連得到

選配（之後需要時再開）：
- **Higgsfield**（AI 圖/影片生成）
- **AgentCrow plugin**（多 agent 分派）

---

問題隨時問 Frank。
