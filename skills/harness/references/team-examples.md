# Codex 多代理配置範例

以下範例展示如何把六種架構模式實作為 Codex 自訂代理人與 Orchestrator 技能。代理人使用 `.codex/agents/*.toml`；專案技能使用 `.agents/skills/*/SKILL.md`。

## 範例 1：研究團隊

### 架構

Fan-out/Fan-in。四位唯讀研究者平行蒐集，主代理人等待所有結果後整合。

```text
主代理人
├── official_researcher
├── media_researcher
├── community_researcher
└── background_researcher
        ↓
主代理人查證、去重、解決衝突並產出報告
```

### 代理人

| 代理人 | 範圍 | 權限 | 輸出 |
|---|---|---|---|
| `official_researcher` | 官方文件、公告、規範 | 唯讀 | 來源、日期、摘要、可信度 |
| `media_researcher` | 媒體、產業與投資資訊 | 唯讀 | 來源、觀點、可能偏誤 |
| `community_researcher` | 社群回饋與實務案例 | 唯讀 | 代表性案例、限制、時間性 |
| `background_researcher` | 歷史、競品與學術背景 | 唯讀 | 對照表、差異、引用 |

### Orchestrator 重點

1. 先定義日期範圍、來源資格與共同輸出 schema。
2. 平行委派四個互不重疊的任務。
3. 等待所有必要結果；失敗來源要標成覆蓋缺口。
4. 主代理人查證重複或矛盾說法。
5. 最終報告把事實、推論與未證實說法分開。

### 代理人 TOML 範例

`.codex/agents/official-researcher.toml`：

```toml
name = "official_researcher"
description = "唯讀研究者，負責官方文件、公告、規格與政策來源。"
sandbox_mode = "read-only"
developer_instructions = """
優先使用第一方與權威來源。
每項結論包含來源、發布日期、事件日期與直接支持的主張。
區分來源事實與你的推論；資料可能過時時要明確標示。
只回傳精簡摘要與可追溯證據，不修改專案檔案。
"""
```

## 範例 2：科幻小說設計團隊

### 架構

混合模式：世界觀、角色與情節先平行草擬，再由 continuity editor 整合，最後由 science reviewer 審查。

```text
worldbuilder ───────┐
character_designer ─┼→ continuity_editor → science_reviewer
plot_architect ─────┘
```

### 角色邊界

| 代理人 | 核心責任 | 不負責 |
|---|---|---|
| `worldbuilder` | 物理規則、社會結構、歷史背景 | 最終角色弧線 |
| `character_designer` | 人物動機、關係、成長曲線 | 改寫世界物理規則 |
| `plot_architect` | 事件因果、節奏、伏筆 | 最終一致性裁決 |
| `continuity_editor` | 解決設定衝突並建立唯一 bible | 無證據新增設定 |
| `science_reviewer` | 檢查科學可信度與內在一致性 | 直接修改最終 bible |

### 資料流

- 三位設計者寫入 `_workspace/02_{agent}_draft.md`。
- `continuity_editor` 是唯一可修改 `_workspace/03_story_bible.md` 的角色。
- `science_reviewer` 回傳具體衝突、證據與修正條件。
- 若修正會改變核心創作方向，主代理人先向使用者確認。

## 範例 3：Webtoon Producer-Reviewer

### 架構

Producer-Reviewer。Producer 建立分鏡與腳本，Reviewer 唯讀檢查節奏、連續性與平台規格。

| 代理人 | 權限 | 輸出 |
|---|---|---|
| `webtoon_producer` | 可寫入 | 腳本、分鏡、驗證摘要 |
| `webtoon_reviewer` | 唯讀 | 缺陷、證據、嚴重度、驗收條件 |

`.codex/agents/webtoon-reviewer.toml`：

```toml
name = "webtoon_reviewer"
description = "唯讀 Webtoon 品質審查者，檢查節奏、角色一致性、畫面可讀性與平台規格。"
sandbox_mode = "read-only"
developer_instructions = """
依需求與平台規格審查，不以個人風格偏好取代驗收條件。
每項發現包含頁面或場景位置、問題、讀者影響與可驗收的修正條件。
區分阻擋發布的問題與可選改進。
不要直接修改腳本或分鏡。
"""
```

### 迭代限制

1. Producer 產出第一版。
2. Reviewer 審查。
3. 主代理人過濾無證據意見。
4. Producer 修正一次。
5. 執行最終驗收；仍有阻擋項目則回報，不進入無限迭代。

## 範例 4：程式碼審查團隊

### 架構

Expert Pool + Fan-out/Fan-in。所有審查者唯讀，主代理人去重與排序。

```text
security_reviewer ────┐
correctness_reviewer ─┼→ 主代理人 → 可執行 findings
test_reviewer ────────┤
performance_reviewer ─┘
```

### 共同 finding schema

```json
{
  "title": "簡短問題名稱",
  "severity": "critical | high | medium | low",
  "file": "相對路徑",
  "line": 1,
  "evidence": "可重現或可驗證的證據",
  "impact": "實際行為或風險",
  "suggested_test": "能證明修正有效的測試"
}
```

### 主代理人整合規則

- 合併同一根因的重複 findings。
- 無法重現、沒有實際影響或只有風格偏好的項目不列為缺陷。
- 對嚴重度分歧回查證據。
- 依嚴重度排序，附上檔案與行號。
- 審查工作本身不修改程式碼；若使用者要求修正，再另派單一 `worker` 或實作者。

## 範例 5：大型遷移 Supervisor

### 架構

Supervisor。主代理人依批次狀態選擇探索、實作、測試或審查代理人。

```text
主代理人
├── migration_mapper   # 唯讀，建立相依圖與批次
├── migration_worker   # 單一批次寫入者
├── migration_tester   # 驗證該批次
└── migration_reviewer # 唯讀複審風險
```

### 執行邏輯

1. `migration_mapper` 產生批次清單、相依性、風險與驗收命令。
2. 主代理人一次選擇一個可執行批次。
3. `migration_worker` 只修改該批次範圍。
4. `migration_tester` 執行對應驗證。
5. 測試失敗時，主代理人把證據交回同一寫入者修正。
6. 高風險批次由 `migration_reviewer` 唯讀複審。
7. 一個批次通過後才解鎖相依批次。

### 專案設定

`.codex/config.toml`：

```toml
[agents]
max_threads = 4
max_depth = 1
```

即使批次很多，也不讓子代理人再自行委派；主代理人保留全域狀態與寫入控制。

## 產物結構摘要

```text
專案/
├── AGENTS.md
├── .codex/
│   ├── config.toml
│   └── agents/
│       ├── official-researcher.toml
│       ├── webtoon-reviewer.toml
│       └── migration-worker.toml
├── .agents/
│   └── skills/
│       ├── domain-orchestrator/
│       │   ├── SKILL.md
│       │   └── references/
│       └── domain-validator/
│           └── SKILL.md
└── _workspace/
    ├── 02_researcher_findings.md
    └── 03_integrated_output.md
```

## 設計檢查

- 每位代理人是否有唯一責任與可驗證輸出？
- 唯讀與寫入權是否符合角色？
- 是否只有一位代理人擁有最終產物？
- 主代理人是否知道要等待哪些結果？
- 結果衝突是否有明確裁決方式？
- 任一代理人失敗時，是否能回報覆蓋缺口或降級？
- 是否避免固定到未經使用者指定的模型？
