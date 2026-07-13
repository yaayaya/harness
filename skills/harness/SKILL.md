---
name: harness
description: "建構 Harness。這是一個定義專業 agent 並建立該 agent 所使用 skill 的 meta-skill。適用於：(1) 收到「幫我配置 Harness」、「幫我建立 Harness」請求時，(2) 收到「Harness 設計」、「Harness 工程」請求時，(3) 要為新領域/新專案建立以 Harness 為基礎的自動化體系時，(4) 要重構或擴充 Harness 配置時，(5) 收到「檢查 Harness」、「審核 Harness」、「Harness 現況」、「agent/skill 同步」等既有 Harness 營運/維護請求時使用。"
---

# Harness — Agent Team & Skill Architect

針對對應領域/專案配置 Harness，定義各 agent 的角色，並建立 agent 會使用的 skill 的 meta-skill。

**核心原則：**
1. 建立 agent 定義（`.claude/agents/`）與 skill（`.claude/skills/`）。
2. **將 Agent Teams 作為預設執行模式。**
3. **在 CLAUDE.md 註冊 Harness 指標。** — 只記錄最小必要的指標（觸發規則 + 變更歷程），讓新的 session 能觸發 orchestrator skill。
4. **Harness 不是固定不變的成品，而是持續演化的系統。** — 每次執行後都納入回饋，持續更新 agent、skill 與 CLAUDE.md。

## 工作流程

### Phase 0: 現況稽核

當 Harness skill 被觸發時，首先要檢查既有 Harness 現況。

1. 讀取 `專案/.claude/agents/`、`專案/.claude/skills/`、`專案/CLAUDE.md`
2. 根據現況切分執行模式：
   - **新建**：agent/skill 目錄不存在或為空 → 從 Phase 1 開始完整執行
   - **既有擴充**：既有 Harness 存在，且收到新增 agent/skill 的請求 → 依下方 Phase 選擇矩陣，只執行需要的 Phase
   - **營運/維護**：既有 Harness 的稽核、修正、同步請求 → 移動到 Phase 7-5 營運/維護工作流程

   **既有擴充時的 Phase 選擇矩陣：**
   | 變更類型 | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Phase 6 |
   |----------|---------|---------|---------|---------|---------|---------|
   | 新增 agent | 跳過（使用 Phase 0 結果） | 只決定配置 | 必要（含 3-0） | 僅在需要專屬 skill 時（含 4-0） | 修改 orchestrator | 必要 |
   | 新增/修改 skill | 跳過 | 跳過 | 跳過 | 必要（含 4-0） | 僅在連結有變更時 | 必要 |
   | 架構變更 | 跳過 | 必要 | 只處理受影響 agent（含 3-0） | 只處理受影響 skill（含 4-0） | 必要 | 必要 |
3. 比對既有 agent/skill 清單與 CLAUDE.md 紀錄，偵測不一致（drift）
4. 向使用者摘要報告稽核結果，並確認執行計畫

### Phase 1: 領域分析
1. 從使用者請求辨識領域/專案
2. 識別核心工作類型（生成、驗證、編輯、分析等）
3. 根據 Phase 0 稽核結果，分析與既有 agent/skill 的衝突或重複
4. 探索專案 codebase —— 了解技術堆疊、資料模型、主要模組
5. **偵測使用者熟練度** —— 透過對話脈絡線索（使用術語、提問層次）判斷技術水準，並調整後續溝通語氣。對程式經驗較少的使用者，不要在沒有說明的情況下直接使用像 `assertion`、`JSON schema` 這類術語。

### Phase 2: 團隊架構設計

#### 2-1. 選擇執行模式

**Agent Teams 是最優先的預設值。** 只要有兩個以上 agent 協作，就必須先評估 Agent Teams。成員之間可以直接通訊（SendMessage），並透過共享工作清單（TaskCreate）自我協調；共享發現、討論衝突、補齊遺漏，都能提升結果品質。

| 模式 | 何時使用 | 特性 |
|------|----------|------|
| **Agent Teams**（預設） | 2 人以上協作、需要即時協調/交換回饋、中間產物需要互相參照 | 透過 `TeamCreate` + `SendMessage` + `TaskCreate` 進行自我協調 |
| **Sub-agents**（替代） | 單一 agent 作業、只需把結果回傳給主流程、團隊通訊開銷過高時 | 直接呼叫 `Agent` 工具，搭配 `run_in_background` 進行平行化 |
| **Hybrid** | 各 Phase 特性不同時 —— 例如：平行收集（sub）→ 共識整合（team） | 依 Phase 混合 team/sub 模式 |

**決策順序：**
1. 先檢查是否可用 Agent Teams 設計 —— 只要有 2 人以上就是預設值
2. 只有在團隊通訊結構上確實不必要（只需傳遞結果），且 team 的開銷大於收益時，才選用 sub-agent
3. 若各 Phase 特性差異明顯，再考慮 Hybrid —— 並在 orchestrator 中明確標示各 Phase 的執行模式

> 詳細比較表與各 pattern 的決策樹，請參考 `references/agent-design-patterns.md` 的「執行模式」。

#### 2-2. 選擇架構 pattern

1. 將工作拆解為專業領域
2. 決定 Agent Team 結構（架構 pattern 請參考 `references/agent-design-patterns.md`）
   - **Pipeline**：依序相依的工作
   - **Fan-out/Fan-in**：平行且獨立的工作
   - **Expert Pool**：依情境選擇性呼叫
   - **Producer-Reviewer**：先生成再做品質審查
   - **Supervisor**：中央 agent 管理狀態並動態分派
   - **Hierarchical Delegation**：上層 agent 遞迴委派給下層

#### 2-3. Agent 拆分標準

依專業性、平行性、context、可重用性四個面向判斷。詳細標準表請參考 `references/agent-design-patterns.md` 的「agent 拆分標準」。既有 agent 的重複與重複使用檢查在 Phase 3-0 執行。

### Phase 3: 建立 agent 定義

#### 3-0. 檢查既有 agent 的重複與重複使用

建立新 agent 前，先檢查 `專案/.claude/agents/` 中是否已有職責重疊的 agent。反覆建立 Harness 時，相同角色很容易以不同名稱累積。

> 重複分類標準與重複使用設計請參閱 `references/agent-design-patterns.md` 的「代理人重複使用設計」章節。

**所有 agent 都必須定義為 `專案/.claude/agents/{name}.md` 檔案。** 禁止在沒有 agent 定義檔的情況下，直接把角色寫進 Agent 工具的 prompt。原因如下：
- agent 定義必須以檔案形式存在，才能在下次 session 重複使用
- 必須明確寫出團隊通訊協定，才能保證 agent 之間的協作品質
- Harness 的核心價值是分離 agent（誰做）與 skill（怎麼做）

即使使用 built-in type（`general-purpose`、`Explore`、`Plan`），也必須建立 agent 定義檔。built-in type 透過 Agent 工具的 `subagent_type` 參數指定，而 agent 定義檔則負責承載角色、原則與協定。

**模型設定：** 所有 agent 都使用 `model: "opus"`。呼叫 Agent 工具時，務必明確帶上 `model: "opus"` 參數。Harness 的品質與 agent 的推理能力直接相關，而 opus 能提供最佳品質。

**重組團隊：** 每個 session 只能啟用一個 Agent Team，但可以在不同 Phase 之間解散並重建新團隊。若像 Pipeline pattern 那樣，每個 Phase 需要不同的專家組合，就先把前一個團隊的產出存成檔案，再整理舊團隊並建立新團隊。

將每個 agent 定義在 `專案/.claude/agents/{name}.md`。必要區段：核心角色、工作原則、輸入/輸出協定、錯誤處理、協作。在 Agent Team 模式下，還要新增 `## 團隊通訊協定` 區段，說明訊息接收/發送對象與工作請求範圍。

> 定義範本與完整實際檔案內容，請參考 `references/agent-design-patterns.md` 的「agent 定義結構」與 `references/team-examples.md`。

**若包含 QA agent，必須遵守：**
- QA agent 請使用 `general-purpose` 類型（`Explore` 為唯讀，無法執行驗證 script）
- QA 的核心不是「確認有沒有」，而是 **「交叉比對邊界面」** —— 同時讀取 API 回應與前端 hook，再比對 shape
- QA 不是在全部完成後只做 1 次，而是 **每個模組一完成就漸進執行**（incremental QA）
- 詳細指南：請參考 `references/qa-agent-guide.md`

### Phase 4: 建立 skill

將各 agent 會使用的 skill 建立在 `專案/.claude/skills/{name}/SKILL.md`。詳細撰寫指南請參考 `references/skill-writing-guide.md`。

#### 4-0. 檢查既有 skill 的重複與重複使用

建立新 skill 前，先檢查 `專案/.claude/skills/` 中是否已有功能重疊的 skill。反覆建立 Harness 時，相同功能很容易以不同名稱累積。

> 重複分類標準與一般化模式請參閱 `references/skill-writing-guide.md` 的「技能重複使用設計」章節。

#### 4-1. Skill 結構

```
skill-name/
├── SKILL.md (必填)
│   ├── YAML frontmatter (name, description 必填)
│   └── Markdown 內文
└── Bundled Resources (選填)
    ├── scripts/    - 用於重複性/可決定性工作的可執行程式碼
    ├── references/ - 條件式載入的參考文件
    └── assets/     - 用於輸出的檔案（範本、圖片等）
```

#### 4-2. 撰寫 description —— 主動促成觸發

description 是 skill 唯一的觸發機制。Claude 對觸發條件通常判斷保守，因此 description 要寫得**積極（"pushy"）**。

**不好的例子：** `"處理 PDF 文件的 skill"`
**好的例子：** `"執行所有 PDF 工作，包括讀取 PDF 檔、擷取文字/表格、合併、分割、旋轉、浮水印、加密、OCR 等。只要提到 .pdf 檔案或要求 PDF 輸出，就一定要使用這個 skill。"`

重點：同時描述這個 skill 做什麼，以及哪些具體情況要觸發，並且要能和相似但不應觸發的情況區分開來。

#### 4-3. 內文撰寫原則

| 原則 | 說明 |
|------|------|
| **解釋 Why** | 不要只用像 "ALWAYS/NEVER" 這種強硬指令，而是要說明為什麼。LLM 理解原因後，面對 edge case 也更能正確判斷。 |
| **保持精簡** | context window 是公共資源。SKILL.md 內文目標控制在 500 行內，不必要增加負擔的內容要刪掉或移到 references/。 |
| **一般化** | 與其寫只適用於特定例子的狹窄規則，不如說明原理，讓它能處理多種輸入。避免 overfitting。 |
| **重複程式碼要 bundle** | 若在測試執行中發現 agent 反覆撰寫相同 script，就先 bundle 到 `scripts/`。 |
| **使用命令式寫法** | 採用「~做」、「~請執行」這類命令式/指示式語氣。 |

#### 4-4. Progressive Disclosure（漸進式資訊揭露）

skill 透過 3 層載入系統管理 context：

| 階段 | 載入時機 | 大小目標 |
|------|----------|----------|
| **Metadata**（name + description） | 永遠存在於 context 中 | 約 100 字 |
| **SKILL.md 內文** | skill 被觸發時 | <500 行 |
| **references/** | 只有在需要時 | 無上限（script 可不載入直接執行） |

**大小管理規則：**
- 當 SKILL.md 接近 500 行時，把細節拆到 references/，並在內文保留「何時應讀這個檔案」的指標
- 超過 300 行的 reference 檔案，在開頭加入 **目錄（ToC）**
- 若存在領域/框架專屬變體，請拆分到 references/ 子目錄，只載入相關檔案

```
cloud-deploy/
├── SKILL.md (工作流程 + 選擇指南)
└── references/
    ├── aws.md    ← 只有在選擇 AWS 時才載入
    ├── gcp.md
    └── azure.md
```

#### 4-5. Skill-agent 連結原則

- 1 個 agent ↔ 1~N 個 skill（1:1 或 1:多）
- skill 也可以由多個 agent 共用
- skill 負責「怎麼做」，agent 負責「誰來做」

> 詳細撰寫 pattern、範例與資料 schema 標準，請參考 `references/skill-writing-guide.md`。

### Phase 5: 整合與 orchestration

orchestrator 是一種特殊型態的 skill，負責把個別 agent 與 skill 串成單一工作流程，協調整個團隊。若說 Phase 4 建立的個別 skill 定義的是「各 agent 要做什麼、怎麼做」，那 orchestrator 定義的就是「誰在什麼時候、依什麼順序合作」。具體範本請參考 `references/orchestrator-template.md`。

**既有擴充時修改 orchestrator：** 若不是新建，而是擴充既有配置，不要重建新的 orchestrator，而是修改既有 orchestrator。新增 agent 時，要把新 agent 納入團隊配置、工作分派與資料流，也要在 description 新增與新 agent 相關的觸發關鍵字。

依照 Phase 2-1 選定的執行模式，orchestrator pattern 會有所不同：

#### 5-0. Orchestrator pattern（依模式）

**Agent Team pattern（預設）：**
orchestrator 透過 `TeamCreate` 建立團隊，再用 `TaskCreate` 分派工作。團隊成員用 `SendMessage` 直接通訊並自我協調。leader（orchestrator）負責監控進度並彙整結果。

```
[orchestrator/leader]
    ├── TeamCreate(team_name, members)
    ├── TaskCreate(tasks with dependencies)
    ├── 成員自我協調（SendMessage）
    ├── 收集並彙整結果
    └── 整理解散團隊
```

**Sub-agent pattern（替代）：**
orchestrator 直接透過 `Agent` 工具呼叫 sub-agent。平行執行時使用 `run_in_background: true`，結果只回傳給主流程。適用於不需要團隊通訊、希望降低開銷的情況。

```
[orchestrator]
    ├── Agent(agent-1, run_in_background=true)
    ├── Agent(agent-2, run_in_background=true)
    ├── 等待並收集結果
    └── 產生整合輸出
```

**Hybrid pattern：**
各 Phase 混用不同模式。常見組合：
- **平行收集（sub）→ 共識整合（team）**：在 Phase 2 用 sub-agent 平行收集獨立資料 → 在 Phase 3 建立 team 進行討論、共識式整合
- **team 生成 → sub 驗證**：在 Phase 2 由 team 產生初稿 → 在 Phase 3 由單一 sub-agent 獨立驗證
- **跨 Phase 重組 team**：每個 Phase 都先 `TeamDelete` 再 `TeamCreate`，中間插入 sub-agent 呼叫

若選擇 Hybrid，請在 orchestrator 的各 Phase 區段開頭明確標示該 Phase 的執行模式（例如：`**執行模式：** Agent Teams`）。

#### 5-1. 資料傳遞協定

在 orchestrator 中明確規範 agent 之間如何傳遞資料：

| 策略 | 方式 | 適用模式 | 適合情境 |
|------|------|----------|-----------|
| **訊息型** | 以 `SendMessage` 讓成員直接通訊 | team | 即時協調、交換回饋、輕量狀態傳遞 |
| **任務型** | 以 `TaskCreate`/`TaskUpdate` 分享工作狀態 | team | 追蹤進度、管理相依性、請求工作本身 |
| **檔案型** | 在約定路徑寫入/讀取檔案 | team + sub | 大量資料、結構化產物、需要稽核追蹤 |
| **回傳值型** | 使用 `Agent` 工具的回傳訊息 | sub | 主流程直接收集 sub-agent 結果 |

**建議組合（team 模式）：** 任務型（協調） + 檔案型（產物） + 訊息型（即時溝通）
**建議組合（sub 模式）：** 回傳值型（結果收集） + 檔案型（大型產物）
**Hybrid：** 依各 Phase 的執行模式套用對應組合

使用檔案型傳遞時的規則：
- 在工作目錄下建立 `_workspace/` 資料夾，用來存放中間產物
- 檔名慣例：`{phase}_{agent}_{artifact}.{ext}`（例如：`01_analyst_requirements.md`）
- 最終產物才輸出到使用者指定路徑，中間檔案（`_workspace/`）要保留（供事後驗證與稽核追蹤）

#### 5-2. 錯誤處理

在 orchestrator 中加入錯誤處理方針。核心原則：先重試 1 次，若再次失敗，就在沒有該結果的情況下繼續進行（並在報告中標示缺漏）；若資料互相衝突，不要刪除，而是保留來源並列出。

> 各種錯誤類型的策略表與實作細節，請參考 `references/orchestrator-template.md` 的「錯誤處理」。

#### 5-3. 團隊規模指引

| 工作規模 | 建議成員數 | 每位成員負責工作數 |
|----------|------------|--------------------|
| 小型（5~10 個工作） | 2~3 人 | 3~5 個 |
| 中型（10~20 個工作） | 3~5 人 | 4~6 個 |
| 大型（20 個以上工作） | 5~7 人 | 4~5 個 |

> 成員越多，協調開銷越高。3 位專注的成員通常比 5 位分散的成員更好。

#### 5-4. 在 CLAUDE.md 註冊 Harness 指標

當 Harness 配置完成後，在專案的 `CLAUDE.md` 註冊最小必要指標。因為 CLAUDE.md 每個新 session 都會載入，只需記錄 Harness 的存在與觸發規則，剩下的由 orchestrator skill 負責。

**CLAUDE.md 範本：**

````markdown
## Harness: {領域名稱}

**目標：** {Harness 核心目標的一句話}

**觸發規則：** 收到與 {領域} 相關的工作請求時，使用 `{orchestrator-skill-name}` skill。若只是簡單問題，可以直接回答。

**變更歷程：**
| 日期 | 變更內容 | 對象 | 原因 |
|------|----------|------|------|
| {YYYY-MM-DD} | 初始配置 | 全部 | - |
````

**不要放進 CLAUDE.md 的內容：** agent 清單、skill 清單、目錄結構、詳細執行規則。原因：agent/skill 清單已由 orchestrator skill 與 `.claude/agents/`、`.claude/skills/` 管理，重複了；目錄結構可直接從檔案系統確認。CLAUDE.md 只保留 **指標（觸發規則） + 變更歷程**。

#### 5-5. 支援後續工作

orchestrator 不只要處理初次執行，也要能處理後續工作。請確保下列三點：

**1. 在 orchestrator description 中納入後續工作關鍵字：**
如果只寫初次建立相關關鍵字，後續請求就不會被觸發。description 必須包含：
- 「重新執行」、「再跑一次」、「更新」、「修改」、「補強」
- 「只重跑 {領域} 的 {部分工作}」
- 「基於先前結果」、「改善結果」

**2. 在 orchestrator 的 Phase 1 加入 context 檢查步驟：**
工作流程啟動時，先確認既有產物是否存在，再決定執行模式：
- `_workspace/` 存在 + 使用者要求部分修改 → **部分重跑**（只重新呼叫對應 agent）
- `_workspace/` 存在 + 使用者提供新輸入 → **新執行**（將舊 `_workspace` 移到 `_workspace_prev/`）
- `_workspace/` 不存在 → **初始執行**

**3. 在 agent 定義中加入重新呼叫指引：**
在各 agent 的 `.md` 檔中明確寫出「已有先前產物時該如何處理」：
- 若先前結果檔存在，先讀取並反映改善點
- 若有使用者回饋，僅修改對應部分

> 請參考 orchestrator 範本中 `references/orchestrator-template.md` 的「Phase 0: context 檢查」區段

### Phase 6: 驗證與測試

驗證生成好的 Harness。詳細測試方法請參考 `references/skill-testing-guide.md`。

#### 6-1. 結構驗證

- 確認所有 agent 檔都在正確位置
- 驗證 skill 的 frontmatter（name、description）
- 確認 agent 間參照一致
- 確認沒有建立 command

#### 6-2. 依執行模式驗證

- **Agent Teams**：檢查成員間通訊路徑、工作相依性、團隊規模是否合適
- **Sub-agents**：檢查各 agent 的輸入/輸出連結、`run_in_background` 設定、回傳值收集邏輯
- **Hybrid**：確認各 Phase 的執行模式是否明確標示在 orchestrator 中，並檢查 Phase 邊界的資料傳遞是否中斷（team → sub 切換時，team 的產物是否有正確連接為 sub 的輸入）

#### 6-3. Skill 執行測試

針對每個建立好的 skill，實際進行執行測試：

1. **撰寫測試 prompt** —— 每個 skill 撰寫 2~3 個具體且自然、符合真實使用者情境的測試 prompt。

2. **比較 With-skill 與 Without-skill 的執行** —— 若可行，平行執行有 skill 與無 skill 的版本，確認 skill 的附加價值。為此建立兩個 agent：
   - **With-skill**：讀取 skill 後執行工作
   - **Without-skill (baseline)**：在沒有 skill 的情況下，用相同 prompt 執行

3. **評估結果** —— 從質性（使用者評論）與量化（基於 assertion）兩個層面評估輸出品質。若產物可客觀驗證（例如檔案生成、資料擷取），定義 assertion；若較主觀（例如語氣、設計），就依賴使用者回饋。

4. **反覆改善迴圈** —— 若測試中發現問題：
   - 將回饋**一般化**後再修改 skill（避免只針對單一例子做狹窄修補）
   - 修改後重新測試
   - 持續反覆，直到使用者滿意或已無實質可改善空間

5. **Bundle 重複 pattern** —— 若在測試執行中發現 agent 反覆撰寫相同程式碼（例如每次都生成相同 helper script），就先把它 bundle 到 `scripts/`。

#### 6-4. 觸發驗證

驗證每個 skill 的 description 是否會被正確觸發：

1. **Should-trigger 查詢**（8~10 個）—— 各種應該觸發 skill 的表達方式（正式/口語、明示/暗示）
2. **Should-NOT-trigger 查詢**（8~10 個）—— 關鍵字相似，但實際上更適合其他工具/skill 的「near-miss」查詢

**撰寫 near-miss 的重點：** 像「幫我寫 Fibonacci 函式」這種明顯無關的查詢，測試價值很低。像「幫我把這個 excel 檔裡的圖表匯出成 PNG」（xlsx skill vs 圖片轉換）這種**邊界模糊的查詢**才是好的測試案例。

這個階段也要檢查與既有 skill 是否發生觸發衝突。

#### 6-5. Dry-run 測試

- 檢查 orchestrator skill 的 Phase 順序是否合理
- 確認資料傳遞路徑中沒有空白區段（dead link）
- 確認所有 agent 的輸入都能對應到前一個 Phase 的輸出
- 確認各種錯誤情境的 fallback 路徑都可執行

#### 6-6. 撰寫測試情境

- 在 orchestrator skill 中新增 `## 測試情境` 區段
- 至少描述 1 個正常流程 + 1 個錯誤流程

### Phase 7: Harness 演化

Harness 不是建立一次就結束的靜態產物，而是會隨使用者回饋持續演化的系統。

#### 7-1. 執行後蒐集回饋

每次 Harness 執行完成後，都向使用者索取回饋：
- 「結果有沒有哪裡需要改善？」
- 「Agent Team 配置或工作流程有沒有想調整的地方？」

若沒有回饋就繼續，不要強迫，但一定要提供這個機會。

#### 7-2. 反映回饋的路徑

依回饋類型，修改對象不同：

| 回饋類型 | 修改對象 | 例子 |
|-----------|----------|------|
| 產物品質 | 對應 agent 的 skill | 「分析太淺」→ 在 skill 新增深度標準 |
| agent 角色 | agent 定義 `.md` | 「也需要做安全審查」→ 新增 agent |
| 工作流程順序 | orchestrator skill | 「應該先驗證」→ 調整 Phase 順序 |
| 團隊配置 | orchestrator + agent | 「這兩個感覺可以合併」→ 合併 agent |
| 觸發漏掉 | skill description | 「這種說法不會觸發」→ 擴充 description |

#### 7-3. 變更歷程

所有變更都要記錄在 CLAUDE.md 的 **變更歷程** 表格中（與 Phase 5-4 範本中的「變更歷程」區段相同）：

```markdown
**變更歷程：**
| 日期 | 變更內容 | 對象 | 原因 |
|------|----------|------|------|
| 2026-04-05 | 初始配置 | 全部 | - |
| 2026-04-07 | 新增 QA agent | agents/qa.md | 使用者反映產物品質驗證不足 |
| 2026-04-10 | 新增語氣指南 | skills/content-creator | 收到「太生硬」的回饋 |
```

透過這份歷程，可以追蹤 Harness 是如何演化的，也能避免 regression。

#### 7-4. 演化觸發時機

不只在使用者明確說「請幫我修改 Harness」時才演化，以下情況也要主動提出：
- 同類型回饋重複出現 2 次以上
- 發現 agent 反覆失敗的 pattern
- 觀察到使用者繞過 orchestrator 改成手動作業

#### 7-5. 營運/維護工作流程

有系統地執行既有 Harness 的檢查、修正與同步。當 Phase 0 進入「營運/維護」分支時，依照此流程進行。

**Step 1: 現況稽核**
- 比對 `.claude/agents/` 檔案清單與 orchestrator skill 中的 agent 配置 → 產生不一致清單
- 比對 `.claude/skills/` 目錄清單與 orchestrator skill 中的 skill 配置 → 產生不一致清單
- 將稽核結果回報給使用者

**Step 2: 漸進式新增/修正**
- 依使用者請求執行 agent 的新增/修改/刪除，以及 skill 的新增/修改/刪除
- 每次只做一項變更，每做完一項立刻執行 Step 3（同步）

**Step 3: 更新 CLAUDE.md 變更歷程**
- 在變更歷程表中記錄日期、變更內容、對象、原因

**Step 4: 驗證變更**
- 依 Phase 6-1 標準驗證修改過的 agent/skill 結構
- 若修改範圍會影響觸發條件，則依 Phase 6-4 進行觸發驗證
- 若是大型變更（架構調整、一次新增/刪除 3 個以上 agent），則進一步執行 Phase 6-3（執行測試）與 6-5（dry-run）
- 最後再次確認 CLAUDE.md 與實際檔案是否一致

## 產物檢查清單

建立完成後確認：

- [ ] `專案/.claude/agents/` — **必須建立 agent 定義檔**（即使是 built-in type，也一定要建立檔案）
- [ ] `專案/.claude/skills/` — skill 檔案（SKILL.md + references/）
- [ ] 1 個 orchestrator skill（包含資料流 + 錯誤處理 + 測試情境）
- [ ] 明確標示執行模式（Agent Teams / Sub-agents / Hybrid 三選一；若為 Hybrid，要寫出各 Phase 模式）
- [ ] 所有 Agent 呼叫都明確帶上 `model: "opus"` 參數
- [ ] `.claude/commands/` — 不建立任何內容
- [ ] 與既有 agent/skill 無衝突
- [ ] skill description 以積極（"pushy"）方式撰寫 —— **包含後續工作關鍵字**
- [ ] SKILL.md 內文控制在 500 行內，超出則拆到 references/
- [ ] 已用 2~3 個測試 prompt 完成執行驗證
- [ ] 已完成觸發驗證（should-trigger + should-NOT-trigger）
- [ ] **在 CLAUDE.md 註冊 Harness 指標**（觸發規則 + 變更歷程）
- [ ] **在 CLAUDE.md 的變更歷程記錄 agent/skill 的新增/刪除/修改**
- [ ] **在 orchestrator 的 Phase 1 加入 context 檢查步驟**（判斷初始/後續/部分重跑）

## 參考資料

- Harness pattern：`references/agent-design-patterns.md`
- 既有 Harness 範例（含完整實際檔案內容）：`references/team-examples.md`
- orchestrator 範本：`references/orchestrator-template.md`
- **Skill 撰寫指南**：`references/skill-writing-guide.md` — 撰寫 pattern、範例、資料 schema 標準
- **Skill 測試指南**：`references/skill-testing-guide.md` — 測試/評估/反覆改善方法論
- **QA agent 指南**：`references/qa-agent-guide.md` — 在 build Harness 時若要納入 QA agent 可參考。包含整合一致性驗證方法、邊界面 bug pattern、QA agent 定義範本，並以實際專案中發現的 7 個 bug 案例為基礎。
