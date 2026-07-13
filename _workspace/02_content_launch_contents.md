# Harness 發布內容 —— 多平台版本

---

## 1. Hacker News（Show HN）

### 標題

```
Show HN: Harness – A Claude Code plugin that designs AI agent teams from a single prompt
```

### 內文

```
我已經使用 Claude Code 的 agent teams 好幾個月了，但同一個問題一直反覆出現：每次我要建立 multi-agent workflow，都像是在重新發明輪子。定義 agent 角色、撰寫 skill 檔案、判斷該用哪種 coordination pattern、把 agents 之間的資料傳遞接起來——在真正開始工作之前，這些前置作業就要先折騰 2 個小時。

所以我做了 Harness。它是一個 Claude Code plugin——一個「meta-skill」——可以把整個流程自動化。你只要說「build a harness for this project」，它就會執行一條 6-phase pipeline：

  1. 分析你的 domain 與 codebase
  2. 從 6 種 architecture patterns 中選擇（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
  3. 產生 agent definition files（.claude/agents/）
  4. 產生具備 Progressive Disclosure 的 skills（.claude/skills/）
  5. 串接 orchestration，包含 data-passing protocols 與 error handling
  6. 透過 trigger testing 與有／無 skill 的 A/B comparisons 進行驗證

我在 3 個難度層級的 15 個 software engineering tasks 上跑了一組受控實驗。結果如下：

  - 平均品質分數提升 +60%（49.5 → 79.3）
  - 勝率 100%——加上 harness 的版本在 15 次比較中全部勝出
  - 輸出變異降低 32%
  - 效果會隨任務複雜度放大：基礎任務 +23.8、進階任務 +29.6、專家任務 +36.2

這個洞見其實很直接：LLM code agents 很有能力，但缺乏方向。只要先給它們結構化的 pre-configuration——誰負責什麼、要如何協作、什麼才算「完成」——輸出品質就會明顯躍升。

我另外也產生了 100 個 production-ready 的 harness configurations，涵蓋 10 個 domains（內容創作、software dev、data/AI、商業策略、教育等等），並把它們作為 companion repo 開源。總計 1,808 個檔案。

這個 plugin 可搭配 Claude Code 的 experimental Agent Teams system 使用。你可以透過 plugin marketplace 安裝，或直接複製 skill files。

GitHub: https://github.com/revfactory/harness
100 ready-made harnesses: https://github.com/revfactory/harness-100
A/B test results & paper: https://github.com/revfactory/claude-code-harness

如果你想聊 architecture patterns、研究方法，或 meta-skill generation loop 是怎麼運作的，我很樂意回答。
```

---

## 2. Reddit

### 2a. r/ClaudeAI

**標題：** `I built a Claude Code plugin that designs agent teams for you — 60% quality improvement in A/B tests`

**內文：**

```
我在使用 Claude Code 的 agent teams 時，一直碰到同樣的摩擦點：建立 agents、撰寫 skills、選擇 coordination patterns，以及把 orchestration 串起來，花的時間常常比真正的任務還久。

所以我做了 **Harness**——一個 meta-skill（Claude Code Plugin），可以從單一 prompt 完成這一切。

**它的運作方式：**

你只要說「build a harness for this project」，它就會執行一條 6-phase pipeline：
- 分析你的 codebase 與 domain
- 選擇一種 architecture pattern（共 6 種：Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
- 產生 `.claude/agents/` 與 `.claude/skills/` 檔案
- 建立包含 inter-agent communication 的 orchestration
- 透過 trigger tests 與 A/B comparisons 驗證

**最讓我意外的是研究結果：**

我在 15 個 software engineering tasks 上進行了受控的 A/B tests：
- **品質提升 +60%**（平均分數從 49.5 → 79.3）
- **勝率 100%**——加上 harness 的版本每一次比較都贏
- **任務越難，提升越大**——專家等級任務最高提升了 +36.2 分

這其實很符合直覺：你不會在沒有藍圖的情況下，就把一群 contractors 丟去蓋房子。同樣的邏輯也適用於 AI agents。

**延伸資源：**

我另外產生了 [100 個現成的 harnesses](https://github.com/revfactory/harness-100)，涵蓋 10 個 domains（共 1,808 個檔案）。內容創作、software dev、data/AI、marketing、education、legal、health——每一套都包含 4 到 5 個 specialist agents 與 orchestrator skills。

**快速開始：**

```
/plugin marketplace add revfactory/harness
/plugin install harness@harness
```

接著只要說：「Build a harness for [your domain]」

GitHub: https://github.com/revfactory/harness

需要先啟用 Agent Teams：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

如果你也有在用 Claude Code 的 agent teams，很想聽聽你的回饋。你正在為哪些 domains 建構這類流程？
```

### 2b. r/MachineLearning

**標題：** `[P] Harness: Structured Pre-Configuration for LLM Code Agents — +60% Quality, 100% Win Rate in A/B Tests`

**內文：**

```
**TL;DR:** Structured pre-configuration（在執行前先定義 agent roles、coordination patterns 與 skill specifications）可讓 LLM code agents 的輸出品質提升 +60%，並在 15 個任務中取得 100% 勝率。

---

**問題：** 以 LLM 為基礎的 code agents（Claude Code、Cursor 等）能力正越來越強，但輸出品質不穩定。相同模型面對相同任務，可能會因工作結構不同而產生 40/100 或 80/100 的結果。目前沒有系統化的方法能降低這種變異。

**方法：** 我打造了 **Harness**，一個用於 Claude Code 的「meta-skill」，用來自動化 structured pre-configuration。給定一個 domain/project，它會：

1. 分析 task space
2. 從 6 種 multi-agent architecture patterns 中選擇（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
3. 產生具備 role boundaries 與 communication protocols 的 agent definitions
4. 建立採用 Progressive Disclosure（3-tier context loading）的 skills
5. 串接 orchestration 與 error handling
6. 透過 trigger testing 與有／無 skill 的比較進行驗證

**實驗結果**（在 15 個 SE tasks、3 個難度層級上進行受控 A/B）：

| Metric | Without | With | Delta |
|--------|---------|------|-------|
| Avg Quality Score | 49.5 | 79.3 | **+60%** |
| Win Rate | — | — | **15/15 (100%)** |
| Output Variance | — | — | **-32%** |

關鍵發現：**效果會隨任務複雜度放大**。
- Basic tasks: +23.8
- Advanced: +29.6
- Expert: +36.2

這與假設相符：當 search space 很大，而且 agent 需要在多個 subtasks 之間維持 coherence 時，structured decomposition 的重要性會大幅提升。

**Artifacts：**
- Plugin（meta-skill）: https://github.com/revfactory/harness
- 跨 10 個 domains 產生的 100 組 harness configs: https://github.com/revfactory/harness-100
- 實驗方法與結果: https://github.com/revfactory/claude-code-harness

Paper reference: Hwang, M. (2026). "Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality."

如果你想討論實驗設計、pattern selection heuristics，或 progressive disclosure mechanism，我很樂意交流。
```

### 2c. r/programming

**標題：** `Show r/programming: A plugin that auto-generates multi-agent AI teams from your codebase — with A/B tested results`

**內文：**

```
我最近一直在使用 Claude Code 的 agent teams——可以把它想像成同時生成多個會彼此協作的 AI「workers」來處理複雜任務。問題在於：建立這些 teams 很麻煩。你得定義角色、寫 skill files、挑 coordination pattern、接資料傳遞、處理錯誤。每。次。都。要。

**Harness** 是一個能把這一切自動化的 Claude Code plugin。一個 prompt → 完整 agent team。

**它實際會產生什麼：**

```
your-project/
├── .claude/
│   ├── agents/          # Agent definitions (roles, protocols, comms)
│   │   ├── analyst.md
│   │   ├── builder.md
│   │   └── qa.md
│   └── skills/          # What each agent knows how to do
│       ├── analyze/
│       │   └── skill.md
│       └── build/
│           ├── skill.md
│           └── references/
```

**它會從這 6 種 architecture patterns 中選擇：**

- **Pipeline** —— A → B → C（code gen → review → test → deploy）
- **Fan-out/Fan-in** —— 平行 agents，最後合併結果（multi-reviewer code audit）
- **Expert Pool** —— 動態挑選正確的 specialist
- **Producer-Reviewer** —— 一個負責建構，一個負責 QA
- **Supervisor** —— 由中央 coordinator 派發任務
- **Hierarchical Delegation** —— 遞迴式的 top-down decomposition

**它真的有效嗎？**

我跑了一個受控實驗。15 個 tasks。3 個難度層級。比較有 harness 與沒有 harness。

- 品質分數提升 +60%
- 勝率 100%（15/15）
- 輸出變異降低 32%
- 專家等級任務獲益最大（+36.2 分）

另外那個 companion repo 也提供了 100 套預先建好的 harnesses，橫跨 10 個 domains：https://github.com/revfactory/harness-100

**安裝方式：**

```
/plugin marketplace add revfactory/harness
/plugin install harness@harness
```

接著輸入：「Build a harness for this project」

Source: https://github.com/revfactory/harness

需要使用已啟用 Agent Teams 的 Claude Code。
```

---

## 3. Twitter/X 討論串

### Tweet 1 —— Hook

```
我做了一個能設計 AI agent teams 的工具。

不是單一 agent——而是完整、彼此協作的 teams，包含 roles、skills、communication protocols 與 orchestration。

一個 prompt。完整團隊。A/B tests 顯示品質提升 60%。

它叫做 Harness，而且是 open source。

🧵👇
```

### Tweet 2 —— 問題

```
AI code agents 的問題在於：

它們很有能力，但缺乏方向。

相同模型、相同任務 → 品質卻可能差很多。有時 40/100，有時 80/100。

缺少的不是智慧，而是結構。

[IMAGE: 並排比較圖，展示零散 vs. 有組織的 agent output]
```

### Tweet 3 —— 解法

```
Harness 是一個 Claude Code Plugin——一個能設計 multi-agent teams 的「meta-skill」。

只要說「build a harness for this project」，它就會跑完一條 6-phase pipeline：

1. Domain Analysis
2. Architecture Design (6 patterns)
3. Agent Definition Generation
4. Skill Generation
5. Orchestration
6. Validation & Testing

[IMAGE: 顯示 6 個 phases 的 workflow diagram]
```

### Tweet 4 —— Architecture Patterns

```
6 種經過驗證的 coordination patterns：

→ Pipeline: sequential（gen → review → test）
⟐ Fan-out/Fan-in: parallel 後再 merge
♠ Expert Pool: 挑選合適的 specialist
⇄ Producer-Reviewer: build 後再 QA
◆ Supervisor: 中央 dispatch
△ Hierarchical: 遞迴 delegation

它會替你的 domain 選出最適合的一種。

[IMAGE: 6 張 architecture pattern cards 的視覺圖]
```

### Tweet 5 —— 研究

```
我不只把它做出來——我還實際量測了它的效果。

15 個 software engineering tasks。3 個難度層級。受控 A/B tests。

結果：
• 平均品質分數提升 +60%
• 勝率 100%（15/15 tasks）
• 輸出變異 -32%
• 任務越難 = 提升越大

這種效果會隨複雜度放大。

[IMAGE: landing page 上的長條圖，展示 Basic/Advanced/Expert 結果]
```

### Tweet 6 —— Scaling Insight

```
這就是關鍵洞見：

Basic tasks: +23.8 improvement
Advanced tasks: +29.6
Expert tasks: +36.2

任務越複雜，結構就越重要。

你不會在沒有藍圖的情況下派 contractors 去蓋房子。對 AI agents 來說也是同樣的原則。
```

### Tweet 7 —— Harness 100

```
為了證明這件事可以泛化，我產生了 100 組 production-ready 的 harness configurations，涵蓋 10 個 domains：

• 內容創作
• Software Development
• Data & AI
• 商業策略
• 教育
• Marketing
• Legal、Health 等更多領域

總共 1,808 個檔案。全部 open source。

github.com/revfactory/harness-100
```

### Tweet 8 —— Demo: Getting Started

```
開始使用只要 30 秒：

/plugin marketplace add revfactory/harness
/plugin install harness@harness

然後試試看：

"Build a harness for deep research"
"Build a harness for full-stack website development"
"Build a harness for code review"

它會分析你的專案，並產生一個為你的 domain 量身打造的 agent team。

[GIF: 在 Claude Code 中執行 "build a harness" 的螢幕錄影]
```

### Tweet 9 —— CTA

```
Harness 採用 Apache 2.0 授權。

⭐ Plugin: github.com/revfactory/harness
📦 100 harnesses: github.com/revfactory/harness-100
📄 Research: github.com/revfactory/claude-code-harness

如果你正在使用 Claude Code，試試看吧。
如果你正在用 AI agents 建構東西，光是 architecture patterns 就很值得一讀。

歡迎幫忙點星——能讓更多人找到它。
```

---

## 4. Dev.to 文章

### 標題

```
How I Built a Meta-Skill That Designs AI Agent Teams — and Proved It Works with A/B Tests
```

### 標籤

`#ai #claude #agents #opensource`

### 內文

```markdown
## 那個幾乎沒人會談的問題

AI code agents 正變得非常強大。Claude Code、Cursor、Copilot——它們能寫函式、重構程式碼，甚至打造整個功能。但這裡有個麻煩的現實：**輸出品質非常不穩定**。

同一個模型，面對同一個任務，可能做出 40/100 的結果，也可能做出 80/100 的結果。那差異到底來自什麼？運氣？context window 狀態？月亮的相位？

我已經使用 Claude Code 的 experimental Agent Teams 功能好幾個月了——你可以把它想成同時生成多個彼此協作的 AI「workers」來處理複雜任務。而我一直撞上同一面牆：**建立這些 teams 比實際工作本身還困難**。

每次我想建立 multi-agent workflow，都得先：

1. 搞清楚我需要哪些 agents
2. 撰寫包含 roles 與 protocols 的 agent definition files
3. 為每個 agent 建立 skill files
4. 選擇一種 coordination pattern
5. 串接 data passing 與 error handling
6. 測試 triggers 是否有正確觸發

這一整套 2 小時的 yak shave，發生在任何真正有產出的工作開始之前。

所以我做了一個工具來把它自動化。

## Harness 會做什麼

**Harness** 是一個 Claude Code Plugin——更精確地說，它是一個「meta-skill」，會設計 domain-specific agent teams、定義 specialized agents，並產生它們要使用的 skills。

你只要說一句：

```
Build a harness for this project
```

它就會執行一條結構化的 6-phase pipeline。

### Phase 1: Domain Analysis

Harness 會讀取你的 codebase 與對話 context，理解：

- 你正在處理哪個 domain
- 涉及哪些類型的 tasks（generation、validation、editing、analysis）
- 目前已有哪些 agents/skills（避免衝突）
- 你的技術熟悉度（據此調整溝通方式）

### Phase 2: Team Architecture Design

這一段就開始有趣了。Harness 會從 **6 種 architecture patterns** 中選擇：

| Pattern | 適用時機 |
|---------|-------------|
| **Pipeline** | 有順序依賴的任務（code gen → review → test → deploy） |
| **Fan-out/Fan-in** | 可平行進行的獨立任務（multi-reviewer code audit） |
| **Expert Pool** | 根據 context 動態選擇 specialist |
| **Producer-Reviewer** | 先產生，再做 quality-check |
| **Supervisor** | 由中央 agent 動態分配任務 |
| **Hierarchical Delegation** | 自上而下的遞迴分解 |

它也會判斷該使用 Agent Teams（多個 agents 透過 `SendMessage` 直接溝通）還是 Subagents（一次性 tasks，沒有 inter-agent communication）。

### Phase 3: Agent Definition Generation

每個 agent 都會在 `.claude/agents/{name}.md` 擁有一份 definition file，內容包含：

- 核心角色與職責
- 運作原則
- Input/output protocols
- Error handling strategies
- Team communication contracts（誰要和誰溝通）

### Phase 4: Skill Generation

Skills 是「怎麼做」的部分——也就是每個 agent 的能力。它們會產生在 `.claude/skills/{name}/skill.md`，內容包含：

- YAML frontmatter（名稱、具侵略性的 trigger description）
- Markdown 本體（少於 500 行）
- Progressive Disclosure：metadata 永遠載入、本體在 trigger 時載入、references 依需求載入

這個 trigger description 會刻意寫得比較「積極」——Claude 對 skill 觸發通常偏保守，所以描述會更明確地規定 skill 何時該啟用。

### Phase 5: Integration & Orchestration

orchestrator skill 會把所有東西接起來：

- **Message-based** data passing（用 `SendMessage` 進行即時協作）
- **Task-based** tracking（用 `TaskCreate`/`TaskUpdate` 追蹤依賴）
- **File-based** artifacts（在 `_workspace/` 目錄輸出結構化成果）
- Error handling：重試一次，之後若仍失敗就繼續往下，但會記錄缺口

### Phase 6: Validation & Testing

多數 agent frameworks 到這裡之前就停止了——但真正的品質其實就在這一段：

- 結構檢查（檔案是否在正確位置、frontmatter 是否有效）
- Trigger verification（should-trigger 與 should-NOT-trigger queries）
- **有 skill vs 無 skill 的 A/B comparison**——會生成兩個 subagents，一個帶 skill、一個不帶，再比較輸出
- 完整 orchestration pipeline 的 dry-run testing
- Iterative refinement loop

## 研究：它真的有效嗎？

我不想只交出「感覺上不錯」的東西。所以我在 3 個難度層級的 15 個 software engineering tasks 上，做了一組**受控 A/B experiment**。

### 設定

- 15 個任務，涵蓋 basic、advanced 與 expert complexity
- 每個任務各跑兩次：一次使用 Harness pre-configuration，一次不使用
- 以標準化 rubric 進行品質評分

### 結果

| Metric | Without Harness | With Harness | Improvement |
|--------|:-:|:-:|:-:|
| Average Quality Score | 49.5 | 79.3 | **+60%** |
| Win Rate | — | — | **100% (15/15)** |
| Output Variance | — | — | **-32%** |

### Scaling Insight

最有意思的發現是：**效果會隨任務複雜度放大**。

- Basic tasks: +23.8 分提升
- Advanced tasks: +29.6
- Expert tasks: +36.2

這非常符合直覺。對簡單任務來說，agent 靠摸索也可能碰出不錯的答案。但對一個由許多相互依賴部分組成的複雜任務來說，如果沒有給它結構，就很難持續維持 coherence。

這就像建築工程需要藍圖、電影製作需要 shot lists。輸出越複雜，流程就越需要結構。

## 100 組現成的 harnesses

為了證明這不只適用於我自己的專案，我產生了 **100 組 production-ready 的 harness configurations**，橫跨 10 個 domains：

- 內容創作（部落格文章、社群貼文、影片腳本）
- Software Development（full-stack、mobile、DevOps）
- Data & AI（pipelines、ML ops、analytics）
- 商業策略（市場分析、競品情報）
- 教育（課程設計、評量）
- Marketing（campaigns、SEO、brand）
- Legal、Health、Finance 等更多領域

總計 **1,808 份 markdown files**——每一組 harness 都包含 4 到 5 個 specialist agents、一個 orchestrator skill，以及 domain-specific skills。全部提供英文與韓文版本（共 200 個 packages）。

Repository: [revfactory/harness-100](https://github.com/revfactory/harness-100)

## 快速開始

### 安裝

```shell
# Add the marketplace
/plugin marketplace add revfactory/harness

# Install the plugin
/plugin install harness@harness
```

### Requirements

- Claude Code with Agent Teams enabled:
  ```
  CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
  ```

### 使用方式

在 Claude Code 中，只要說出以下任一句：

```
Build a harness for this project
Design an agent team for deep research
Set up a harness for code review
Build a harness for full-stack website development
```

Harness 會分析你的 context，並產生一個依照你的 domain 量身打造的完整 agent team。

### 你會得到什麼

```
your-project/
├── .claude/
│   ├── agents/          # Agent definitions
│   │   ├── analyst.md
│   │   ├── builder.md
│   │   └── qa.md
│   └── skills/          # Skill files
│       ├── analyze/
│       │   └── skill.md
│       └── build/
│           ├── skill.md
│           └── references/
```

## 我在打造這個工具時學到的事

**1. Trigger descriptions 必須夠積極。** Claude 對 skill 啟動相當保守。寫成「PDF processing skill」幾乎永遠不會觸發。寫成「Use this skill for ANY task involving .pdf files including reading, extracting, merging, splitting...」才真的有效。

**2. Progressive Disclosure 對 context management 至關重要。** 一開始就把所有內容全部載入，只是在浪費 context window。3-tier system（metadata 永遠載入 → 本體在 trigger 時載入 → references 依需求載入）能把整體維持得更精簡。

**3. 「誰做什麼」與「怎麼做」應該拆成不同檔案。** Agent definitions（誰做什麼）與 skills（怎麼做）是不同層次的問題。把兩者耦合在一起會讓 reuse 幾乎不可能。拆開之後，你就能自由 mix and match。

**4. 真正有價值的地方是在 validation。** 產生 agent files 只是基本盤。真正讓輸出從 demo-quality 變成 production-quality 的，是 trigger testing、A/B comparisons 與 iterative refinement loop。

**5. 效果會隨複雜度放大。** 這是最讓我意外、也最重要的發現。簡單任務不太需要很多結構；複雜任務則很需要。Harness 最有價值的地方，正好就是你最需要它的地方。

## 連結

- **Harness plugin**: [github.com/revfactory/harness](https://github.com/revfactory/harness)
- **100 ready-made harnesses**: [github.com/revfactory/harness-100](https://github.com/revfactory/harness-100)
- **A/B test research**: [github.com/revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)
- **Paper**: Hwang, M. (2026). "Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality."

採用 Apache 2.0 授權。歡迎點星與提供回饋。
```

---

## 5. Content Calendar —— 協調式發布計畫

所有時間皆為 **UTC**。設計目標是在 48 小時內，達到最大的跨平台放大效果。

### Day 1（發布日）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| 08:00 | **Hacker News** | Show HN 貼文 | 在美國西岸清晨發文。HN 流量高峰約在 PT 9-11am。 |
| 08:30 | **Twitter/X** | 討論串（Tweets 1-9） | 立刻發完整討論串，並置頂 Tweet 1。 |
| 09:00 | **r/ClaudeAI** | Reddit 貼文 | 主要社群，最容易接受這類內容。 |
| 10:00 | **r/programming** | Reddit 貼文 | 更廣泛的開發者受眾。等待 1 小時以避免被判定為 spam。 |
| 12:00 | **Dev.to** | 完整文章 | 提供較長篇內容，兼顧搜尋與發現。 |

### Day 2（後續追蹤）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| 08:00 | **r/MachineLearning** | Reddit 貼文 | 偏研究取向的受眾，先強調 methodology。 |
| 10:00 | **Twitter/X** | Quote-tweet 原討論串並加上新角度 | 「研究結果讓我很意外……」——突出 scaling insight。 |
| 14:00 | **Hacker News** | 回覆留言 | 深度互動。技術性回答有助於提高排序。 |

### Day 3+（持續延伸）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| Ongoing | **Twitter/X** | 回覆引用與 mentions | 跟所有分享的人互動。 |
| Ongoing | **GitHub** | 回應 issues/stars | 快速回應 issues 能傳達專案有在積極維護。 |
| +3 days | **Twitter/X** | 「100 harnesses」獨立貼文 | 為 companion repo 單獨做一則內容。 |
| +5 days | **Dev.to** | 後續文章：「5 architecture patterns for AI agent teams」 | Evergreen content，可再導流回 repo。 |
| +7 days | **Twitter/X** | 里程碑更新 | 例如「一週內 500 stars」這類 social proof。 |

### 發布檢查清單

- [ ] GitHub README 已潤飾完成，包含 badges、banner 與清楚的安裝說明
- [ ] Landing page（index.html）已上線，並從 README 連過去
- [ ] harness-100 repo 已公開，且有清楚的 README
- [ ] claude-code-harness（研究 repo）已公開
- [ ] 所有 GitHub repos 都已設定適當的 topics/tags 以提升 discoverability
- [ ] Twitter 個人簡介已更新，提到 Harness
- [ ] 已準備 2-3 個 demo GIFs/screenshots 用於 Twitter 討論串
- [ ] 已先擬好對可能的 HN 問題的回應（methodology、limitations、與其他工具的比較）

---

## 各平台最佳化備註

### Hacker News
- 標題必須以 `Show HN:` 開頭——這是 Show HN 貼文的要求
- 只支援純文字，不會渲染 markdown
- 開頭先講問題，不要先講解法
- 盡早放入具體數字
- 以「Happy to answer questions」作結——傳達願意互動

### Reddit
- 每個 subreddit 都要有不同切角：r/ClaudeAI（實務／教學）、r/MachineLearning（研究／方法論）、r/programming（工程／展示）
- 不要 cross-post——每篇都要是原生貼文
- 別太常說「my project」——重點放在讀者的問題

### Twitter/X
- Hook tweet 是一切——必須能讓人停下來
- 即使只看 tweet 1 和 tweet 9，整個討論串也要能成立
- 先標記 image/GIF 欄位——視覺內容能帶來 3 倍互動
- 用清楚的 CTA 與連結收尾

### Dev.to
- 長文適合做 SEO——會有機會排到「AI agent teams」、「Claude Code plugin」、「multi-agent orchestration」等關鍵字
- 要包含 code blocks——Dev.to 讀者期待有技術深度
- 「What I learned」段落能帶動互動與分享
- Tags 會決定分發效果——要使用高流量 tags
