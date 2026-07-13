# Harness 发布内容 —— 多平台版本

---

## 1. Hacker News（Show HN）

### 标题

```
Show HN: Harness – A Claude Code plugin that designs AI agent teams from a single prompt
```

### 内文

```
我已经使用 Claude Code 的 agent teams 好几个月了，但同一个问题一直反复出现：每次我要建立 multi-agent workflow，都像是在重新发明轮子。定义 agent 角色、撰写 skill 档案、判断该用哪种 coordination pattern、把 agents 之间的资料传递接起来——在真正开始工作之前，这些前置作业就要先折腾 2 个小时。

所以我做了 Harness。它是一个 Claude Code plugin——一个「meta-skill」——可以把整个流程自动化。你只要说「build a harness for this project」，它就会执行一条 6-phase pipeline：

  1. 分析你的 domain 与 codebase
  2. 从 6 种 architecture patterns 中选择（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
  3. 产生 agent definition files（.claude/agents/）
  4. 产生具备 Progressive Disclosure 的 skills（.claude/skills/）
  5. 串接 orchestration，包含 data-passing protocols 与 error handling
  6. 透过 trigger testing 与有／无 skill 的 A/B comparisons 进行验证

我在 3 个难度层级的 15 个 software engineering tasks 上跑了一组受控实验。结果如下：

  - 平均品质分数提升 +60%（49.5 → 79.3）
  - 胜率 100%——加上 harness 的版本在 15 次比较中全部胜出
  - 输出变异降低 32%
  - 效果会随任务复杂度放大：基础任务 +23.8、进阶任务 +29.6、专家任务 +36.2

这个洞见其实很直接：LLM code agents 很有能力，但缺乏方向。只要先给它们结构化的 pre-configuration——谁负责什么、要如何协作、什么才算「完成」——输出品质就会明显跃升。

我另外也产生了 100 个 production-ready 的 harness configurations，涵盖 10 个 domains（内容创作、software dev、data/AI、商业策略、教育等等），并把它们作为 companion repo 开源。总计 1,808 个档案。

这个 plugin 可搭配 Claude Code 的 experimental Agent Teams system 使用。你可以透过 plugin marketplace 安装，或直接复制 skill files。

GitHub: https://github.com/revfactory/harness
100 ready-made harnesses: https://github.com/revfactory/harness-100
A/B test results & paper: https://github.com/revfactory/claude-code-harness

如果你想聊 architecture patterns、研究方法，或 meta-skill generation loop 是怎么运作的，我很乐意回答。
```

---

## 2. Reddit

### 2a. r/ClaudeAI

**标题：** `I built a Claude Code plugin that designs agent teams for you — 60% quality improvement in A/B tests`

**内文：**

```
我在使用 Claude Code 的 agent teams 时，一直碰到同样的摩擦点：建立 agents、撰写 skills、选择 coordination patterns，以及把 orchestration 串起来，花的时间常常比真正的任务还久。

所以我做了 **Harness**——一个 meta-skill（Claude Code Plugin），可以从单一 prompt 完成这一切。

**它的运作方式：**

你只要说「build a harness for this project」，它就会执行一条 6-phase pipeline：
- 分析你的 codebase 与 domain
- 选择一种 architecture pattern（共 6 种：Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
- 产生 `.claude/agents/` 与 `.claude/skills/` 档案
- 建立包含 inter-agent communication 的 orchestration
- 透过 trigger tests 与 A/B comparisons 验证

**最让我意外的是研究结果：**

我在 15 个 software engineering tasks 上进行了受控的 A/B tests：
- **品质提升 +60%**（平均分数从 49.5 → 79.3）
- **胜率 100%**——加上 harness 的版本每一次比较都赢
- **任务越难，提升越大**——专家等级任务最高提升了 +36.2 分

这其实很符合直觉：你不会在没有蓝图的情况下，就把一群 contractors 丢去盖房子。同样的逻辑也适用于 AI agents。

**延伸资源：**

我另外产生了 [100 个现成的 harnesses](https://github.com/revfactory/harness-100)，涵盖 10 个 domains（共 1,808 个档案）。内容创作、software dev、data/AI、marketing、education、legal、health——每一套都包含 4 到 5 个 specialist agents 与 orchestrator skills。

**快速开始：**

```
/plugin marketplace add revfactory/harness
/plugin install harness@harness
```

接著只要说：「Build a harness for [your domain]」

GitHub: https://github.com/revfactory/harness

需要先启用 Agent Teams：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

如果你也有在用 Claude Code 的 agent teams，很想听听你的回馈。你正在为哪些 domains 建构这类流程？
```

### 2b. r/MachineLearning

**标题：** `[P] Harness: Structured Pre-Configuration for LLM Code Agents — +60% Quality, 100% Win Rate in A/B Tests`

**内文：**

```
**TL;DR:** Structured pre-configuration（在执行前先定义 agent roles、coordination patterns 与 skill specifications）可让 LLM code agents 的输出品质提升 +60%，并在 15 个任务中取得 100% 胜率。

---

**问题：** 以 LLM 为基础的 code agents（Claude Code、Cursor 等）能力正越来越强，但输出品质不稳定。相同模型面对相同任务，可能会因工作结构不同而产生 40/100 或 80/100 的结果。目前没有系统化的方法能降低这种变异。

**方法：** 我打造了 **Harness**，一个用于 Claude Code 的「meta-skill」，用来自动化 structured pre-configuration。给定一个 domain/project，它会：

1. 分析 task space
2. 从 6 种 multi-agent architecture patterns 中选择（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
3. 产生具备 role boundaries 与 communication protocols 的 agent definitions
4. 建立采用 Progressive Disclosure（3-tier context loading）的 skills
5. 串接 orchestration 与 error handling
6. 透过 trigger testing 与有／无 skill 的比较进行验证

**实验结果**（在 15 个 SE tasks、3 个难度层级上进行受控 A/B）：

| Metric | Without | With | Delta |
|--------|---------|------|-------|
| Avg Quality Score | 49.5 | 79.3 | **+60%** |
| Win Rate | — | — | **15/15 (100%)** |
| Output Variance | — | — | **-32%** |

关键发现：**效果会随任务复杂度放大**。
- Basic tasks: +23.8
- Advanced: +29.6
- Expert: +36.2

这与假设相符：当 search space 很大，而且 agent 需要在多个 subtasks 之间维持 coherence 时，structured decomposition 的重要性会大幅提升。

**Artifacts：**
- Plugin（meta-skill）: https://github.com/revfactory/harness
- 跨 10 个 domains 产生的 100 组 harness configs: https://github.com/revfactory/harness-100
- 实验方法与结果: https://github.com/revfactory/claude-code-harness

Paper reference: Hwang, M. (2026). "Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality."

如果你想讨论实验设计、pattern selection heuristics，或 progressive disclosure mechanism，我很乐意交流。
```

### 2c. r/programming

**标题：** `Show r/programming: A plugin that auto-generates multi-agent AI teams from your codebase — with A/B tested results`

**内文：**

```
我最近一直在使用 Claude Code 的 agent teams——可以把它想像成同时生成多个会彼此协作的 AI「workers」来处理复杂任务。问题在于：建立这些 teams 很麻烦。你得定义角色、写 skill files、挑 coordination pattern、接资料传递、处理错误。每。次。都。要。

**Harness** 是一个能把这一切自动化的 Claude Code plugin。一个 prompt → 完整 agent team。

**它实际会产生什么：**

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

**它会从这 6 种 architecture patterns 中选择：**

- **Pipeline** —— A → B → C（code gen → review → test → deploy）
- **Fan-out/Fan-in** —— 平行 agents，最后合并结果（multi-reviewer code audit）
- **Expert Pool** —— 动态挑选正确的 specialist
- **Producer-Reviewer** —— 一个负责建构，一个负责 QA
- **Supervisor** —— 由中央 coordinator 派发任务
- **Hierarchical Delegation** —— 递回式的 top-down decomposition

**它真的有效吗？**

我跑了一个受控实验。15 个 tasks。3 个难度层级。比较有 harness 与没有 harness。

- 品质分数提升 +60%
- 胜率 100%（15/15）
- 输出变异降低 32%
- 专家等级任务获益最大（+36.2 分）

另外那个 companion repo 也提供了 100 套预先建好的 harnesses，横跨 10 个 domains：https://github.com/revfactory/harness-100

**安装方式：**

```
/plugin marketplace add revfactory/harness
/plugin install harness@harness
```

接著输入：「Build a harness for this project」

Source: https://github.com/revfactory/harness

需要使用已启用 Agent Teams 的 Claude Code。
```

---

## 3. Twitter/X 讨论串

### Tweet 1 —— Hook

```
我做了一个能设计 AI agent teams 的工具。

不是单一 agent——而是完整、彼此协作的 teams，包含 roles、skills、communication protocols 与 orchestration。

一个 prompt。完整团队。A/B tests 显示品质提升 60%。

它叫做 Harness，而且是 open source。

🧵👇
```

### Tweet 2 —— 问题

```
AI code agents 的问题在于：

它们很有能力，但缺乏方向。

相同模型、相同任务 → 品质却可能差很多。有时 40/100，有时 80/100。

缺少的不是智慧，而是结构。

[IMAGE: 并排比较图，展示零散 vs. 有组织的 agent output]
```

### Tweet 3 —— 解法

```
Harness 是一个 Claude Code Plugin——一个能设计 multi-agent teams 的「meta-skill」。

只要说「build a harness for this project」，它就会跑完一条 6-phase pipeline：

1. Domain Analysis
2. Architecture Design (6 patterns)
3. Agent Definition Generation
4. Skill Generation
5. Orchestration
6. Validation & Testing

[IMAGE: 显示 6 个 phases 的 workflow diagram]
```

### Tweet 4 —— Architecture Patterns

```
6 种经过验证的 coordination patterns：

→ Pipeline: sequential（gen → review → test）
⟐ Fan-out/Fan-in: parallel 后再 merge
♠ Expert Pool: 挑选合适的 specialist
⇄ Producer-Reviewer: build 后再 QA
◆ Supervisor: 中央 dispatch
△ Hierarchical: 递回 delegation

它会替你的 domain 选出最适合的一种。

[IMAGE: 6 张 architecture pattern cards 的视觉图]
```

### Tweet 5 —— 研究

```
我不只把它做出来——我还实际量测了它的效果。

15 个 software engineering tasks。3 个难度层级。受控 A/B tests。

结果：
• 平均品质分数提升 +60%
• 胜率 100%（15/15 tasks）
• 输出变异 -32%
• 任务越难 = 提升越大

这种效果会随复杂度放大。

[IMAGE: landing page 上的长条图，展示 Basic/Advanced/Expert 结果]
```

### Tweet 6 —— Scaling Insight

```
这就是关键洞见：

Basic tasks: +23.8 improvement
Advanced tasks: +29.6
Expert tasks: +36.2

任务越复杂，结构就越重要。

你不会在没有蓝图的情况下派 contractors 去盖房子。对 AI agents 来说也是同样的原则。
```

### Tweet 7 —— Harness 100

```
为了证明这件事可以泛化，我产生了 100 组 production-ready 的 harness configurations，涵盖 10 个 domains：

• 内容创作
• Software Development
• Data & AI
• 商业策略
• 教育
• Marketing
• Legal、Health 等更多领域

总共 1,808 个档案。全部 open source。

github.com/revfactory/harness-100
```

### Tweet 8 —— Demo: Getting Started

```
开始使用只要 30 秒：

/plugin marketplace add revfactory/harness
/plugin install harness@harness

然后试试看：

"Build a harness for deep research"
"Build a harness for full-stack website development"
"Build a harness for code review"

它会分析你的专案，并产生一个为你的 domain 量身打造的 agent team。

[GIF: 在 Claude Code 中执行 "build a harness" 的萤幕录影]
```

### Tweet 9 —— CTA

```
Harness 采用 Apache 2.0 授权。

⭐ Plugin: github.com/revfactory/harness
📦 100 harnesses: github.com/revfactory/harness-100
📄 Research: github.com/revfactory/claude-code-harness

如果你正在使用 Claude Code，试试看吧。
如果你正在用 AI agents 建构东西，光是 architecture patterns 就很值得一读。

欢迎帮忙点星——能让更多人找到它。
```

---

## 4. Dev.to 文章

### 标题

```
How I Built a Meta-Skill That Designs AI Agent Teams — and Proved It Works with A/B Tests
```

### 标签

`#ai #claude #agents #opensource`

### 内文

```markdown
## 那个几乎没人会谈的问题

AI code agents 正变得非常强大。Claude Code、Cursor、Copilot——它们能写函式、重构程式码，甚至打造整个功能。但这里有个麻烦的现实：**输出品质非常不稳定**。

同一个模型，面对同一个任务，可能做出 40/100 的结果，也可能做出 80/100 的结果。那差异到底来自什么？运气？context window 状态？月亮的相位？

我已经使用 Claude Code 的 experimental Agent Teams 功能好几个月了——你可以把它想成同时生成多个彼此协作的 AI「workers」来处理复杂任务。而我一直撞上同一面墙：**建立这些 teams 比实际工作本身还困难**。

每次我想建立 multi-agent workflow，都得先：

1. 搞清楚我需要哪些 agents
2. 撰写包含 roles 与 protocols 的 agent definition files
3. 为每个 agent 建立 skill files
4. 选择一种 coordination pattern
5. 串接 data passing 与 error handling
6. 测试 triggers 是否有正确触发

这一整套 2 小时的 yak shave，发生在任何真正有产出的工作开始之前。

所以我做了一个工具来把它自动化。

## Harness 会做什么

**Harness** 是一个 Claude Code Plugin——更精确地说，它是一个「meta-skill」，会设计 domain-specific agent teams、定义 specialized agents，并产生它们要使用的 skills。

你只要说一句：

```
Build a harness for this project
```

它就会执行一条结构化的 6-phase pipeline。

### Phase 1: Domain Analysis

Harness 会读取你的 codebase 与对话 context，理解：

- 你正在处理哪个 domain
- 涉及哪些类型的 tasks（generation、validation、editing、analysis）
- 目前已有哪些 agents/skills（避免冲突）
- 你的技术熟悉度（据此调整沟通方式）

### Phase 2: Team Architecture Design

这一段就开始有趣了。Harness 会从 **6 种 architecture patterns** 中选择：

| Pattern | 适用时机 |
|---------|-------------|
| **Pipeline** | 有顺序依赖的任务（code gen → review → test → deploy） |
| **Fan-out/Fan-in** | 可平行进行的独立任务（multi-reviewer code audit） |
| **Expert Pool** | 根据 context 动态选择 specialist |
| **Producer-Reviewer** | 先产生，再做 quality-check |
| **Supervisor** | 由中央 agent 动态分配任务 |
| **Hierarchical Delegation** | 自上而下的递回分解 |

它也会判断该使用 Agent Teams（多个 agents 透过 `SendMessage` 直接沟通）还是 Subagents（一次性 tasks，没有 inter-agent communication）。

### Phase 3: Agent Definition Generation

每个 agent 都会在 `.claude/agents/{name}.md` 拥有一份 definition file，内容包含：

- 核心角色与职责
- 运作原则
- Input/output protocols
- Error handling strategies
- Team communication contracts（谁要和谁沟通）

### Phase 4: Skill Generation

Skills 是「怎么做」的部分——也就是每个 agent 的能力。它们会产生在 `.claude/skills/{name}/skill.md`，内容包含：

- YAML frontmatter（名称、具侵略性的 trigger description）
- Markdown 本体（少于 500 行）
- Progressive Disclosure：metadata 永远载入、本体在 trigger 时载入、references 依需求载入

这个 trigger description 会刻意写得比较「积极」——Claude 对 skill 触发通常偏保守，所以描述会更明确地规定 skill 何时该启用。

### Phase 5: Integration & Orchestration

orchestrator skill 会把所有东西接起来：

- **Message-based** data passing（用 `SendMessage` 进行即时协作）
- **Task-based** tracking（用 `TaskCreate`/`TaskUpdate` 追踪依赖）
- **File-based** artifacts（在 `_workspace/` 目录输出结构化成果）
- Error handling：重试一次，之后若仍失败就继续往下，但会记录缺口

### Phase 6: Validation & Testing

多数 agent frameworks 到这里之前就停止了——但真正的品质其实就在这一段：

- 结构检查（档案是否在正确位置、frontmatter 是否有效）
- Trigger verification（should-trigger 与 should-NOT-trigger queries）
- **有 skill vs 无 skill 的 A/B comparison**——会生成两个 subagents，一个带 skill、一个不带，再比较输出
- 完整 orchestration pipeline 的 dry-run testing
- Iterative refinement loop

## 研究：它真的有效吗？

我不想只交出「感觉上不错」的东西。所以我在 3 个难度层级的 15 个 software engineering tasks 上，做了一组**受控 A/B experiment**。

### 设定

- 15 个任务，涵盖 basic、advanced 与 expert complexity
- 每个任务各跑两次：一次使用 Harness pre-configuration，一次不使用
- 以标准化 rubric 进行品质评分

### 结果

| Metric | Without Harness | With Harness | Improvement |
|--------|:-:|:-:|:-:|
| Average Quality Score | 49.5 | 79.3 | **+60%** |
| Win Rate | — | — | **100% (15/15)** |
| Output Variance | — | — | **-32%** |

### Scaling Insight

最有意思的发现是：**效果会随任务复杂度放大**。

- Basic tasks: +23.8 分提升
- Advanced tasks: +29.6
- Expert tasks: +36.2

这非常符合直觉。对简单任务来说，agent 靠摸索也可能碰出不错的答案。但对一个由许多相互依赖部分组成的复杂任务来说，如果没有给它结构，就很难持续维持 coherence。

这就像建筑工程需要蓝图、电影制作需要 shot lists。输出越复杂，流程就越需要结构。

## 100 组现成的 harnesses

为了证明这不只适用于我自己的专案，我产生了 **100 组 production-ready 的 harness configurations**，横跨 10 个 domains：

- 内容创作（部落格文章、社群贴文、影片脚本）
- Software Development（full-stack、mobile、DevOps）
- Data & AI（pipelines、ML ops、analytics）
- 商业策略（市场分析、竞品情报）
- 教育（课程设计、评量）
- Marketing（campaigns、SEO、brand）
- Legal、Health、Finance 等更多领域

总计 **1,808 份 markdown files**——每一组 harness 都包含 4 到 5 个 specialist agents、一个 orchestrator skill，以及 domain-specific skills。全部提供英文与韩文版本（共 200 个 packages）。

Repository: [revfactory/harness-100](https://github.com/revfactory/harness-100)

## 快速开始

### 安装

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

在 Claude Code 中，只要说出以下任一句：

```
Build a harness for this project
Design an agent team for deep research
Set up a harness for code review
Build a harness for full-stack website development
```

Harness 会分析你的 context，并产生一个依照你的 domain 量身打造的完整 agent team。

### 你会得到什么

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

## 我在打造这个工具时学到的事

**1. Trigger descriptions 必须够积极。** Claude 对 skill 启动相当保守。写成「PDF processing skill」几乎永远不会触发。写成「Use this skill for ANY task involving .pdf files including reading, extracting, merging, splitting...」才真的有效。

**2. Progressive Disclosure 对 context management 至关重要。** 一开始就把所有内容全部载入，只是在浪费 context window。3-tier system（metadata 永远载入 → 本体在 trigger 时载入 → references 依需求载入）能把整体维持得更精简。

**3. 「谁做什么」与「怎么做」应该拆成不同档案。** Agent definitions（谁做什么）与 skills（怎么做）是不同层次的问题。把两者耦合在一起会让 reuse 几乎不可能。拆开之后，你就能自由 mix and match。

**4. 真正有价值的地方是在 validation。** 产生 agent files 只是基本盘。真正让输出从 demo-quality 变成 production-quality 的，是 trigger testing、A/B comparisons 与 iterative refinement loop。

**5. 效果会随复杂度放大。** 这是最让我意外、也最重要的发现。简单任务不太需要很多结构；复杂任务则很需要。Harness 最有价值的地方，正好就是你最需要它的地方。

## 连结

- **Harness plugin**: [github.com/revfactory/harness](https://github.com/revfactory/harness)
- **100 ready-made harnesses**: [github.com/revfactory/harness-100](https://github.com/revfactory/harness-100)
- **A/B test research**: [github.com/revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)
- **Paper**: Hwang, M. (2026). "Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality."

采用 Apache 2.0 授权。欢迎点星与提供回馈。
```

---

## 5. Content Calendar —— 协调式发布计划

所有时间皆为 **UTC**。设计目标是在 48 小时内，达到最大的跨平台放大效果。

### Day 1（发布日）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| 08:00 | **Hacker News** | Show HN 贴文 | 在美国西岸清晨发文。HN 流量高峰约在 PT 9-11am。 |
| 08:30 | **Twitter/X** | 讨论串（Tweets 1-9） | 立刻发完整讨论串，并置顶 Tweet 1。 |
| 09:00 | **r/ClaudeAI** | Reddit 贴文 | 主要社群，最容易接受这类内容。 |
| 10:00 | **r/programming** | Reddit 贴文 | 更广泛的开发者受众。等待 1 小时以避免被判定为 spam。 |
| 12:00 | **Dev.to** | 完整文章 | 提供较长篇内容，兼顾搜寻与发现。 |

### Day 2（后续追踪）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| 08:00 | **r/MachineLearning** | Reddit 贴文 | 偏研究取向的受众，先强调 methodology。 |
| 10:00 | **Twitter/X** | Quote-tweet 原讨论串并加上新角度 | 「研究结果让我很意外……」——突出 scaling insight。 |
| 14:00 | **Hacker News** | 回复留言 | 深度互动。技术性回答有助于提高排序。 |

### Day 3+（持续延伸）

| Time (UTC) | Platform | Content | Notes |
|------------|----------|---------|-------|
| Ongoing | **Twitter/X** | 回复引用与 mentions | 跟所有分享的人互动。 |
| Ongoing | **GitHub** | 回应 issues/stars | 快速回应 issues 能传达专案有在积极维护。 |
| +3 days | **Twitter/X** | 「100 harnesses」独立贴文 | 为 companion repo 单独做一则内容。 |
| +5 days | **Dev.to** | 后续文章：「5 architecture patterns for AI agent teams」 | Evergreen content，可再导流回 repo。 |
| +7 days | **Twitter/X** | 里程碑更新 | 例如「一周内 500 stars」这类 social proof。 |

### 发布检查清单

- [ ] GitHub README 已润饰完成，包含 badges、banner 与清楚的安装说明
- [ ] Landing page（index.html）已上线，并从 README 连过去
- [ ] harness-100 repo 已公开，且有清楚的 README
- [ ] claude-code-harness（研究 repo）已公开
- [ ] 所有 GitHub repos 都已设定适当的 topics/tags 以提升 discoverability
- [ ] Twitter 个人简介已更新，提到 Harness
- [ ] 已准备 2-3 个 demo GIFs/screenshots 用于 Twitter 讨论串
- [ ] 已先拟好对可能的 HN 问题的回应（methodology、limitations、与其他工具的比较）

---

## 各平台最佳化备注

### Hacker News
- 标题必须以 `Show HN:` 开头——这是 Show HN 贴文的要求
- 只支援纯文字，不会渲染 markdown
- 开头先讲问题，不要先讲解法
- 尽早放入具体数字
- 以「Happy to answer questions」作结——传达愿意互动

### Reddit
- 每个 subreddit 都要有不同切角：r/ClaudeAI（实务／教学）、r/MachineLearning（研究／方法论）、r/programming（工程／展示）
- 不要 cross-post——每篇都要是原生贴文
- 别太常说「my project」——重点放在读者的问题

### Twitter/X
- Hook tweet 是一切——必须能让人停下来
- 即使只看 tweet 1 和 tweet 9，整个讨论串也要能成立
- 先标记 image/GIF 栏位——视觉内容能带来 3 倍互动
- 用清楚的 CTA 与连结收尾

### Dev.to
- 长文适合做 SEO——会有机会排到「AI agent teams」、「Claude Code plugin」、「multi-agent orchestration」等关键字
- 要包含 code blocks——Dev.to 读者期待有技术深度
- 「What I learned」段落能带动互动与分享
- Tags 会决定分发效果——要使用高流量 tags
