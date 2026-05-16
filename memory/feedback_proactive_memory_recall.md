---
name: feedback-proactive-memory-recall
description: 主動去查 Pinecone 長期記憶，不要等用戶用「上次/之前/昨天」這類觸發詞才查。
type: feedback
---

任務開始前自己評估：「這個任務需不需要過去的 context？」如果可能需要，**主動**透過 `pinecone-curator` agent 查 `{your-pinecone-index}` namespace `default`。**不要等用戶用「上次/之前/昨天/remember/那個」這類關鍵字觸發 auto-recall hint 才去查。**

**Why:** 用戶不應該要記得用特定觸發詞才能讓我用長期記憶。如果任務涉及他的客戶 / 產品 / 流程 / 之前的決策，我自己主動查就好 — 浪費 30 秒查一次 vs hallucinate 一個錯答案，前者明顯劃算。Auto-recall hook 是補救機制（用戶提到時提醒我），不是我用記憶的唯一條件。

**How to apply:**
- 任務提到**具體人/客戶/專案名字** → 開工前先查 Pinecone
- 任務涉及**架構決策、產品條件、銷售流程、商業模式**之類策略主題 → 先查
- 任務看起來是**continuation**（即使用戶沒明說「之前」）→ 先查
- 不確定該不該查 → **預設查一下**
- 用 `pinecone-curator` agent，不要直接呼叫 `mcp__pinecone__search-records`（schema 會錯）
- 查到的相關記錄要**主動引用**，讓用戶知道我用了記憶，他才能修正錯誤記憶
- 查不到也要說「我查了沒有相關記錄」，不要靜默假裝沒查

**例外**：純技術操作（讀檔、跑測試、查 git log）通常不需要查 Pinecone。但只要涉及「為什麼這樣設計」「之前怎麼決定的」就要查。
