<p align="center">
  <img src="harness_banner.png" alt="Harness" width="760">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Codex-Plugin-10A37F.svg" alt="Codex Plugin">
  <img src="https://img.shields.io/badge/Language-繁體中文-blue.svg" alt="繁體中文">
  <img src="https://img.shields.io/badge/License-Apache--2.0-orange.svg" alt="Apache-2.0">
  <img src="https://img.shields.io/badge/Version-2.1.0-purple.svg" alt="2.1.0">
</p>

# Harness — Codex 團隊架構工廠

Harness 是一組 Codex meta-skills：`$harness` 會把專案或領域需求轉換成可重複使用的自訂代理人、技能與多代理工作流程；`$harness-packager` 會把完成的團隊搬到其他 repo。

輸入「幫我為這個專案配置 Harness」或明確叫用 `$harness`，Codex 會分析工作階段、選擇團隊架構、產生原生設定，並建立可驗證與可持續維護的 Harness。

## 這個分支的定位

`codex` 分支是以 Codex 為唯一執行環境的版本。它不是在舊格式上做名稱替換，而是採用 Codex 原生結構：

| 功能 | Codex 產物 |
|---|---|
| 專案持久指示 | `AGENTS.md` |
| 自訂代理人 | `.codex/agents/*.toml` |
| 專案技能 | `.agents/skills/{name}/SKILL.md` |
| 多代理設定 | `.codex/config.toml` |
| 可攜團隊套件 | `<name>.harness/` |
| 可安裝外掛 | `.codex-plugin/plugin.json` |
| 儲存庫 Marketplace | `.agents/plugins/marketplace.json` |

舊版 Claude 專用的 `.claude/agents/*.md`、`.claude/skills/`、`CLAUDE.md`、Team API 與固定 Opus 模型設定，不會出現在 Harness 產物中。

## 核心能力

- **領域分析**：從業務結果、資料流、風險與驗收條件找出真正需要的角色。
- **自訂代理人**：產生 Codex TOML 代理人，包含責任、權限、工具、輸入、輸出與失敗處理。
- **技能設計**：產生符合 Agent Skills 格式的 `SKILL.md`、references、scripts 與 assets。
- **多代理編排**：支援 Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor 與 Hierarchical Delegation。
- **權限設計**：研究與審查角色預設唯讀，只有指定實作者擁有寫入權。
- **驗證與維護**：檢查結構、觸發、資料流、失敗情境、漂移與實際 Dry-run。
- **跨 repo 搬移**：把目前 Harness 封裝成免壓縮的 `.harness` 資料夾，在另一個 repo 安裝或更新。

## 工作流程

```text
Phase 0：稽核 AGENTS.md、.codex/agents、.agents/skills 與既有設定
    ↓
Phase 1：分析領域、輸入、輸出、風險與驗收條件
    ↓
Phase 2：選擇單一、平行、階段式或混合多代理模式
    ↓
Phase 3：建立 .codex/agents/*.toml
    ↓
Phase 4：建立 .agents/skills/*/SKILL.md
    ↓
Phase 5：建立 Orchestrator 技能並在 AGENTS.md 註冊入口
    ↓
Phase 6：結構、觸發、失敗與 Dry-run 驗證
    ↓
Phase 7：記錄變更並持續修正漂移
```

## 安裝

### 方法一：透過 Codex Marketplace 安裝

在儲存庫外執行：

```powershell
powershell -NoProfile -Command "codex plugin marketplace add yaayaya/harness-codex --ref codex"
```

重新啟動 ChatGPT 桌面版或 Codex，開啟 Plugins，選擇 `Harness Codex` marketplace，再安裝 `Harness`。

也可以在 Codex CLI 輸入 `/plugins` 瀏覽已加入的 marketplace 與外掛。

### 方法二：本機開發連結

在本專案根目錄執行：

```powershell
powershell -NoProfile -Command "codex plugin marketplace add ."
```

重新啟動 ChatGPT 桌面版，從 `Harness Codex` marketplace 安裝。修改外掛後，重新整理 marketplace 並重啟應用程式，使安裝快取載入新版本。

### 方法三：只安裝 Harness Skills

如果不需要外掛安裝介面，可直接複製兩個技能到個人技能目錄：

```powershell
powershell -NoProfile -Command '$target = Join-Path $HOME ".agents\skills"; New-Item -ItemType Directory -Force $target | Out-Null; Copy-Item -Recurse -Force .\skills\harness (Join-Path $target "harness"); Copy-Item -Recurse -Force .\skills\harness-packager (Join-Path $target "harness-packager")'
```

重新開啟 Codex 後，可用 `$harness` 或 `$harness-packager` 明確叫用，也可以直接描述需求讓 Codex 依 description 判斷是否使用。

## 快速開始

在目標專案中開啟 Codex，輸入：

```text
$harness 幫我為這個專案建立 Codex Harness。
先分析現有架構，再建立自訂代理人、專案技能、Orchestrator 與驗證流程。
所有研究與審查角色保持唯讀，只有一位實作者可以修改同一份產物。
```

也可以使用自然語言：

- 「幫我為金融科技風險評估流程配置 Harness。」
- 「建立一套 Producer-Reviewer 的 Codex 工作流程。」
- 「檢查目前 `.codex/agents`、`.agents/skills` 與 `AGENTS.md` 是否同步。」
- 「把這個專案現有的其他代理平台設定遷移成 Codex 原生格式。」

完成後通常會產生：

```text
目標專案/
├── AGENTS.md
├── .codex/
│   ├── config.toml
│   └── agents/
│       ├── domain-explorer.toml
│       ├── domain-worker.toml
│       └── domain-reviewer.toml
├── .agents/
│   └── skills/
│       ├── domain-orchestrator/
│       │   ├── SKILL.md
│       │   └── references/
│       └── domain-validator/
│           └── SKILL.md
└── _workspace/
    └── 階段性產物
```

詳細操作請參閱 [快速開始](docs/quickstart.md)。

## 封裝與搬移團隊

Harness Plugin 已包含 `$harness-packager`，不需要安裝 Node、Python、npm 套件或 global CLI。

在已完成 Harness 的來源 repo 中輸入：

```text
$harness-packager 打包目前團隊
```

預設產生 `dist/<name>.harness/`。也可以指定位置：

```text
$harness-packager 把目前團隊打包到 D:\MyHarnessPackages
```

使用者可把整個 `<name>.harness` 資料夾複製到另一個 repo，然後在目標 repo 輸入：

```text
$harness-packager 安裝 .\<name>.harness
```

若套件在其他位置，也能直接提供絕對路徑。第一次執行會安裝，之後以同一指令套用新版；Skill 只更新該套件管理的 agents、skills、AGENTS 區塊與 `[agents]` 設定，其他 repo 內容不變。更新前會自動備份到 `.harness/backups/`。

## 團隊架構模式

| Pattern | 適用情境 | Codex 執行方式 |
|---|---|---|
| Pipeline | 工作有固定前後依賴 | 階段式委派，每階段驗證後交接 |
| Fan-out/Fan-in | 多個獨立來源或面向 | 平行子代理人，主代理人等待後整合 |
| Expert Pool | 同一問題需要不同專業判準 | 平行專家審查，主代理人解決衝突 |
| Producer-Reviewer | 產出需要獨立品質關卡 | 單一寫入者產出，唯讀審查者驗收 |
| Supervisor | 工作類型會隨結果改變 | 主代理人依狀態動態委派 |
| Hierarchical Delegation | 多個大型子領域各自需要分工 | 提高代理深度並限制遞迴與成本 |

Codex 子代理人會消耗額外 token。Harness 預設只為可獨立、能降低上下文污染或需要不同權限的工作使用多代理。

## 專案結構

```text
harness/
├── .codex-plugin/
│   └── plugin.json
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── skills/
│   ├── harness/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── agent-design-patterns.md
│   │       ├── orchestrator-template.md
│   │       ├── team-examples.md
│   │       ├── skill-writing-guide.md
│   │       ├── skill-testing-guide.md
│   │       └── qa-agent-guide.md
│   └── harness-packager/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/package-format.md
│       └── scripts/harness_packager.ps1
├── docs/
│   ├── quickstart.md
│   └── codex-compatibility.md
└── scripts/
    └── validate_codex_harness.py
```

## 外部服務與 API Key

Harness 本身不需要 OpenAI API Key；使用 ChatGPT 帳號登入 Codex 即可使用外掛與技能。

只有產生出的代理人需要連接外部 MCP、私有 API 或其他服務時，才需要額外憑證。開始整合前應先向使用者確認：

- 服務與環境名稱
- Base URL 或 MCP 端點
- 驗證方式
- 環境變數名稱
- 最小權限範圍
- 可使用的測試帳號或測試資料

不得把 API Key、token 或密碼提交到專案。

## 驗證

```powershell
powershell -NoProfile -Command "python .\scripts\validate_codex_harness.py"
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test_harness_packager.ps1
```

驗證器會檢查外掛 manifest、Marketplace、Skill frontmatter、Codex 路徑與平台殘留；Packager 測試會實際驗證打包、安裝、更新、回復與損壞拒絕。

## 參考文件

- [Codex Skills 與 Plugins](https://learn.chatgpt.com/docs/skills-and-plugins)
- [建立 Codex Plugins](https://learn.chatgpt.com/docs/build-plugins)
- [Codex Subagents 與自訂代理人](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Codex 客製化概覽](https://learn.chatgpt.com/docs/customization/overview)

## 授權與致謝

本專案以 [Apache License 2.0](LICENSE) 授權。

Harness 原始方法與內容由 [revfactory/harness](https://github.com/revfactory/harness) 建立；本分支由 `yaayaya` 進行繁體中文與 Codex 原生化改造。保留原作者的架構思想、研究脈絡與授權聲明。
