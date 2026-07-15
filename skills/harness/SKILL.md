---
name: harness
description: "建構與維護 Codex Harness。當使用者要求配置 Harness、設計多代理工作流程、建立 Codex 自訂代理人與技能、重構既有 Harness、檢查代理人與技能同步狀態，或把其他代理平台的配置遷移到 Codex 時使用。"
---

# Harness — Codex 團隊架構與技能工廠

把一個領域或專案需求轉換成可執行、可驗證、可維護的 Codex Harness。產物以 Codex 原生格式為準：

- 專案持久指示：`AGENTS.md`
- 專案自訂代理人：`.codex/agents/*.toml`
- 專案技能：`.agents/skills/{skill-name}/SKILL.md`
- 專案執行設定：`.codex/config.toml`
- 可安裝外掛：`.codex-plugin/plugin.json` 與外掛根目錄下的 `skills/`

若使用者要封裝、搬移、備份、安裝或更新已存在的 Harness 團隊，改用 `$harness-packager`；不要重新設計團隊。

不得建立 `.claude/agents/`、`.claude/skills/`、`CLAUDE.md`，也不得把 `TeamCreate`、`SendMessage`、`TaskCreate`、`subagent_type`、`run_in_background` 或 `model: "opus"` 寫進 Codex 產物。

## 核心原則

1. **Codex 原生優先。** 自訂代理人使用 TOML；技能使用 Agent Skills 格式；長期專案規則寫入 `AGENTS.md`。
2. **主代理人負責協調。** 子代理人處理有界工作並回傳摘要；除非需求明確需要遞迴委派，否則維持 `agents.max_depth = 1`。
3. **平行讀取、審慎寫入。** 探索、研究、測試與審查適合平行；多個代理人同時修改重疊檔案容易衝突，應指定單一寫入者。
4. **先重複使用，再新增。** 建立代理人或技能前，先檢查既有產物是否已涵蓋相同責任。
5. **設定跟著風險走。** 研究與審查代理人預設 `sandbox_mode = "read-only"`；實作者才使用父工作階段允許的寫入權限。
6. **模型設定保持可攜。** 未收到明確需求時，不固定模型名稱與推理等級，讓代理人繼承目前工作階段設定。
7. **每次變更都要驗證。** 結構、觸發、資料流、失敗處理與實際任務都必須有證據。

## 工作流程

### Phase 0：現況稽核

先讀取以下位置；不存在不算錯誤：

1. `AGENTS.md` 與更深層的 `AGENTS.md`
2. `.codex/config.toml`
3. `.codex/agents/*.toml`
4. `.agents/skills/*/SKILL.md`
5. `.codex-plugin/plugin.json` 與外掛 `skills/`

判定本次屬於新建、擴充或維護：

| 類型 | 判定方式 | 後續處理 |
|---|---|---|
| 新建 | 沒有 Harness 產物 | 執行全部 Phase |
| 擴充 | 已有 Harness，新增角色、技能或階段 | 只執行受影響 Phase，完成後做全面一致性驗證 |
| 維護 | 修正漂移、錯誤或過時設定 | 先列出證據，再做最小範圍修正 |

稽核時要找出：重複角色、失效路徑、未被引用的技能、過寬權限、固定到過時模型的設定，以及只適用其他代理平台的語彙。

### Phase 1：領域分析

1. 說明 Harness 要完成的業務結果。
2. 列出主要工作階段、輸入、輸出、品質門檻與失敗情境。
3. 找出可平行工作、具有前後相依的工作，以及必須由單一擁有者完成的寫入工作。
4. 只在確實需要不同上下文、工具、權限或判斷標準時拆分代理人。
5. 外部系統若需要憑證，先整理需要的服務名稱、驗證方式、環境變數名稱、權限範圍與測試方式，再請使用者提供；不得把密鑰寫進儲存庫。

### Phase 2：選擇協作模式

Codex 的團隊是由主代理人協調的子代理人工作流程，不使用獨立的 Team API。

| 模式 | 適用情境 | 執行方式 |
|---|---|---|
| 平行子代理人 | 多個互不相依的探索、研究、測試或審查工作 | 同時委派有界任務，等待所有結果後彙整 |
| 階段式子代理人 | 工作具有明確依賴、審查關卡或交接 | 前一階段完成並產出摘要後，再啟動下一階段 |
| 混合模式 | 前段可平行，後段需要整合或獨立驗證 | 平行蒐集 → 單一整合者 → 獨立審查者 |
| 單一代理人 | 任務很小、協調成本高於效益 | 不委派，直接完成並驗證 |

從下列架構 pattern 選擇最小可行組合：

- **Pipeline**：前一角色輸出是下一角色輸入。
- **Fan-out/Fan-in**：多個角色平行處理後由主代理人整合。
- **Expert Pool**：不同專家從各自角度判斷同一問題。
- **Producer-Reviewer**：產出者與審查者分離，依回饋迭代。
- **Supervisor**：主代理人依任務狀態動態選擇角色。
- **Hierarchical Delegation**：只有需求明確需要多層管理時才使用，並同步提高 `agents.max_depth`；必須說明成本與遞迴擴散風險。

完整判斷準則見 `references/agent-design-patterns.md`。

### Phase 3：建立自訂代理人

#### 3-0：先檢查重複

比較 `.codex/agents/*.toml` 的 `name`、`description`、權限與核心責任。若既有代理人可透過小幅調整或補上技能完成需求，優先重複使用。

#### 3-1：使用 Codex TOML 格式

每個自訂代理人建立一個 `.codex/agents/{name}.toml`。必填欄位：

- `name`
- `description`
- `developer_instructions`

可選欄位包括 `nickname_candidates`、`model`、`model_reasoning_effort`、`sandbox_mode`、`mcp_servers` 與 `skills.config`。未明確需要時省略，讓設定繼承父工作階段。

```toml
name = "domain_reviewer"
description = "唯讀領域審查者，檢查正確性、風險與缺漏。"
sandbox_mode = "read-only"
developer_instructions = """
根據可驗證證據進行審查。
優先找出行為錯誤、風險、缺少的測試與不一致。
回傳精簡摘要、證據位置、嚴重度與建議後續動作。
不要修改檔案，除非主代理人明確改派實作任務。
"""
```

代理人說明必須包含：適用時機、責任邊界、輸入、輸出、驗證方式、失敗時如何回報，以及是否允許寫入。

#### 3-2：控制併發與深度

只有多代理需求確定後才新增或修改 `.codex/config.toml`：

```toml
[agents]
max_threads = 4
max_depth = 1
```

併發數應依工作量與資源調整。不要只為展示多代理能力而提高數值。

### Phase 4：建立技能

#### 4-0：選擇正確位置

- 僅適用目前專案：`.agents/skills/{name}/SKILL.md`
- 要隨外掛安裝：`skills/{name}/SKILL.md`
- 不要把專案技能放進 `.codex/agents/`，兩者用途不同。

#### 4-1：技能結構

```text
skill-name/
├── SKILL.md
├── scripts/       # 可選：可重複執行或驗證的程式
├── references/    # 可選：按需載入的詳細知識
└── assets/        # 可選：範本與靜態資源
```

`SKILL.md` 必須有 `name` 與 `description`。Description 要清楚列出適用任務與常見觸發語句，讓 Codex 能隱式選用，也能讓使用者以 `$skill-name` 明確叫用。

#### 4-2：漸進式揭露

1. Frontmatter 只負責發現與觸發。
2. `SKILL.md` 保留必要決策、步驟、限制與輸出格式。
3. 超過約 300 行或只在少數情境需要的內容移到 `references/`，並在主檔明確寫出何時讀取。
4. 重複而可機械化的工作放進 `scripts/`，避免每次重新生成。

詳細原則見 `references/skill-writing-guide.md`。

### Phase 5：整合 Orchestrator

建立 `.agents/skills/{domain}-orchestrator/SKILL.md`，由主代理人讀取並執行。Orchestrator 應描述意圖，不應硬綁某一版內部工具名稱。

必須包含：

1. 何時啟動，以及不該啟動的相鄰情境。
2. 要使用哪些自訂代理人與選擇原因。
3. 任務如何切分、哪些可平行、哪些有相依。
4. 主代理人要等待哪些結果、如何彙整與處理衝突。
5. 哪一個角色擁有寫入權，以及如何避免重疊修改。
6. 失敗、逾時、部分結果與缺少工具時的降級策略。
7. 完成條件與驗證證據。

#### 5-1：資料傳遞

- 預設讓子代理人回傳摘要、證據位置與明確結論，不回灌大量原始日誌。
- 跨階段需要完整產物時，寫入專案內的 `_workspace/`；檔名使用 `{phase}_{agent}_{artifact}.{ext}`。
- 只有單一角色可修改同一份最終產物；其他角色提供審查意見。
- 主代理人必須解決衝突，不能只把互斥結論並列。

#### 5-2：在 AGENTS.md 註冊最小指標

Harness 完成後，在專案根目錄 `AGENTS.md` 加入最小入口：

````markdown
## Harness：{領域名稱}

**用途：** {一句話說明 Harness 解決的問題}

**觸發規則：** 當任務涉及 {核心工作類型} 時，使用 `${orchestrator-skill-name}` 技能；若工作可獨立平行，依技能指示委派子代理人。

**變更歷程：**

| 日期 | 變更 | 產物 | 原因 |
|---|---|---|---|
| YYYY-MM-DD | 初始建立 | `.codex/agents/`、`.agents/skills/` | - |
````

不要在 `AGENTS.md` 重複完整代理人清單、技能全文或編排細節；這些內容的單一來源是實際 TOML 與技能檔。

Orchestrator 範本見 `references/orchestrator-template.md`。

### Phase 6：驗證與測試

#### 6-1：結構驗證

- 解析所有 `.codex/agents/*.toml`，確認必填欄位與型別正確。
- 解析 `.codex/config.toml`，確認 `[agents]` 數值合理。
- 驗證每個 `SKILL.md` 的 frontmatter、引用路徑與腳本路徑。
- 驗證 `.codex-plugin/plugin.json` 與其中宣告的檔案都存在。
- 搜尋 Claude 專用路徑、工具名稱與模型設定；除非是明確標示的遷移說明，否則不得殘留。

#### 6-2：行為驗證

至少建立：

1. 一個正常流程情境。
2. 一個失敗或部分結果情境。
3. 兩到三個應觸發技能的 prompt。
4. 兩到三個相似但不應觸發技能的 prompt。
5. 一個實際 Dry-run，驗證委派、等待、整合、寫入擁有權與完成條件。

技能評估方法見 `references/skill-testing-guide.md`；QA 角色設計見 `references/qa-agent-guide.md`。

### Phase 7：維護與演化

每次修改先從現況重新稽核，不依賴舊清單。比較：

- `.codex/agents/` 與 Orchestrator 引用的代理人
- `.agents/skills/` 與代理人、Orchestrator 引用的技能
- `AGENTS.md` 指標與實際入口技能
- `.codex/config.toml` 的深度、併發與目前架構

把新增、修改、刪除與原因寫入 `AGENTS.md` 的變更歷程。若回饋指出角色邊界、技能觸發或資料流有問題，修正其單一來源並重跑相關驗證。

## 產物檢查清單

- [ ] 使用 `AGENTS.md`，未建立 `CLAUDE.md`
- [ ] 自訂代理人位於 `.codex/agents/*.toml`
- [ ] 每個代理人都有 `name`、`description`、`developer_instructions`
- [ ] 研究與審查角色採唯讀權限，寫入責任明確
- [ ] 專案技能位於 `.agents/skills/`；外掛技能位於 `skills/`
- [ ] 有一個 Orchestrator 技能，且沒有硬綁內部工具名稱
- [ ] `.codex/config.toml` 只包含必要設定
- [ ] 未固定到使用者未指定的模型
- [ ] 沒有 Claude 專用路徑、工具或旗標殘留
- [ ] 正常、失敗、觸發、非觸發與 Dry-run 測試都有結果
- [ ] 外部憑證需求已列出且未寫入儲存庫
- [ ] 變更歷程與實際檔案一致

## 參考資料

- `references/agent-design-patterns.md`：模式選擇、代理人拆分與重複使用
- `references/orchestrator-template.md`：Codex Orchestrator 範本
- `references/team-examples.md`：多代理配置範例
- `references/skill-writing-guide.md`：技能撰寫與漸進式揭露
- `references/skill-testing-guide.md`：觸發、基準與行為測試
- `references/qa-agent-guide.md`：整合一致性與 QA 代理人
