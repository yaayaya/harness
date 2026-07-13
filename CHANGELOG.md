# 變更紀錄

本專案遵循 [Semantic Versioning](https://semver.org/)。

## [未發布]

### 新增

- 新增建立 agent/skill 前的重複檢查階段（Phase 3-0、Phase 4-0）
- `references/agent-design-patterns.md` 新增「代理人重複使用設計」章節
- `references/skill-writing-guide.md` 新增第 9 節「技能重複使用設計」

### 變更

- 在 Phase 選擇矩陣中明確列出 3-0/4-0
- 在 Phase 2-3 新增重複使用檢查階段的指引
- 在產物檢查清單新增 2 個重複使用檢查項目

---

## [1.2.1] - 2026-04-18

### 修正

- **版本一致性同步** — `README.md` / `README_KO.md` / `README_JA.md` 的 badge 顯示 `v1.0.1`、`.claude-plugin/marketplace.json` 為 `1.1.0`、`.claude-plugin/plugin.json` 為 `1.2.0`，原本共有三處版本不一致；現已全部統一為 **v1.2.0**（以 `plugin.json` 為準）
- **為解決「尚無 tagged release」狀態預作準備** — 制定 `v1.0.0` / `v1.0.1` / `v1.1.0` / `v1.2.0` 的補標籤計畫（請參考 `_workspace/release/audit-2026-04-18.md` 第 4 節）

### 新增

- **定位宣告："harness factory"** — 在 README 頂部加入類別自我定義文字，強調這是一個「能依領域產出 agent 與 skill 的 harness factory」，以便與單一 agent / prompt framework 做出區隔
- **`CONTRIBUTING.md`** — 新增貢獻指南與 SLA，明確標示 PR 首次回應 72 小時內、Issue triage 48 小時內，降低社群參與門檻
- **`docs/` 目錄** — 新增長篇文件的放置空間，用於後續存放架構、遷移與模式目錄，避免 README 過度膨脹並提升可搜尋性
- **Issue #3 回應政策** — 新增社群議題的正式回應範本與 triage 流程

### 變更

- `.claude-plugin/marketplace.json` 版本：`1.1.0` → `1.2.0`
- README badge（EN/KO/JA 三個版本）：`Version-1.0.1` → `Version-1.2.0`
- **重寫 `.claude-plugin/plugin.json` 的 description** — 從 `"Agent Team & Skill Architect — Meta-skill that designs..."` 改為 `"The team-architecture factory for Claude Code — a meta-skill that turns a domain description into an agent team and the skills they use, with six pre-defined team-architecture patterns..."`（英韓並列，反映 L3 Meta-Factory 定位）
- **擴充 `.claude-plugin/plugin.json` 的 keywords** — 從 5 個增加到 17 個，新增 `harness-factory`、`team-architecture-factory`、`claude-code-plugin`、`agent-scaffolding`、`multi-agent` 以及 6 種模式相關關鍵字

## [1.2.0] - 2026-04-08

### 變更

- **簡化 `CLAUDE.md` 註冊政策（去除重複）** — 將 Phase 5-4 的「上下文註冊」改為「指標註冊」，從 `CLAUDE.md` 中移除 agent 清單、skill 清單、目錄結構與執行規則細節，只保留 **觸發規則與變更歷史**。agent / skill 清單改由 `.claude/agents/`、`.claude/skills/` 與 orchestrator skill 作為單一來源
- **移除 Phase 3/4 的臨時同步步驟** — 為減少 `CLAUDE.md` 的同步負擔，刪除 Phase 3/4 中的臨時同步指示，最終的指標註冊僅在 Phase 5-4 進行一次
- **重新定義第 3 條核心原則** — 從「在 `CLAUDE.md` 註冊 harness 上下文」改為「在 `CLAUDE.md` 註冊 harness 指標」
- **刪除 `CLAUDE.md` 與 orchestrator 的角色分工表** — 由於指標政策已簡化，該表不再必要

### 新增

- **Phase 2-1：混合執行模式** — 除了 Agent Teams / Subagents 外，新增可按階段混用模式的 hybrid pattern，並明示常見組合（平行蒐集 → 共識整合、先建團隊 → 再驗證、各 Phase 重組團隊）
- **Phase 2-1 執行模式比較表** — 提供 Team / Subagent / Hybrid 三者特性與三步驟決策順序
- **Phase 5-0 混合式 orchestrator pattern** — 規定在 hybrid 配置下，需於各 Phase 開頭標示執行模式
- **Phase 5-1 基於回傳值的資料傳遞** — 為 Subagent 模式新增回傳值導向的資料傳遞策略（在原有訊息 / task / 檔案傳遞之外）
- **Phase 5-1 建議組合（Subagent / Hybrid）** — 明列非 Team 模式下的資料傳遞建議組合

## [1.1.0] - 2026-04-05

### 新增

- **Phase 0：現況稽核** — 觸發時先檢查現有 harness 狀態，再分流到新建、既有擴充或營運維護三種情境
- **既有擴充的 Phase 選擇矩陣** — 依 agent 新增、skill 新增、架構變更，提供所需 Phase 的決策表
- **Phase 3/4 `CLAUDE.md` 臨時同步** — 在 agent / skill 生成後立即寫回 `CLAUDE.md`，提升中斷恢復能力
- **Phase 5-4：於 `CLAUDE.md` 註冊 harness 上下文** — 記錄 agent team 結構、skill 清單、執行規則、目錄結構與變更歷史，並包含 `CLAUDE.md` 與 orchestrator 的角色分工表
- **Phase 5-5：支援後續工作** — 要求 orchestrator description 必須包含後續工作關鍵字，並透過 Phase 0 判別初次執行、局部重跑與新一輪執行
- **Phase 5 orchestrator 修改路徑** — 在既有擴充情境下，提供修改既有 orchestrator 而非重建的指南
- **Phase 7：Harness 演化機制** — 透過執行後回饋蒐集 → 根據回饋類型對應修改對象 → 記錄變更歷史 → 自動觸發演化
- **Phase 7-5：營運 / 維護工作流** — 提供現況稽核 → 漸進式修正 → `CLAUDE.md` 同步 → 變更驗證的四步流程
- **description 中新增營運 / 維護觸發詞** — 例如「harness 點檢」、「harness 稽核」、「harness 現況」、「agent/skill 同步」
- **加強產出檢查清單** — 新增 `CLAUDE.md` 同步完成、變更歷史記錄與 Phase 0 上下文確認項目
- 在 orchestrator 範本中加入 Phase 0（上下文確認）— 適用於 Agent Teams 與 Subagent 兩種模式
- 在 orchestrator description 範本中加入後續工作關鍵字規則

### 變更

- 核心原則從 2 條擴充為 4 條（加入 `CLAUDE.md` 註冊與演化系統）
- **統一將「evolution log」改稱「變更歷史」** — 名稱與格式（4 欄：日期 / 變更內容 / 對象 / 原因）在所有章節一致
- **Phase 1 Step 3** — 改為依據 Phase 0 的稽核結果進行衝突分析，以避免重複工作
- **5-4 `CLAUDE.md` 範本程式區塊** — 修正巢狀渲染錯誤（3 個反引號 → 4 個反引號）
- **擴充角色分工表** — 新增 skill 清單、目錄結構與變更歷史列
- **orchestrator 範本** — 新增 Phase 0 上下文確認與後續工作關鍵字指南

## [1.0.1] - 2026-03-28

### 變更

- 移除 `SKILL.md` 與 `references/` 之間的重複內容（330 行 → 285 行）
  - Phase 2-1：將執行模式比較表 / 條列改為核心原則 + `agent-design-patterns.md` 指標
  - Phase 2-3：將 agent 拆分標準條列改為 4 軸摘要 + `agent-design-patterns.md` 指標
  - Phase 3：將 agent 定義範本程式碼區塊改為必要章節清單 + `references/` 指標
  - Phase 5-2：將錯誤處理 5 列表格改為核心原則 + `orchestrator-template.md` 指標

## [1.0.0] - 2026-03-27

### 新增

- 基於 6 個 Phase 工作流的 harness 建構 meta-skill
- 6 種 agent 架構模式（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
- 支援 Agent Teams / Subagents 執行模式
- 基於 Progressive Disclosure 的 skill 生成指南
- orchestrator 範本（Agent Teams 模式 + Subagent 模式）
- QA agent 整合指南（根據 7 個真實專案 bug 案例）
- skill 測試 / 評估方法（With-skill 與 Without-skill 比較）
- 5 組實戰團隊配置範例（研究、小說、Webtoon、程式碼審查、遷移）
