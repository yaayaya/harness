# Agent Team Design Patterns

## 執行模式：Agent Teams vs Sub-agents

理解兩種執行模式的核心差異，並選擇合適的模式。

### Agent Teams — 預設模式

team leader 使用 `TeamCreate` 組成團隊，而 team 成員會以獨立的 Claude Code instance 執行。成員之間可透過 `SendMessage` 直接通訊，並以共享工作清單（`TaskCreate`/`TaskUpdate`）自我協調。

```
[Leader] ←→ [MemberA] ←→ [MemberB]
  ↕          ↕          ↕
  └──── Shared Task List ────┘
```

**核心工具：**
- `TeamCreate`: 建立 team + 啟動 team 成員
- `SendMessage({to: name})`: 傳送訊息給特定成員
- `SendMessage({to: "all"})`: 廣播（成本高，應少用）
- `TaskCreate`/`TaskUpdate`: 管理共享工作清單

**特性：**
- 成員之間可直接對話、挑戰、驗證
- 不需經過 leader，即可在成員間交換資訊
- 使用共享工作清單進行自我協調（也可自行提出工作請求）
- 成員若進入閒置狀態，會自動通知 leader
- 可透過 plan approval mode，在高風險操作前先審查

**限制：**
- 每個 session 只能有一個 **active** team（但可以在不同 Phase 解散後重建新 team）
- 不支援巢狀 team（team 成員不能再建立自己的 team）
- leader 固定（不可轉移）
- token 成本較高

**重組 team 的 pattern：**
若各 Phase 需要不同專家組合，流程為：先將前一個 team 的產物寫入檔案 → 整理解散 team → 建立新 team。前一個 team 的產物保存在 `_workspace/`，因此新 team 可以透過 Read 存取。

### Sub-agents — 輕量模式

主 agent 使用 `Agent` 工具建立 sub-agent。sub-agent 只會把工作結果回傳給主 agent，彼此之間不會通訊。

```
[Main] → [SubA] → Return result
      → [SubB] → Return result
      → [SubC] → Return result
```

**核心工具：**
- `Agent(prompt, subagent_type, run_in_background)`: 建立 sub-agent

**特性：**
- 輕量且快速
- 結果會摘要後回到主 context
- token 效率較高

**限制：**
- sub-agent 之間無法通訊
- 所有協調都由主 agent 負責
- 無法進行即時協作/挑戰

### 模式選擇決策樹

```
是否有 2 個以上的 agent？
├── Yes → agent 之間是否需要通訊？
│         ├── Yes → Agent Teams（預設）
│         │         透過交叉驗證、共享發現、即時回饋來提升品質。
│         │
│         └── No → 也可以使用 Sub-agents
│                  適合只需要傳結果的生成-驗證、Expert Pool 等情境。
│
└── No（1 個） → Sub-agents
               單一 agent 不需要建立 team。
```

> **核心原則：** Agent Teams 是預設值。當你想選 Sub-agents 時，先自問：「team 成員之間真的完全不需要通訊嗎？」

---

## Agent Team 架構類型

### 1. Pipeline
順序式工作流程。前一個 agent 的輸出會成為下一個 agent 的輸入。

```
[Analysis] → [Design] → [Implementation] → [Validation]
```

**適合情境：** 每個階段都高度依賴前一階段產物  
**例子：** 小說寫作 —— 世界觀 → 角色 → 劇情 → 寫作 → 編輯  
**注意：** 任一瓶頸都會拖慢整條 Pipeline。每個階段都應盡可能獨立設計。  
**適用的 team 模式：** 因為順序相依性很強，team 模式的優勢較有限。但若 Pipeline 內存在可平行化區段，team 模式仍然有價值。

### 2. Fan-out/Fan-in
先平行處理，再整合結果。同時執行彼此獨立的工作。

```
         ┌→ [ExpertA] ─┐
[Dispatch] → ├→ [ExpertB] ─┼→ [Integration]
         └→ [ExpertC] ─┘
```

**適合情境：** 針對同一份輸入，需要從不同觀點/領域進行分析  
**例子：** 綜合研究 —— 同步調查官方/媒體/社群/背景資料 → 整合報告  
**注意：** 整合階段的品質會決定最終品質。  
**適用的 team 模式：** 這是最自然的 Agent Teams pattern。**必須使用 Agent Teams。** 成員可以互相分享發現與提出挑戰，一個 agent 的新發現能即時修正其他 agent 的調查方向，因此比各自獨立調查的品質更高。

### 3. Expert Pool
依情境選擇合適的專家進行呼叫。

```
[Router] → { ExpertA | ExpertB | ExpertC }
```

**適合情境：** 根據輸入類型需要不同處理方式  
**例子：** 程式碼審查 —— 從安全、效能、架構專家中只呼叫對應領域  
**注意：** router 的分類準確度是關鍵。  
**適用的 team 模式：** 更適合用 Sub-agents。因為只需呼叫需要的專家，沒必要維持常駐 team。

### 4. Producer-Reviewer
生成 agent 與驗證 agent 成對運作。

```
[Producer] → [Reviewer] → (if issues) → [Producer] rerun
```

**適合情境：** 產物品質保證很重要，且存在客觀驗證標準  
**例子：** Webtoon —— artist 生成 → reviewer 審查 → 有問題的 panel 重新生成  
**注意：** 為避免無限迴圈，必須設定最大重試次數（2~3 次）。  
**適用的 team 模式：** Agent Teams 很有幫助。可透過 SendMessage 讓 producer 與 reviewer 即時交換回饋。

### 5. Supervisor
中央 agent 管理工作狀態，並動態把工作分派給下層 agent。

```
         ┌→ [WorkerA]
[Supervisor] ─┼→ [WorkerB]    ← supervisor 觀察狀態後動態分派
         └→ [WorkerC]
```

**適合情境：** 工作量可變，或需要在執行期間動態決定如何分派工作  
**例子：** 大型程式碼 migration —— supervisor 分析檔案清單，再分批指派給 workers  
**與 Fan-out 的差異：** Fan-out 是事先固定分派工作；Supervisor 則會根據進度動態調整  
**注意：** 委派粒度要夠大，避免 supervisor 成為瓶頸。  
**適用的 team 模式：** Agent Teams 的共享工作清單和 Supervisor pattern 非常契合。使用 TaskCreate 登記工作，成員再自行請領。

### 6. Hierarchical Delegation
上層 agent 會遞迴委派給下層 agent，將複雜問題逐層拆解。

```
[Lead] → [TeamLeadA] → [ExecutorA1]
                     → [ExecutorA2]
       → [TeamLeadB] → [ExecutorB1]
```

**適合情境：** 問題本身天然適合分層拆解  
**例子：** Full-stack app 開發 —— 總負責 → 前端 team lead →（UI/邏輯/測試）+ 後端 team lead →（API/DB/測試）  
**注意：** 深度超過 3 層時，延遲與 context 損耗會大增。建議控制在 2 層內。  
**適用的 team 模式：** Agent Teams 不支援巢狀（team 成員不能再建立 team）。第一層可用 team，第二層改用 sub-agent，或乾脆展平成單一 team。

## 複合 pattern

實務上，比起單一 pattern，更常見的是複合 pattern：

| 複合 pattern | 組成 | 例子 |
|----------|------|------|
| **Fan-out + Producer-Reviewer** | 平行生成後逐一驗證 | 多語翻譯 —— 4 種語言平行翻譯 → 各自由 native reviewer 審查 |
| **Pipeline + Fan-out** | 在順序式流程中將部分階段平行化 | 分析（順序）→ 實作（平行）→ 整合測試（順序） |
| **Supervisor + Expert Pool** | supervisor 動態呼叫專家 | 客服處理 —— supervisor 先分類問題，再分派合適專家 |

### 複合 pattern 下的執行模式

**原則上所有複合 pattern 都優先使用 Agent Teams。** 團隊成員之間活躍的溝通，是提升結果品質的關鍵動力。

| 情境 | 建議模式 | 原因 |
|---------|----------|------|
| **研究 + 分析** | Agent Teams | 調查者之間可共享發現，即時討論矛盾資訊 |
| **設計 + 實作 + 驗證** | Agent Teams | 設計者、實作者、驗證者之間能形成回饋迴圈 |
| **Supervisor + Worker** | Agent Teams | 可用共享工作清單做動態分派，也能共享進度 |
| **生成 + 驗證** | Agent Teams | 生成者與驗證者即時交換回饋，減少返工 |

> 只有在單一 agent 執行完全隔離、一次性的工作時，才考慮混用 Sub-agents。

## 選擇 agent 類型

呼叫 agent 時，透過 Agent 工具的 `subagent_type` 參數指定類型。Agent Team 的成員也可以使用自訂 agent 定義。

### Built-in type

| 類型 | 工具存取 | 適合用途 |
|------|----------|-----------|
| `general-purpose` | 完整（包含 WebSearch、WebFetch） | 網路調查、通用工作 |
| `Explore` | 唯讀（無 Edit/Write） | 探索 codebase、分析 |
| `Plan` | 唯讀（無 Edit/Write） | 架構設計、規劃 |

### 自訂 type

若在 `.claude/agents/{name}.md` 定義了 agent，就能用 `subagent_type: "{name}"` 呼叫。自訂 agent 可使用完整工具集。

### 選擇標準

| 情境 | 建議 | 原因 |
|------|------|------|
| 角色複雜，且會跨多個 session 重複使用 | **自訂 type**（`.claude/agents/`） | 可把 persona 與工作原則管理在檔案中 |
| 只是單純調查/蒐集，prompt 就已足夠 | **`general-purpose`** + 詳細 prompt | 不需要額外 agent 檔，直接在 prompt 下指令 |
| 只需要讀程式碼（分析/審查） | **`Explore`** | 避免誤改檔案 |
| 只需要做設計/規劃 | **`Plan`** | 專注分析，避免變更程式碼 |
| 需要修改檔案的實作工作 | **自訂 type** | 完整工具存取 + 專業化指示 |

**原則：** 所有 agent 都必須定義在 `.claude/agents/{name}.md` 檔案中。即使是 built-in type，也要建立 agent 定義檔，明確寫出角色、原則與協定。只有以檔案形式存在，才能在後續 session 重複使用，也只有明確寫出團隊通訊協定，才能保證協作品質。

**模型：** 所有 agent 都使用 `model: "opus"`。呼叫 Agent 工具時，務必帶上 `model: "opus"` 參數。

## agent 定義結構

```markdown
---
name: agent-name
description: "1-2 句角色說明。列出觸發關鍵字。"
---

# Agent Name — 角色一句話摘要

你是 [領域] 的 [角色] 專家。

## 核心角色
1. 角色1
2. 角色2

## 工作原則
- 原則1
- 原則2

## 輸入/輸出協定
- 輸入：[從哪裡接收什麼]
- 輸出：[寫到哪裡、寫什麼]
- 格式：[檔案格式、結構]

## 團隊通訊協定（Agent Team 模式）
- 接收訊息：[會從誰收到什麼訊息]
- 發送訊息：[會傳給誰什麼訊息]
- 工作請求：[會在共享工作清單請求哪種類型的工作]

## 錯誤處理
- [失敗時怎麼做]
- [逾時時怎麼做]

## 協作
- 與其他 agent 的關係
```

## agent 拆分標準

| 標準 | 拆分 | 整合 |
|------|------|------|
| 專業性 | 領域不同就拆分 | 領域重疊就整合 |
| 平行性 | 能獨立執行就拆分 | 若有順序依賴則考慮整合 |
| context | context 負擔大就拆分 | 若輕量且快速可整合 |
| 可重用性 | 若其他 team 也會用就拆分 | 若只在本 team 使用可考慮整合 |

## 區分 skill 與 agent

| 區分 | Skill | Agent |
|------|-------|-------|
| 定義 | 程序性知識 + 工具 bundle | 專家 persona + 行為原則 |
| 位置 | `.claude/skills/` | `.claude/agents/` |
| 觸發方式 | 使用者請求關鍵字比對 | 透過 Agent 工具明確呼叫 |
| 大小 | 小到大皆可（workflow） | 較小（角色定義） |
| 用途 | 「怎麼做」 | 「誰來做」 |

skill 是 agent 執行工作時參考的 **程序性指南**。  
agent 是活用 skill 的 **專家角色定義**。

## skill ↔ agent 的連結方式

agent 使用 skill 的 3 種方式：

| 方式 | 實作 | 適合情境 |
|------|------|-----------|
| **呼叫 Skill 工具** | 在 agent prompt 中明示 `Skill 工具呼叫 /skill-name` | skill 是可獨立執行的 workflow，且也可能被使用者直接呼叫 |
| **直接內嵌於 prompt** | 直接把 skill 內容放進 agent 定義 | skill 很短（50 行以下），且只供這個 agent 使用 |
| **載入 reference** | 需要時以 `Read` 載入 skill 的 references/ 檔案 | skill 內容較大，且只在特定條件下需要 |

建議：可重用性高就用 Skill 工具、專屬用途就內嵌、大型內容就用 reference 載入。
