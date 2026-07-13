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

# Harness — Claude Code 的团队架构工厂

**繁体中文** | [English](README_EN.md) | [한국어](README_KO.md) | [日本语](README_JA.md)

> **Harness 是 Claude Code 的团队架构工厂。** 只要输入 **"build a harness for this project"**、`「帮我为这个专案配置 Harness」`、`「하네스 구성해줘」` 或 `「ハーネスを构成して」`，外挂就会将你的领域描述转换成代理人团队与其使用的技能，并从六种预先定义的团队架构模式中挑选最合适的配置。

## 概要

Harness 运用 Claude Code 的 agent team 系统，将复杂任务拆解成由多个专职代理人协作完成的工作流程。输入「build a harness for this project」后，它会根据你的领域自动产生代理人定义（`.claude/agents/`）与技能（`.claude/skills/`）。

## 类别定位 — Harness 位在哪一层

Harness 位于 agent coding runtime 生态系中的 **L3 Meta-Factory** 层，也就是「用来生成其他 harness，而不是自己作为 harness」的那一层。在 L3 里，它定位在一个更具体的子层：**Team-Architecture Factory**。

| 层级 | 功能 | 相邻专案 |
|------|------|----------|
| **L3 — Meta-Factory / Team-Architecture Factory**（本专案） | 将领域描述转成代理人团队与技能，并套用 6 种预定义团队模式 | — |
| L3 — Meta-Factory / Runtime-Configuration Factory | 产生可重现、可预测的执行环境设定 | [coleam00/Archon](https://github.com/coleam00/Archon) |
| L3 — Meta-Factory / Codex Runtime Port | 相同概念的 Codex runtime 移植版 | [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) |
| L2 — Cross-Harness Workflow | 在多个 harness 之间标准化 skills、rules、hooks | [affaan-m/ECC](https://github.com/affaan-m/everything-claude-code) |

> Archon 负责产生可重现的 runtime 设定；Harness 则负责产生团队架构，例如 Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation，以及各代理人会用到的技能。两者同属 L3，但处于不同子层。若你需要执行环境的一致性，选 Archon；若你需要代理人团队设计，选 Harness；也可以两者搭配使用。

## 星标历史

<a href="https://www.star-history.com/?repos=revfactory%2Fharness&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=revfactory/harness&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=revfactory/harness&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=revfactory/harness&type=date&legend=top-left" />
 </picture>
</a>

## 主要特色

- **Agent Team Design**：提供 6 种架构模式，包含 Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation
- **Skill Generation**：自动产生符合领域需求的技能，并采用 Progressive Disclosure 管理上下文
- **Orchestration**：支援代理人之间的资料传递、错误处理与协调流程
- **Validation**：提供触发验证、dry-run 测试，以及有技能与无技能的比较测试

## Harness 演化机制

Harness 的演化机制会把真实使用后的差异回馈到工厂中，例如哪些设计有效、哪些设计需要修正，让下一次产生相似领域的 harness 时更接近实战版本。当一个生成的 harness 在真实专案中被使用后，`/harness:evolve` 技能会撷取初始架构与最终交付版本之间的差异，再把这些差异送回工厂。

```
Initial harness ──▶ Real project use ──▶ Shipped harness
                                              │
                                              ▼ (delta capture via /harness:evolve)
                                        ┌───────────────┐
                                        │  Factory      │◀── better next-gen draft
                                        └───────────────┘
```

这套机制被称为 **Harness Evolution Mechanism**。

## 工作流程

``` 
Phase 1: 领域分析
    ↓
Phase 2: 团队架构设计（Agent Teams 与 Subagents）
    ↓
Phase 3: 产生代理人定义（`.claude/agents/`）
    ↓
Phase 4: 产生技能（`.claude/skills/`）
    ↓
Phase 5: 整合与协调
    ↓
Phase 6: 验证与测试
```

## 安装方式

### Claude Code Marketplace 安装

#### 加入 Marketplace
```shell
/plugin marketplace add revfactory/harness
```

#### 安装外挂
```shell
/plugin install harness@harness
```

### 直接安装为全域 Skill

```shell
# 将 skills 目录复制到 ~/.claude/skills/harness/
cp -r skills/harness ~/.claude/skills/harness
```

## 外挂结构

```
harness/
├── .claude-plugin/
│   └── plugin.json                 # Claude Code plugin manifest
├── skills/
│   └── harness/
│       ├── SKILL.md                # Claude Code 版 Harness skill
│       └── references/
│           ├── agent-design-patterns.md   # 6 种架构模式
│           ├── orchestrator-template.md   # Team/Subagent 协调器范本
│           ├── team-examples.md           # 5 组真实世界团队配置
│           ├── skill-writing-guide.md     # Skill 撰写指南
│           ├── skill-testing-guide.md     # 测试与评估方法
│           └── qa-agent-guide.md          # QA agent 整合指南
└── README.md
```

## 使用方式

在 Claude Code 中，可以用下面这类 prompt 触发：

```
为这个专案建立一个 harness
为这个领域设计一个代理人团队
设定一个 harness
```

### 执行模式

| 模式 | 说明 | 适用情境 |
|------|------|----------|
| **Agent Teams**（预设） | TeamCreate + SendMessage + TaskCreate | 2 个以上代理人需要协作时 |
| **Subagents** | 直接呼叫 Agent 工具 | 单次任务、不需要代理人彼此沟通时 |

<p align="center">
  <img src="harness_team.png" alt="Harness Agent Team" width="500">
</p>

### 架构模式

| 模式 | 说明 |
|------|------|
| Pipeline | 依序执行、彼此相依的任务 |
| Fan-out/Fan-in | 可平行处理、再汇总结果的任务 |
| Expert Pool | 依上下文选择性呼叫专家代理人 |
| Producer-Reviewer | 先生成，再经过品质审查 |
| Supervisor | 由中央代理人动态分派任务 |
| Hierarchical Delegation | 自上而下的层级式委派 |

## 输出内容

Harness 会生成的档案如下：

```
your-project/
├── .claude/
│   ├── agents/          # 代理人定义档
│   │   ├── analyst.md
│   │   ├── builder.md
│   │   └── qa.md
│   └── skills/          # Skill 档案
│       ├── analyze/
│       │   └── SKILL.md
│       └── build/
│           ├── SKILL.md
│           └── references/
```

## 使用情境 — 试试这些 Prompt

安装完成后，你可以把以下 prompt 直接贴进 Claude Code：

**深度研究**
```
为深度研究建立一个 harness。我需要一个代理人团队，能从多个角度
研究任何主题，例如网路搜寻、学术来源与社群观点，然后交叉验证结论，
最后产出完整报告。
```

**网站开发**
```
为全端网站开发建立一个 harness。团队需要能在同一条协作流程中处理
设计、前端（React/Next.js）、后端（API）与 QA 测试，从线框稿一路
推进到部署。
```

**Webtoon / 漫画制作**
```
为 Webtoon 单集制作建立一个 harness。我需要负责剧情撰写、角色设计
prompt、分镜版面规划与对白编修的代理人，并且让他们彼此审查作品，
以维持风格一致性。
```

**YouTube 内容规划**
```
为 YouTube 内容创作建立一个 harness。团队需要研究热门主题、撰写脚本、
优化标题与标签以利 SEO，并规划缩图概念，全部由一位 supervisor agent
统筹协调。
```

**程式码审查与重构**
```
为全面程式码审查建立一个 harness。我希望有多个平行代理人分别检查
架构、安全漏洞、效能瓶颈与程式风格，最后再把所有发现整合成一份报告。
```

**技术文件撰写**
```
建立一个能从这份程式码库产生 API 文件的 harness。代理人需要分析端点、
撰写说明、生成使用范例，并检查内容是否完整。
```

**资料管线设计**
```
为资料管线设计建立一个 harness。我需要能处理 schema 设计、ETL 逻辑、
资料验证规则与监控设定的代理人，并且支援阶层式委派子任务。
```

**行销活动规划**
```
为行销活动建立一个 harness。团队需要研究目标市场、撰写广告文案、
设计视觉概念，并安排 A/B 测试计划与反复品质审查。
```

## 生态共存 — Harness 与相邻专案

Harness 并不是 Claude Code / agent framework 生态系中唯一的选项。以下专案位于相邻层级，各自拥有不同定位，可依需求单独选用或搭配使用。

| Repo | 他们的定位 | 与 Harness 的关系 |
|------|------------|-------------------|
| [coleam00/Archon](https://github.com/coleam00/Archon) | 「harness builder」, 著重可重现的 runtime 设定 | **同属 L3、不同子层。** Archon 是 Runtime-Configuration Factory，Harness 是 Team-Architecture Factory。 |
| [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) | 相同概念的 Codex 移植版 | **同属 L3、不同发行路线。** 本 fork 内建 Codex plugin；meta-harness 可作为另一个 Codex 参考实作。 |
| [affaan-m/ECC](https://github.com/affaan-m/everything-claude-code) | 建立在既有 harness 上方的工作流标准化层 | **不同层级。** ECC 负责标准化，Harness 负责生成 harness。 |
| [wshobson/agents](https://github.com/wshobson/agents) | Subagent / skill catalog | **像零件供应与工厂的关系。** Harness 负责设计团队，wshobson/agents 可作为可吸收的零件库。 |
| [LangGraph](https://langchain-ai.github.io/langgraph/) | 状态图导向、LLM 无关的编排框架 | **不同路线。** LangGraph 侧重长时间执行与状态恢复，Harness 侧重 Claude Code 原生的快速团队设计。 |

## 使用 Harness 建立的成果

### Harness 100

**[revfactory/harness-100](https://github.com/revfactory/harness-100)** — 横跨 10 个领域的 100 套可投入生产的 agent team harness，提供英文与韩文版本（共 200 套）。每一套 harness 都包含 4 到 5 个专职代理人、一个 orchestrator skill，以及领域专用技能，全部由本外挂生成。整体涵盖 1,808 份 Markdown 档，主题横跨内容创作、软体开发、资料/AI、商业策略、教育、法律、健康等。

### 研究：Harness 效果 A/B 测试

**[revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)** — 一项针对 15 个软体工程任务的对照实验，用来测量有无结构化预先配置时，LLM 程式代理人的输出品质差异。

| 指标 | 未使用 Harness | 使用 Harness | 改善幅度 |
|------|:-:|:-:|:-:|
| 平均品质分数 | 49.5 | 79.3 | **+60%** |
| 胜率 | — | — | **100%**（15/15） |
| 输出变异 | — | — | **-32%** |

关键结论：任务越复杂，效果提升越明显。Basic 任务提升 +23.8、Advanced 任务提升 +29.6、Expert 任务提升 +36.2。

**建议统一引用说法：** +60% 平均品质（49.5 → 79.3）、15/15 胜率、−32% 变异（n=15，作者自测 A/B，第三方重现仍待验证）。

> 完整论文：*Hwang, M. (2026). Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality.*

## 使用需求

- [启用 Agent Teams](https://code.claude.com/docs/en/agent-teams): `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## FAQ

<details>
<summary><b>Q1. 「+60%」是不是有点夸大？</b></summary>

**A.** `+60%` 来自 **作者自测的 A/B 实验（n=15，15 个任务，于姊妹专案 `claude-code-harness` 上量测）**。本 repo 的引用都会在同一句中附上「n=15、作者自测、第三方重现待验证」这个揭露。若你要用于导入评估，建议还是做一个 2 到 4 周的内部 pilot，以你的场景重新量测。

**证据：**
- 作者 A/B 测试：[revfactory/claude-code-harness](https://github.com/revfactory/claude-code-harness)
- Paper: *Hwang, M. (2026). Harness: Structured Pre-Configuration for Enhancing LLM Code Agent Output Quality*
</details>

<details>
<summary><b>Q2. 为什么叫「harness factory」而不是「harness builder」？这样不会跟 Archon 竞争吗？</b></summary>

**A.** Archon 产生的是可重现的 runtime 设定，也就是 **Runtime-Configuration Factory**；Harness 产生的是代理人团队架构，例如团队结构、讯息协定、审查关卡，也就是 **Team-Architecture Factory**。两者是 **同一个 L3 Meta-Factory 底下的相邻子层**，解决的不是同一个问题。需要 runtime 一致性就选 Archon，需要团队架构设计就选 Harness，也可以两者串接使用。

**证据：**
- Archon 自我定义：[clawfit docs/reference-levels.md](https://github.com/hongsw/clawfit/blob/main/docs/reference-levels.md)
- 子层宣告：请见上方 **类别定位 — Harness 位在哪一层**
- Archon repo：[github.com/coleam00/Archon](https://github.com/coleam00/Archon)
</details>

<details>
<summary><b>Q3. 只有 Claude Code 会不会太受限？Gemini 或 Codex 呢？</b></summary>

**A.** 目前官方 runtime 只有 Claude Code。相同概念的 Codex 移植版 [SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness) 已经公开，Codex 团队可以从该专案开始。Harness 选择「深入且原生支援 Claude Code」，而不是「支援多种 runtime 但各自较浅」；未来规划与 meta-harness、harness-init、OpenRig 等姊妹专案进行跨 runtime 协作。

**证据：**
- Codex 移植版：[github.com/SaehwanPark/meta-harness](https://github.com/SaehwanPark/meta-harness)
- 跨 runtime 脚手架：[github.com/Gizele1/harness-init](https://github.com/Gizele1/harness-init)
</details>

## 授权

Apache 2.0

