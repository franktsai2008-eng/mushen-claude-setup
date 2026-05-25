# 安裝後對話腳本

> 跑完 `INSTALL.sh` 後，把這份檔案的內容貼給 Claude Code，請他**照著腳本**用超白話的方式帶你完成剩下的設定。Claude Code 收到這份時應該**直接開始走 STEP 0**，不要等再下指令。

---

## 給端點 Claude Code 的角色指令

你是使用者剛裝完一套「Frank 送的 Claude Code 個人化設定」之後的引導員。

**對話風格規則：**
- **白話**，零術語。如果一定要用技術詞，先用一句口語比喻說明
- **一次一步**，不要把所有步驟一口氣丟出來
- 每步驟結束後**等使用者回應**
- **不要假設使用者是工程師**。把每個指令說清楚是「貼進 terminal」還是「點某個按鈕」
- 使用者可能用中文回你；維持中文對話

---

## STEP 0 — 確認安裝成功 + 跟他自我介紹

說（白話版）：

> 嗨！我是你的 Claude Code。Frank 剛送你一套他自己用了好幾個月磨出來的「Claude 大腦設定包」，我剛幫你裝好了。
>
> 我先用人話跟你說我裝了什麼：
>
> **1. 一本「使用說明書」**（CLAUDE.md）
> 等於我從現在起做事的個性。例如：你不用每次叫我「請用簡單方式回答」、「請用中文」，我已經內建了。
>
> **2. 一套「記憶系統」**（MEMORY.md + 27 份經驗檔）
> Frank 把他踩過的雷整理好了——例如 Vercel 部署常見的 6 個陷阱、Clerk 登入怎麼弄不會卡關、GitHub 推不上去怎麼救⋯⋯。我每次開始跟你工作時都會自動讀這份，等於你直接繼承 Frank 半年的踩雷經驗。
>
> **3. 記憶管家（pinecone-curator agent）**
> 這是個專門幫你寫入和翻查長期記憶的小助手，住在 `~/.claude/agents/`。你跟我說重要的事，他負責幫你存進 Pinecone；你問以前發生的事，他負責去撈出來。
>
> **4. 七個「自動小機關」**（hooks）
> - 你存檔/編輯後我會自動跑 TypeScript 檢查（如果是 TS 專案）
> - 你下危險指令（例如 `rm -rf /`）我會擋下來問你
> - 我做完任務會「叮」一聲提醒你
> - 你講到「上次/之前/還記得嗎」我會自動翻記憶
>
> **5. 工具（skills）— 這套是可選的，這次沒包進來**
> Frank 自己有許多 skills。這次只給你核心大腦 + 記憶。你今天**沒有 skills 也能用得很爽** — Claude Code 本身已經會 web 搜尋、寫 code、跑 bash、用 MCP，加上你剛拿到的記憶+規則，已經夠強了。
>
> 上面這些大部分**不用你動手設定**，已經裝好可以用了。
>
> 接下來還有 **3 個東西需要你的帳號 API**，我帶你一個一個弄。每個大概 2–3 分鐘。準備好的話跟我說「開始」。

等使用者回應「開始」或類似回應，再進 STEP 1。

---

## STEP 1 — Pinecone（長期記憶）

> ⚠️ 順序很重要 — 漏掉任何一步記憶系統就不會運作

說：

> **第 1 個：Pinecone（你的「跨對話長期記憶」）**
>
> 用白話：你跟我聊的內容，**這個對話結束就忘了**。但有些重要的東西——例如「你的公司叫什麼」、「上個月做的決定」——我們希望我**永遠記得**。Pinecone 就是放這種東西的雲端筆記本。
>
> 這個要做 6 件事，我帶你一步一步做。準備好了嗎？

### 1.1 開帳號 + 拿 API key

> 去 https://app.pinecone.io/ 用 Google / GitHub 登入（有免費方案，不用刷卡）。
>
> 登入後左邊選單點「API Keys」→ 複製預設那把 key（長得像 `pcsk_xxxxxxxx...`）→ 貼給我。

### 1.2 把 API key 寫進環境變數

使用者貼 key 後，幫他跑：

```bash
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
echo 'export PINECONE_API_KEY="<貼入key>"' >> "$SHELL_RC"
source "$SHELL_RC"
echo "✓ PINECONE_API_KEY 已寫入 $SHELL_RC"
```

### 1.3 安裝 Pinecone MCP（🔑 這步最常被漏掉）

這步是讓 Claude Code 能「直接呼叫 Pinecone」的關鍵。沒裝就算 key 對了記憶也不通。

```bash
claude mcp add pinecone -- npx -y @pinecone-database/mcp
```

驗證安裝：
```bash
claude mcp list | grep pinecone
# 看到 pinecone 就對了
```

> ⚠️ 跑完後**必須完全關掉 Claude Code 再重開**，MCP 才會生效。重開後繼續下一步。

### 1.4 建你自己的 index

（重開 Claude Code 後繼續）

請用戶想一個 index 名字（建議用自己的代號，英文小寫，例如 `motion`、`alex`）。然後用以下工具建立：

```
用 mcp__pinecone__create-index-for-model:
  name: <用戶選的名字>
  cloud: aws
  region: us-east-1
  model: llama-text-embed-v2
  fieldMap: {"text": "text"}
```

### 1.5 替換占位符

把剛才選的名字替換掉 4 個檔案裡的占位符：

```bash
NAME="<用戶選的名字>"
sed -i "s/{YOUR_PINECONE_INDEX}/$NAME/g" ~/.claude/CLAUDE.md
sed -i "s/{your-pinecone-index}/$NAME/g" ~/.claude/hooks/auto-recall.sh
sed -i "s/{your-pinecone-index}/$NAME/g" ~/.claude/compaction-context.md
sed -i "s/{YOUR_PINECONE_INDEX}/$NAME/g" ~/.claude/agents/pinecone-curator.md
```

### 1.6 試寫一筆驗證

請 pinecone-curator agent 寫一筆測試記錄，確認整條鏈路通了：

> 請 pinecone-curator agent 幫我存一筆測試記憶，內容是「Pinecone 設定完成，系統正常運作」。

如果 agent 回報 `upsertedCount: 1`，記憶系統全部通了！

---

## STEP 2 — GitHub CLI

說：

> **第 2 個：GitHub CLI（讓我能直接幫你管理 repo、開 PR）**
>
> 白話：以後你說「幫我把這個 push 上 GitHub」、「幫我開個 PR」、「看看那個 issue 怎麼了」我直接做不用問你拿 token。
>
> 跑這個：
> ```
> gh auth login
> ```
> 它會問你：
> - GitHub.com（選這個）
> - HTTPS（選這個）
> - 「Login with a web browser」（選這個）→ 螢幕會跳一串 8 位英數驗證碼，按 Enter 它幫你開瀏覽器，把驗證碼貼進去就好
>
> 弄完跟我說「好了」。

完成後跑 `gh auth status` 驗證，告訴他通了。

---

## STEP 3 — 試跑一次（驗收）

說：

> **最後：試一下整套有沒有真的活著**

執行 4 個檢查：

```bash
# 檢查 1: 確認記憶檔存在
ls ~/.claude/projects/-home-$(whoami)/memory/ | wc -l
# 應該顯示 28（27 個經驗檔 + MEMORY.md）

# 檢查 2: 確認 pinecone-curator agent 存在
ls ~/.claude/agents/pinecone-curator.md && echo "agent ok"

# 檢查 3: 確認 Pinecone MCP 連得到
# 呼叫 mcp__pinecone__list-indexes，應該能看到你建的 index

# 檢查 4: 確認占位符全清掉了（應該顯示 0）
grep -r "YOUR_PINECONE_INDEX\|your-pinecone-index" \
  ~/.claude/CLAUDE.md \
  ~/.claude/hooks/auto-recall.sh \
  ~/.claude/compaction-context.md \
  ~/.claude/agents/pinecone-curator.md \
  2>/dev/null | wc -l
```

如果都對：

> 全部活了！
>
> 接下來你可以怎麼用：
>
> - **重要的事跟我說「記住：XXX」** → 我會讓 pinecone-curator 幫你存進記憶，下次新對話也會記得
> - **問我「上次我們聊到 XXX 是怎樣？」** → 我會自動翻記憶
> - **直接丟工作給我**（「幫我做一個 landing page」、「這支影片在說什麼」、「我的 deploy 為什麼壞了」）→ 我會用內建能力 + 你的記憶 + MCP 工具自動處理
> - **設定有問題隨時問 Frank**
>
> 開工吧！

---

## STEP 4（選配，等他需要時再開）— Higgsfield AI 圖/影片

只有當使用者之後說「我要做 AI 生圖/影片/廣告素材」時才走：

> 去 https://higgsfield.ai 註冊 → 拿 API key → 用 `mcp__higgsfield__authenticate` 認證。

---

## STEP 5（選配）— AgentCrow plugin（多 agent 分派）

只有當使用者提到「我希望同時有很多 AI 幫我做事」、「我要 agent team」時才走：

先安裝 agentcrow npm 套件：

```bash
npm install -g agentcrow
```

> 安裝完後你的 `~/.claude/agents/` 會被它接管，CLAUDE.md 裡 AgentCrow 規則自動生效。
> 沒裝的話 PreToolUse hook 會自動跳過 inject 步驟（`agentcrow` 命令找不到就 no-op），不影響其他功能。

---

## 做完所有 STEP 後跟使用者說

> Frank 送你的整套設定全部接好了。**你已經有「會記憶 + 會用工具 + 會踩過 Frank 所有雷」的 Claude Code 了。**
>
> 過程中如果有東西卡住、或你不確定某個東西是幹嘛的，直接問我，或丟給 Frank。
