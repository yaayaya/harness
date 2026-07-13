<p align="center">
  <img src="harness_banner.png" alt="Harness Banner" width="600">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-1.2.0-brightgreen.svg" alt="Version">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple.svg" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/Patterns-6_Architectures-orange.svg" alt="6 Architecture Patterns">
  <img src="https://img.shields.io/badge/Mode-Agent_Teams-green.svg" alt="Agent Teams">
  <a href="https://github.com/revfactory/harness/stargazers"><img src="https://img.shields.io/github/stars/revfactory/harness?style=social" alt="GitHub Stars"></a>
</p>

<p align="center">
  <a href="#category--where-harness-sits"><img src="https://img.shields.io/badge/Layer-L3%20Meta--Factory-orange" alt="Layer"></a>
  <a href="#category--where-harness-sits"><img src="https://img.shields.io/badge/Sub--layer-Team--Architecture%20Factory-teal" alt="Sub-layer"></a>
  <a href="#"><img src="https://img.shields.io/badge/Runtime-Claude%20Code-lightgrey" alt="Runtime support"></a>
</p>

# Harness — Claude Code 的團隊架構工廠

**繁體中文** | [English](README_EN.md) | [한국어](README_KO.md) | [日本語](README_JA.md)

> **Harness 是 Claude Code 的團隊架構工廠。** 只要輸入 **"build a harness for this project"**、`「幫我為這個專案配置 Harness」`、`「하네스 구성해줘」` 或 `「ハーネスを構成して」`，外掛就會將你的領域描述轉換成代理人團隊與其使用的技能，並從六種預先定義的團隊架構模式中挑選最合適的配置。

## 概要

Harness 運用 Claude Code 的 agent team 系統，將複雜任務拆解成由多個專職代理人協作完成的工作流程。輸入「build a harness for this project」後，它會根據你的領域自動產生代理人定義（`.claude/agents/`）與技能（`.claude/skills/`）。

## 類別定位 — Harness 位在哪一層

Harness 位於 agent coding runtime 生態系中的 **L3 Meta-Factory** 層，也就是「用來生成其他 harness，而不是自己作為 harness」的那一層。在 L3 裡，它定位在一個更具體的子層：**Team-Architecture Factory**。

| 層級 | 功能 | 相鄰專案 |
|------|------|----------|
| **L3 — Meta-Factory / Team-Architecture Factory**（本專案） | 將領域描述轉成代理人團隊與技能，並套用 6 種預定義團隊模式 | — |
| L3 — Meta-Factory / Runtime-Configuration Factory | 產生可重現、可預測的執行環境設定 | [coleam00/Archon](https://github.com/coleam00/Archon) |
| L3 — Meta-Factory / Codex Runtime Port | 相同概念的 Codex runtime 移植版 | [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) |
| L2 — Cross-Harness Workflow | 在多個 harness 之間標準化 skills、rules、hooks | [affaan-m/ECC](https://github.com/affaan-m/everything-claude-code) |

> Archon 負責產生可重現的 runtime 設定；Harness 則負責產生團隊架構，例如 Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation，以及各代理人會用到的技能。兩者同屬 L3，但處於不同子層。若你需要執行環境的一致性，選 Archon；若你需要代理人團隊設計，選 Harness；也可以兩者搭配使用。

## 星標歷史

<a href="https://www.star-history.com/?repos=revfactory%2Fharness&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=revfactory/harness&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=revfactory/harness&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=revfactory/harness&type=date&legend=top-left" />
 </picture>
</a>

## 主要特色

- **Agent Team Design**：提供 6 種架構模式，包含 Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation
- **Skill Generation**：自動產生符合領域需求的技能，並採用 Progressive Disclosure 管理上下文
- **Orchestration**：支援代理人之間的資料傳遞、錯誤處理與協調流程
- **Validation**：提供觸發驗證、dry-run 測試，以及有技能與無技能的比較測試

## Harness 演化機制

Harness 的演化機制會把真實使用後的差異回饋到工廠中，例如哪些設計有效、哪些設計需要修正，讓下一次產生相似領域的 harness 時更接近實戰版本。當一個生成的 harness 在真實專案中被使用後，`/harness:evolve` 技能會擷取初始架構與最終交付版本之間的差異，再把這些差異送回工廠。

```
Initial harness ──▶ Real project use ──▶ Shipped harness
                                              │
                                              ▼ (delta capture via /harness:evolve)
                                        ┌───────────────┐
                                        │  Factory      │◀── better next-gen draft
                                        └───────────────┘
```

這套機制被稱為 **Harness Evolution Mechanism**。

## 工作流程

``` 
Phase 1: 領域分析
    ↓
Phase 2: 團隊架構設計（Agent Teams 與 Subagents）
    ↓
Phase 3: 產生代理人定義（`.claude/agents/`）
    ↓
Phase 4: 產生技能（`.claude/skills/`）
    ↓
Phase 5: 整合與協調
    ↓
Phase 6: 驗證與測試
```

## 安裝方式

### Claude Code Marketplace 安裝

#### 加入 Marketplace
```shell
/plugin marketplace add revfactory/harness
```

#### 安裝外掛
```shell
/plugin install harness@harness
```

### 直接安裝為全域 Skill

```shell
# 將 skills 目錄複製到 ~/.claude/skills/harness/
cp -r skills/harness ~/.claude/skills/harness
```

## 外掛結構

```
harness/
├── .claude-plugin/
│   └── plugin.json                 # Claude Code plugin manifest
├── skills/
│   └── harness/
│       ├── SKILL.md                # Claude Code 版 Harness skill
│       └── references/
│           ├── agent-design-patterns.md   # 6 種架構模式
│           ├── orchestrator-template.md   # Team/Subagent 協調器範本
│           ├── team-examples.md           # 5 組真實世界團隊配置
│           ├── skill-writing-guide.md     # Skill 撰寫指南
│           ├── skill-testing-guide.md     # 測試與評估方法
│           └── qa-agent-guide.md          # QA agent 整合指南
└── README.md
```

## 使用方式

在 Claude Code 中，可以用下面這類 prompt 觸發：

```
為這個專案建立一個 harness
為這個領域設計一個代理人團隊
設定一個 harness
```

### 執行模式

| 模式 | 說明 | 適用情境 |
|------|------|----------|
| **Agent Teams**（預設） | TeamCreate + SendMessage + TaskCreate | 2 個以上代理人需要協作時 |
| **Subagents** | 直接呼叫 Agent 工具 | 單次任務、不需要代理人彼此溝通時 |

<p align="center">
  <img src="harness_team.png" alt="Harness Agent Team" width="500">
</p>

### 架構模式

| 模式 | 說明 |
|------|------|
| Pipeline | 依序執行、彼此相依的任務 |
| Fan-out/Fan-in | 可平行處理、再匯總結果的任務 |
| Expert Pool | 依上下文選擇性呼叫專家代理人 |
| Producer-Reviewer | 先生成，再經過品質審查 |
| Supervisor | 由中央代理人動態分派任務 |
| Hierarchical Delegation | 自上而下的層級式委派 |

## 輸出內容

Harness 會生成的檔案如下：

```
your-project/
├── .claude/
│   ├── agents/          # 代理人定義檔
│   │   ├── analyst.md
│   │   ├── builder.md
│   │   └── qa.md
│   └── skills/          # Skill 檔案
│       ├── analyze/
│       │   └── SKILL.md
│       └── build/
│           ├── SKILL.md
│           └── references/
```

## 使用情境 — 試試這些 Prompt

安裝完成後，你可以把以下 prompt 直接貼進 Claude Code：

**深度研究**
```
為深度研究建立一個 harness。我需要一個代理人團隊，能從多個角度
研究任何主題，例如網路搜尋、學術來源與社群觀點，然後交叉驗證結論，
最後產出完整報告。
```

**網站開發**
```
為全端網站開發建立一個 harness。團隊需要能在同一條協作流程中處理
設計、前端（React/Next.js）、後端（API）與 QA 測試，從線框稿一路
推進到部署。
```

**Webtoon / 漫畫製作**
```
為 Webtoon 單集製作建立一個 harness。我需要負責劇情撰寫、角色設計
prompt、分鏡版面規劃與對白編修的代理人，並且讓他們彼此審查作品，
以維持風格一致性。
```

**YouTube 內容規劃**
```
為 YouTube 內容創作建立一個 harness。團隊需要研究熱門主題、撰寫腳本、
優化標題與標籤以利 SEO，並規劃縮圖概念，全部由一位 supervisor agent
統籌協調。
```

**程式碼審查與重構**
```
為全面程式碼審查建立一個 harness。我希望有多個平行代理人分別檢查
架構、安全漏洞、效能瓶頸與程式風格，最後再把所有發現整合成一份報告。
```

**技術文件撰寫**
```
建立一個能從這份程式碼庫產生 API 文件的 harness。代理人需要分析端點、
撰寫說明、生成使用範例，並檢查內容是否完整。
```

**資料管線設計**
```
為資料管線設計建立一個 harness。我需要能處理 schema 設計、ETL 邏輯、
資料驗證規則與監控設定的代理人，並且支援階層式委派子任務。
```

**行銷活動規劃**
```
為行銷活動建立一個 harness。團隊需要研究目標市場、撰寫廣告文案、
設計視覺概念，並安排 A/B 測試計畫與反覆品質審查。
```

## 生態共存 — Harness 與相鄰專案

Harness 並不是 Claude Code / agent framework 生態系中唯一的選項。以下專案位於相鄰層級，各自擁有不同定位，可依需求單獨選用或搭配使用。

| Repo | 他們的定位 | 與 Harness 的關係 |
|------|------------|-------------------|
| [coleam00/Archon](https://github.com/coleam00/Archon) | 「harness builder」, 著重可重現的 runtime 設定 | **同屬 L3、不同子層。** Archon 是 Runtime-Configuration Factory，Harness 是 Team-Architecture Factory。 |
| [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) | 相同概念的 Codex 移植版 | **同屬 L3、不同發行路線。** 本 fork 內建 Codex plugin；meta-harness 可作為另一個 Codex 參考實作。 |
| [affaan-m/ECC](https://github.com/affaan-m/everything-claude-code) | 建立在既有 harness 上方的工作流標準化層 | **不同層級。** ECC 負責標準化，Harness 負責生成 harness。 |
| [wshobson/agents](https://github.com/wshobson/agents) | Subagent / skill catalog | **像零件供應與工廠的關係。** Harness 負責設計團隊，wshobson/agents 可作為可吸收的零件庫。 |
| [LangGraph](https://langchain-ai.github.io/langgraph/) | 狀態圖導向、LLM 無關的編排框架 | **不同路線。** LangGraph 側重長時間執行與狀態恢復，Harness 側重 Claude Code 原生的快速團隊設計。 |

## 使用 Harness 建立的成果

### Harness 100

**[revfactory/harness-100](https://github.com/revfactory/harness-100)** — 橫跨 10 個領域的 100 套可投入生產的 agent team harness，提供英文與韓文版本（共 200 套）。每一套 harness 都包含 4 到 5 個專職代理人、一個 orchestrator skill，以及領域專用技能，全部由本外掛生成。整體涵蓋 1,808 份 Markdown 檔，主題橫跨內容創作、軟體開發、資料/AI、商業策略、教育、法律、健康等。

### 研究：Harness 效果 A/B 測試

**[revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)** — 一項針對 15 個軟體工程任務的對照實驗，用來測量有無結構化預先配置時，LLM 程式代理人的輸出品質差異。

| 指標 | 未使用 Harness | 使用 Harness | 改善幅度 |
|------|:-:|:-:|:-:|
| 平均品質分數 | 49.5 | 79.3 | **+60%** |
| 勝率 | — | — | **100%**（15/15） |
| 輸出變異 | — | — | **-32%** |

關鍵結論：任務越複雜，效果提升越明顯。Basic 任務提升 +23.8、Advanced 任務提升 +29.6、Expert 任務提升 +36.2。

**建議統一引用說法：** +60% 平均品質（49.5 → 79.3）、15/15 勝率、−32% 變異（n=15，作者自測 A/B，第三方重現仍待驗證）。

> 完整論文：*Hwang, M. (2026). Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality.*

## 使用需求

- [啟用 Agent Teams](https://code.claude.com/docs/en/agent-teams): `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## FAQ

<details>
<summary><b>Q1. 「+60%」是不是有點誇大？</b></summary>

**A.** `+60%` 來自 **作者自測的 A/B 實驗（n=15，15 個任務，於姊妹專案 `claude-code-harness` 上量測）**。本 repo 的引用都會在同一句中附上「n=15、作者自測、第三方重現待驗證」這個揭露。若你要用於導入評估，建議還是做一個 2 到 4 週的內部 pilot，以你的場景重新量測。

**證據：**
- 作者 A/B 測試：[revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)
- Paper: *Hwang, M. (2026). Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality*
</details>

<details>
<summary><b>Q2. 為什麼叫「harness factory」而不是「harness builder」？這樣不會跟 Archon 競爭嗎？</b></summary>

**A.** Archon 產生的是可重現的 runtime 設定，也就是 **Runtime-Configuration Factory**；Harness 產生的是代理人團隊架構，例如團隊結構、訊息協定、審查關卡，也就是 **Team-Architecture Factory**。兩者是 **同一個 L3 Meta-Factory 底下的相鄰子層**，解決的不是同一個問題。需要 runtime 一致性就選 Archon，需要團隊架構設計就選 Harness，也可以兩者串接使用。

**證據：**
- Archon 自我定義：[clawfit docs/reference-levels.md](https://github.com/hongsw/clawfit/blob/main/docs/reference-levels.md)
- 子層宣告：請見上方 **類別定位 — Harness 位在哪一層**
- Archon repo：[github.com/coleam00/Archon](https://github.com/coleam00/Archon)
</details>

<details>
<summary><b>Q3. 只有 Claude Code 會不會太受限？Gemini 或 Codex 呢？</b></summary>

**A.** 目前官方 runtime 只有 Claude Code。相同概念的 Codex 移植版 [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) 已經公開，Codex 團隊可以從該專案開始。Harness 選擇「深入且原生支援 Claude Code」，而不是「支援多種 runtime 但各自較淺」；未來規劃與 meta-harness、harness-init、OpenRig 等姊妹專案進行跨 runtime 協作。

**證據：**
- Codex 移植版：[github.com/SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness)
- 跨 runtime 腳手架：[github.com/Gizele1/harness-init](https://github.com/Gizele1/harness-init)
</details>

## 授權

Apache 2.0

