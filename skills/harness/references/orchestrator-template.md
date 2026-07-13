# Orchestrator 技能範本

Orchestrator 是協調整個團隊的上層 skill。依照執行模式，提供 3 種範本：

- **範本 A：Agent Team 模式（預設）** - 2 人以上協作時的最優先選擇
- **範本 B：Subagent 模式（替代方案）** - 不需要團隊通訊時使用
- **範本 C：Hybrid 模式** - 可在各 Phase 間混合不同模式

---

## 範本 A：Agent Team 模式（預設，最優先選擇）

當 2 位以上 agent 協作時，**最先評估的預設模式**。使用 `TeamCreate` 建立團隊，並透過共享工作清單與 `SendMessage` 進行協調。

```markdown
---
name: {domain}-orchestrator
description: "{領域} Agent Team 的協調 orchestrator。{初次執行關鍵字}。後續工作：當請求修改 {領域} 結果、局部重跑、更新、補強、重新執行，或改善先前結果時，也一定要使用這個 skill。"
---

# {Domain} Orchestrator

協調 {領域} 的 Agent Team，產出 {最終產出物} 的整合 skill。

## 執行模式：Agent Team

## Agent 組成

| 團隊成員 | Agent 類型 | 角色 | Skill | 輸出 |
|------|-------------|------|------|------|
| {teammate-1} | {自訂或內建} | {角色} | {skill} | {output-file} |
| {teammate-2} | {自訂或內建} | {角色} | {skill} | {output-file} |
| ... | | | | |

## 工作流程

### Phase 0: 確認 context（支援後續工作）

確認是否已有既有產出物，並據此決定執行模式：

1. 確認 `_workspace/` 目錄是否存在
2. 決定執行模式：
   - **`_workspace/` 不存在** → 初次執行。進入 Phase 1
   - **`_workspace/` 存在 + 使用者要求局部修改** → 局部重跑。只重新呼叫對應的 agent，並且只覆寫既有產出中需要修改的部分
   - **`_workspace/` 存在 + 提供了新的輸入** → 全新執行。先將既有 `_workspace/` 移到 `_workspace_{YYYYMMDD_HHMMSS}/`，再進入 Phase 1
3. 局部重跑時：在 agent prompt 中附上先前產出物的路徑，指示 agent 讀取既有結果並反映回饋

### Phase 1: 準備
1. 分析使用者輸入 — {要釐清的內容}
2. 在工作目錄中建立 `_workspace/`
   - **初次執行**：建立新的 `_workspace/`
   - **全新執行**：將既有 `_workspace/` 移到 `_workspace_{YYYYMMDD_HHMMSS}/` 後，重新建立新的 `_workspace/`
3. 將輸入資料存入 `_workspace/00_input/`

### Phase 2: 建立團隊

1. 建立團隊：
   ```
   TeamCreate(
     team_name: "{domain}-team",
     members: [
       { name: "{teammate-1}", agent_type: "{type}", model: "opus", prompt: "{角色說明與工作指示}" },
       { name: "{teammate-2}", agent_type: "{type}", model: "opus", prompt: "{角色說明與工作指示}" },
       ...
     ]
   )
   ```

2. 註冊任務：
   ```
   TaskCreate(tasks: [
     { title: "{任務1}", description: "{細節}", assignee: "{teammate-1}" },
     { title: "{任務2}", description: "{細節}", assignee: "{teammate-2}" },
     { title: "{任務3}", description: "{細節}", depends_on: ["{任務1}"] },
     ...
   ])
   ```

   > 每位團隊成員分配 5 到 6 個任務最合適。有依賴關係的任務請用 `depends_on` 明確標示。

### Phase 3: {主要工作，例如：研究 / 生成 / 分析}

**執行方式：** 團隊成員自行協調

團隊成員從共享任務清單中認領工作（claim），並各自獨立執行。
Leader 監控進度，必要時再介入。

**團隊成員間的通訊規則：**
- {teammate-1} 透過 SendMessage 將 {某些資訊} 傳給 {teammate-2}
- {teammate-2} 完成任務後，將結果存成檔案並通知 Leader
- 若團隊成員需要其他成員的結果，就用 SendMessage 發出請求

**產出物儲存：**

| 團隊成員 | 輸出路徑 |
|------|----------|
| {teammate-1} | `_workspace/{phase}_{teammate-1}_{artifact}.md` |
| {teammate-2} | `_workspace/{phase}_{teammate-2}_{artifact}.md` |

**Leader 監控：**
- 團隊成員進入閒置狀態時，自動接收通知
- 特定成員卡住時，用 SendMessage 下達指示或重新分派任務
- 用 TaskGet 確認整體進度

### Phase 4: {後續工作，例如：驗證 / 整合}
1. 等待所有團隊成員完成任務（用 TaskGet 確認狀態）
2. 用 Read 收集各成員的產出物
3. {整合 / 驗證邏輯}
4. 生成最終產出物：`{output-path}/{filename}`

### Phase 5: 收尾
1. 向團隊成員發送結束請求（SendMessage）
2. 清理團隊（TeamDelete）
3. 保留 `_workspace/` 目錄（不要刪除中間產出物，供後續驗證與稽核追蹤）
4. 向使用者回報結果摘要

> **若需要重組團隊：** 如果不同 Phase 需要不同的專家組合，先用 TeamDelete 清理目前團隊，再用新的 TeamCreate 為下一個 Phase 組隊。前一個團隊的產出物會保留在 `_workspace/`，因此新團隊可以透過 Read 存取。

## 資料流

```
[Leader] → TeamCreate → [teammate-1] ←SendMessage→ [teammate-2]
                          │                           │
                          ↓                           ↓
                    artifact-1.md              artifact-2.md
                          │                           │
                          └───────── Read ────────────┘
                                     ↓
                              [Leader: 整合]
                                     ↓
                              最終產出物
```

## 錯誤處理

| 情況 | 策略 |
|------|------|
| 1 位團隊成員失敗 / 中止 | Leader 偵測到後 → 用 SendMessage 確認狀態 → 重新啟動或建立替代成員 |
| 超過半數團隊成員失敗 | 告知使用者並確認是否繼續 |
| Timeout | 使用目前為止已收集的部分結果，並結束未完成的成員 |
| 團隊成員之間資料衝突 | 標明來源後並列保留，不刪除 |
| 任務狀態延遲 | Leader 用 TaskGet 確認後，手動執行 TaskUpdate |

## 測試情境

### 正常流程
1. 使用者提供 {輸入}
2. 在 Phase 1 得出 {分析結果}
3. 在 Phase 2 建立團隊（{N} 位成員 + {M} 個任務）
4. 在 Phase 3 由團隊成員自行協調並執行工作
5. 在 Phase 4 整合產出物並生成最終結果
6. 在 Phase 5 清理團隊
7. 預期結果：產生 `{output-path}/{filename}`

### 錯誤流程
1. 在 Phase 3 中，{teammate-2} 因錯誤而中止
2. Leader 收到閒置通知
3. 用 SendMessage 確認狀態 → 嘗試重新啟動
4. 若重啟失敗，將 {teammate-2} 的工作改派給 {teammate-1}
5. 以其餘結果進入 Phase 4
6. 在最終報告中註明「{teammate-2} 區塊部分資料未收集」
```

---

## 範本 B：Subagent 模式（替代方案）

適用於不需要團隊通訊成本的情況。直接使用 `Agent` 工具呼叫，並從回傳值蒐集結果。

```markdown
---
name: {domain}-orchestrator
description: "{領域} agent 的協調 orchestrator。{初次執行關鍵字}。包含後續工作關鍵字。"
---

## 執行模式：Subagent

## Agent 組成

| Agent | subagent_type | 角色 | Skill | 輸出 |
|---------|--------------|------|------|------|
| {agent-1} | {內建或自訂} | {角色} | {skill} | {output-file} |
| {agent-2} | ... | ... | ... | ... |

## 工作流程

### Phase 0: 確認 context
（與 Template A 相同，依 `_workspace/` 是否存在分流）

### Phase 1: 準備
1. 分析輸入
2. 建立 `_workspace/`（初次執行時建立，或在全新執行時先將既有 `_workspace/` 移到封存目錄後再建立）

### Phase 2: 平行執行
在單一訊息中同時呼叫 N 個 Agent 工具：

| Agent | 輸入 | 輸出 | model | run_in_background |
|---------|------|------|-------|-------------------|
| {agent-1} | {來源} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |
| {agent-2} | {來源} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |

### Phase 3: 整合
1. 收集各 agent 的返回值
2. 對於檔案型產出物，用 Read 收集
3. 套用整合邏輯 → 產生最終產出物

### Phase 4: 收尾
1. 保留 `_workspace/`
2. 回報結果摘要

## 錯誤處理
- 1 個 agent 失敗：重試 1 次。若再次失敗，標明缺漏後繼續
- 超過半數失敗：告知使用者並確認是否繼續
- Timeout：使用目前為止已收集的部分結果
```

---

## 範本 C：Hybrid 模式

在不同 Phase 使用不同執行模式。需在各 Phase 標題上方標註 `**執行模式:** {團隊 | 子代理}`。

```markdown
---
name: {domain}-orchestrator
description: "{領域} orchestrator（Hybrid）。{關鍵字}。包含後續工作關鍵字。"
---

## 執行模式：Hybrid

| Phase | 模式 | 原因 |
|-------|------|------|
| Phase 2（平行收集） | Subagent | 獨立收集資料，不需要團隊通訊 |
| Phase 3（共識整合） | Agent Team | 需要討論與協調相互衝突的資料 |
| Phase 4（獨立驗證） | Subagent | 由 1 位 QA agent 進行客觀驗證 |

## 工作流程

### Phase 2: 平行收集資料
**執行模式：** Subagent

在單一訊息中用 Agent 工具平行呼叫 N 個 agent（`run_in_background: true`）。
各結果存到 `_workspace/02_{agent}_raw.md`。

### Phase 3: 以共識為基礎的整合
**執行模式：** Agent Team

1. 用 `TeamCreate` 建立整合團隊（editor + fact-checker + synthesizer）
2. 用 `TaskCreate` 分派任務，所有人都 Read Phase 2 的 `_workspace/02_*` 檔案
3. 團隊成員透過 `SendMessage` 討論互相衝突的資料，並以檔案為基礎整理出共識版本
4. 生成最終整合版 `_workspace/03_integrated.md`
5. 用 `TeamDelete` 清理團隊

### Phase 4: 獨立驗證
**執行模式：** Subagent

由單一 QA subagent 讀取 `_workspace/03_integrated.md` 作為輸入，產生驗證報告。
```

**Hybrid 切換規則：**
- 團隊 → 子代理：一定要先用 `TeamDelete` 清理團隊，再呼叫 Agent 工具
- 子代理 → 團隊：將 subagent 的檔案產出透過 Read 路徑提供給團隊成員
- 團隊 → 團隊：整理舊團隊後，再 `TeamCreate` 新團隊（每個 session 同時只能啟用 1 個團隊）

---

## 撰寫原則

1. **先明確標示執行模式** - 在 orchestrator 開頭標明「Agent Team」/「Subagent」/「Hybrid」其中之一。若是 Hybrid，必須提供各 Phase 模式表
2. **團隊模式需具體說明 TeamCreate/SendMessage/TaskCreate 用法** - 包含團隊組成、任務註冊、通訊規則
3. **Subagent 模式需完整標示 Agent 工具參數** - name、subagent_type、prompt、run_in_background、model
4. **檔案路徑必須明確** - 禁止相對路徑，需清楚以 `_workspace/` 為基準
5. **標示 Phase 間依賴關係** - 說明哪個 Phase 依賴哪個 Phase 的結果。Hybrid 尤其要強調模式切換點
6. **Error handling 要務實** - 不要假設「所有事情都會成功」
7. **必須提供測試情境** - 至少 1 個正常流程 + 1 個錯誤流程

## 撰寫 description 時的後續工作關鍵字

Orchestrator 的 description 不能只寫初次執行關鍵字。必須包含以下後續工作表達：

- 重新執行／再次執行／更新／修改／補強
- 「只重做 {domain} 的 {部分}」
- 「基於先前結果」、「改善結果」
- 與 domain 相關的日常請求（例如 launch strategy harness 可包含「launch」、「promotion」、「trending」等）

如果沒有後續關鍵字，第一次執行後這個 harness 實際上就會變成 dead code。

## 實際 Orchestrator 參考

Fan-out/Fan-in pattern 的 orchestrator 基本結構：
準備 → Phase 0（確認 context）→ TeamCreate + TaskCreate → N 位團隊成員平行執行 → Read + 整合 → 收尾。
請參考 `references/team-examples.md` 中的 research team 範例。
