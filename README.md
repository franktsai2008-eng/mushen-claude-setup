# Claude Code Setup（Frank 的個人化大腦設定包）

Frank 整套 Claude Code 記憶系統 + agents + hooks 的乾淨副本，已清掉所有 Frank 個人/商業隱私資料。給協作者 / 客戶當 Claude Code 個人化基底用。

---

## 🚀 一行安裝

**直接複製下面這段，貼給你的 Claude Code：**

```
請照這個 repo 幫我安裝整套設定：

1. git clone https://github.com/franktsai2008-eng/mushen-claude-setup ~/claude-setup
2. bash ~/claude-setup/INSTALL.sh
3. 跑完之後讀 ~/claude-setup/AFTER-INSTALL.md，照著裡面的腳本帶我完成剩下的設定（白話對話、一次一步、等我回應再進下一步）
```

Claude Code 會自動：
1. clone 這個 repo
2. 跑 `INSTALL.sh`（複製檔案到 `~/.claude/`、設好 hooks 權限、裝好 agents）
3. 用白話跟你說裝了什麼
4. 帶你過 Pinecone MCP 安裝 / GitHub CLI / 試跑驗收

全程約 10–15 分鐘。

---

## 內容物

| 項目 | 用途 |
|---|---|
| `CLAUDE.md` | 全域行為規則（Pinecone auto-save、AgentCrow、HTML 自動判斷、GitHub CLI 優先、MCP→CLI 轉換）|
| `settings.json` | Claude Code 設定（hooks、permissions、enabledPlugins）|
| `agents/pinecone-curator.md` | 記憶管家 subagent（負責 auto-save / auto-recall，CLAUDE.md 規定的所有 Pinecone 寫入都走他）|
| `memory/MEMORY.md` | 記憶 index（手寫摘要、session start 自動注入）|
| `memory/feedback_*.md` | 27 份通用工程經驗（Railway/Vercel/Clerk 陷阱、push/lint/deploy/handoff 等）|
| `memory/reference_*.md` | 1 份通用設計模式（terminal dashboard）|
| `hooks/` | 7 個 shell hook（AgentCrow inject、auto-format、dangerous-cmd guard、notify-done、post-compact、auto-recall）|
| `auto-recall-keywords.txt` | 中英文觸發詞用於 auto-recall hook |
| `compaction-context.md` | Post-compact 重新注入模板 |
| `skills/` | **(未包進此 repo)** Frank 有自己的 skills，可選擇性。日後可單獨索取 |

---

## 已剔除的隱私資料

- Frank 個人/商業專案記憶（Cow AI / Creator Brain / Creator AI Workflow / Motion / Mushen 等）
- Frank 銷售模型 / proposal 流程 / 設計偏好
- Hermes peer analyst 設定
- 所有 API key、token、credentials
- Frank Pinecone index 名（已替換成 `{YOUR_PINECONE_INDEX}` 佔位符，安裝最後一步會自動 sed 替換）
- Session 歷史、credentials.json、history.jsonl

---

## 收到後要做的事

`AFTER-INSTALL.md` 是給端點 Claude Code 的對話腳本，會帶用戶過：

1. **Pinecone**（你的跨對話長期記憶）— 開帳號 + 拿 API key + 寫進環境變數 + **`claude mcp add pinecone`** + 建 index + 替換占位符 + 試寫一筆驗證
2. **GitHub CLI** — `gh auth login`
3. **試跑驗收** — 4 個檢查：MEMORY 存在 / pinecone-curator agent 存在 / Pinecone MCP 連得到 / 占位符全清掉

選配（之後需要時再開）：
- **Higgsfield**（AI 圖/影片生成）
- **AgentCrow plugin**（多 agent 分派）

---

## 常見問題

**Q: 我已經有 `~/.claude/CLAUDE.md`，安裝會覆蓋掉嗎？**
A: 會。但 `INSTALL.sh` 會先備份到 `~/.claude-backup-<時間戳>/`。

**Q: Pinecone 一定要嗎？**
A: 不一定。沒裝 Pinecone 的話 auto-save / auto-recall 不會運作，但其他功能（記憶檔注入、hooks、AgentCrow）照常。

**Q: AgentCrow 一定要裝嗎？**
A: 不用。沒裝的話 PreToolUse hook 會自動跳過 inject 步驟（`agentcrow` 命令找不到就 no-op），Agent 派工照常運作。

**Q: 為什麼 repo 名稱是 mushen-claude-setup？**
A: 這個 repo 是 Frank 第一次打包送給 Mushen 時建的，後來變成通用 setup bundle，但 URL 沿用沒改。內容是 generic 的，可以給任何協作者 / 客戶用。

---

問題隨時問 Frank。
