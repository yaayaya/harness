# Agent Team 范例

---

## 范例 1：Research 团队（Agent Team 模式）

### 团队架构：Fan-out/Fan-in
### 执行模式：Agent Team

```
[领导者／Orchestrator]
    ├── TeamCreate(research-team)
    ├── TaskCreate(4 个研究任务)
    ├── 团队成员自行协调 (SendMessage)
    ├── 收集结果 (Read)
    └── 产生综合报告
```

### Agent 组成

| 团队成员 | Agent 类型 | 角色 | 输出 |
|------|-------------|------|------|
| official-researcher | general-purpose | 官方文件／部落格 | research_official.md |
| media-researcher | general-purpose | 媒体／投资 | research_media.md |
| community-researcher | general-purpose | 社群／SNS | research_community.md |
| background-researcher | general-purpose | 背景／竞品／学术 | research_background.md |
| (Leader = Orchestrator) | — | 整合报告 | 综合报告.md |

> Research agent 使用 `general-purpose` 内建类型，但必须以 `.claude/agents/{name}.md` 档案定义。档案中应明确写出角色、调查范围与团队通讯协定，以确保可重用性与协作品质。

### Orchestrator Workflow（Agent Team）

```
Phase 1: 准备
  - 分析使用者输入（掌握主题与研究模式）
  - 建立 _workspace/

Phase 2: 组建团队
  - TeamCreate(team_name: "research-team", members: [
      { name: "official", prompt: "研究官方管道..." },
      { name: "media", prompt: "研究媒体／投资动向..." },
      { name: "community", prompt: "研究社群反应..." },
      { name: "background", prompt: "研究背景／竞争环境..." }
    ])
  - TaskCreate(tasks: [
      { title: "官方管道研究", assignee: "official" },
      { title: "媒体动向研究", assignee: "media" },
      { title: "社群反应研究", assignee: "community" },
      { title: "背景环境研究", assignee: "background" }
    ])

Phase 3: 执行研究
  - 4 位成员各自独立研究
  - 若有有趣发现，透过 SendMessage 在成员间分享
    (例：media 将发现的投资新闻传给 background)
  - 若发现资讯互相冲突，成员之间直接讨论
  - 每位成员完成后都储存档案并通知领导者

Phase 4: 整合
  - 领导者 Read 4 份产出
  - 产生综合报告
  - 对于互相冲突的资讯，并列标注来源

Phase 5: 收尾
  - 请求团队成员结束
  - 解散团队
  - 保留 _workspace/（供事后验证与稽核追踪）
```

### 团队通讯模式

```
official ──SendMessage──→ background  (分享相关官方公告)
media ────SendMessage──→ background  (分享投资／并购资讯)
community ─SendMessage──→ media      (分享社群反应中与媒体相关的资讯)
所有成员 ──TaskUpdate──→ 共享任务清单  (更新进度)
领导者 ←───── 闲置通知 ──── 已完成的成员   (自动)
```

---

## 范例 2：SF 小说写作团队（Agent Team 模式）

### 团队架构：Pipeline + Fan-out
### 执行模式：Agent Team

```
Phase 1 (并行 — Agent Team): worldbuilder + character-designer + plot-architect
  → 彼此透过 SendMessage 协调一致性
Phase 2 (顺序): prose-stylist（执笔）
Phase 3 (并行 — Agent Team): science-consultant + continuity-manager（审查）
  → 彼此透过 SendMessage 分享发现
Phase 4 (顺序): prose-stylist（依审查结果修改）
```

### Agent 组成

| 团队成员 | Agent 类型 | 角色 | Skill |
|------|-------------|------|------|
| worldbuilder | 自订 | 世界观建构 | world-setting |
| character-designer | 自订 | 角色设计 | character-profile |
| plot-architect | 自订 | 剧情结构 | outline |
| prose-stylist | 自订 | 文风编修 + 写作 | write-scene, review-chapter |
| science-consultant | 自订 | 科学验证 | science-check |
| continuity-manager | 自订 | 一致性验证 | consistency-check |

### Agent 档案完整范例：`worldbuilder.md`

```markdown
---
name: worldbuilder
description: "建构 SF 小说世界观的专家。负责设计物理法则、社会结构、技术水准与历史。"
---

# Worldbuilder — SF 世界观设计专家

你是 SF 小说的世界观设计专家。你会以科学事实为基础，同时延展想像力，建构故事展开世界的物理、社会与技术基础。

## 核心角色
1. 定义世界的物理法则与技术水准
2. 设计社会结构、政治体系与经济系统
3. 建立历史脉络与当前冲突结构
4. 描写各地点的环境与氛围

## 工作原则
- 内在一致性优先，设定之间不可互相矛盾
- 以「如果有这项技术会如何？」的连锁提问推论世界的扩散影响
- 世界观应服务故事，避免过度设定而妨碍情节

## 输入／输出协定
- 输入：使用者的世界观概念与类型需求
- 输出：`_workspace/01_worldbuilder_setting.md`
- 格式：Markdown，依章节区分（物理／社会／技术／历史／地点）

## 团队通讯协定
- 传送给 character-designer：社会结构、阶级系统、职业群资讯的 SendMessage
- 传送给 plot-architect：世界主要冲突结构与危机因素的 SendMessage
- 接收来自 science-consultant 的科学错误回馈，并修正设定
- 世界观变更时，向所有相关成员广播

## Error handling
- 若概念模糊，提出 3 个方向并请求选择
- 发现科学错误时，一并提供替代方案

## 协作
- 向 character-designer 提供社会结构资讯
- 向 plot-architect 提供冲突结构资讯
- 反映 science-consultant 的回馈来修正设定
```

### 团队 Workflow 详细说明

```
Phase 1: TeamCreate(team_name: "novel-team", members: [worldbuilder, character-designer, plot-architect])
         TaskCreate([世界观建构, 角色设计, 剧情结构])
         → 成员自行协调并平行作业
         → worldbuilder 完成社会结构时，对 character-designer 发送 SendMessage
         → character-designer 设定主角时，对 plot-architect 发送 SendMessage

Phase 2: 收尾 Phase 1 团队 → 以 subagent 呼叫 prose-stylist（因为是单独执笔，不需要团队）
         prose-stylist Read _workspace/ 中的 3 份产出后开始执笔
         → 将结果储存到 _workspace/02_prose_draft.md

Phase 3: 建立新团队 — TeamCreate(team_name: "review-team", members: [science-consultant, continuity-manager])
         （每个 session 只能有一个启用中的团队，但因为已整理完 Phase 1 团队，所以可建立新团队）
         → 两位 reviewer 检查 draft，并彼此分享发现
         → 若 science-consultant 发现物理错误，也通知 continuity-manager
         → 审查完成后整理团队

Phase 4: 以 subagent 呼叫 prose-stylist，反映审查结果进行最终修改
```

---

## 范例 3：Webtoon 制作团队（Subagent 模式）

### 团队架构：Producer-Reviewer
### 执行模式：Subagent

> 在 Producer-Reviewer pattern 中只有 2 个 agent，而且重点是结果传递而不是通讯，因此更适合使用 subagent。

```
Phase 1: Agent(webtoon-artist) → 产生面板
Phase 2: Agent(webtoon-reviewer) → 检查
Phase 3: Agent(webtoon-artist) → 重新产生有问题的面板（最多 2 次）
```

### Agent 组成

| Agent | subagent_type | 角色 | Skill |
|---------|--------------|------|------|
| webtoon-artist | 自订 | 面板图片生成 | generate-webtoon |
| webtoon-reviewer | 自订 | 品质审查 | review-webtoon, fix-webtoon-panel |

### Agent 档案完整范例：`webtoon-reviewer.md`

```markdown
---
name: webtoon-reviewer
description: "负责审查 Webtoon 面板品质的专家。评估构图、角色一致性、文字可读性与演出效果。"
---

# Webtoon Reviewer — Webtoon 品质审查专家

你是审查 Webtoon 面板品质的专家。你会以视觉完成度、故事传达力与角色一致性为标准来评估面板。

## 核心角色
1. 评估各面板的构图与视觉完成度
2. 验证角色外观在不同面板间的一致性
3. 评估对话框文字的可读性与配置
4. 检视整个篇章的演出流程与节奏

## 工作原则
- 以 PASS/FIX/REDO 三阶段做出明确判定
- FIX 表示可透过部分修改解决，REDO 表示需要全面重制
- 依客观标准（如一致性、可读性、构图）判断，而非主观喜好

## 输入／输出协定
- 输入：`_workspace/panels/` 目录中的面板图片
- 输出：`_workspace/review_report.md`
- 格式:
  ```
  ## Panel {N}
  - 判定: PASS | FIX | REDO
  - 原因: [具体原因]
  - 修改指示: [若为 FIX/REDO，请提供具体修改方向]
  ```

## Error handling
- 若图片载入失败，将该面板判定为 REDO
- 若重制 2 次后仍为 REDO，则附上警告并视为 PASS

## 协作
- 将修改指示传给 webtoon-artist（以结果档案为基础）
- 再次检查重制后的面板（最多循环 2 次）
```

### Error handling

```
重试政策:
- REDO 判定面板 → 要求 artist 重新生成（包含具体修改指示）
- 最多循环 2 次后强制 PASS
- 若超过 50% 的面板为 REDO，建议使用者修改 prompt
```

---

## 范例 4：Code Review 团队（Agent Team 模式）

### 团队架构：Fan-out/Fan-in + 讨论
### 执行模式：Agent Team

> Code review 是最能发挥 Agent Team 优势的代表性案例之一。不同观点的 reviewer 可以共享发现并互相挑战，从而做出更深入的 review。

```
[领导者] → TeamCreate(review-team)
    ├── security-reviewer: 检查安全性弱点
    ├── performance-reviewer: 分析效能影响
    └── test-reviewer: 验证测试覆盖率
    → reviewer 彼此分享发现 (SendMessage)
    → 领导者整合结果
```

### 团队通讯模式

```
security ──SendMessage──→ performance  ("这个 SQL 查询可能被注入，也需要从效能面确认")
performance ──SendMessage──→ test      ("发现 N+1 查询，请确认是否有相关测试")
test ────SendMessage──→ security      ("验证模组没有测试，从安全角度看优先顺序如何？")
```

核心：reviewer 们**不经过 leader** 直接沟通，以更快捕捉跨领域问题。

---

## 范例 5：Supervisor pattern - Code migration 团队（Agent Team 模式）

### 团队架构：Supervisor
### 执行模式：Agent Team

```
[supervisor/领导者] → 分析档案清单 → 分配批次
    ├→ [migrator-1] (batch A)
    ├→ [migrator-2] (batch B)
    └→ [migrator-3] (batch C)
    ← 接收 TaskUpdate → 追加分配批次或重新分配
```

### Agent 组成

| 团队成员 | 角色 |
|------|------|
| (Leader = migration-supervisor) | 档案分析、批次分配、进度管理 |
| migrator-1~3 | 迁移被指派的档案批次 |

### Supervisor 的动态分配逻辑（活用 Agent Team）

```
1. 收集所有目标档案清单
2. 估算复杂度（档案大小、import 数量、相依性）
3. 以 TaskCreate 将档案批次登记为任务（包含相依性）
4. 团队成员自行请求工作（claim）
5. 当成员用 TaskUpdate 回报完成时：
   - 成功 → 自动请求下一项工作
   - 失败 → 领导者用 SendMessage 确认原因 → 重新分配或改派其他成员
6. 所有工作完成 → 领导者执行整合测试
```

与 Fan-out 的差异在于：工作不是事先固定，而是**在 runtime 动态分配**。共享工作清单的自主 claim 功能，与 Supervisor pattern 自然契合。

---

## 产出模式摘要

### Agent 定义档
位置：`专案/.claude/agents/{agent-name}.md`
必要章节：核心角色、工作原则、输入／输出协定、Error handling、协作
团队模式额外章节：**团队通讯协定**（讯息接收／发送、可 claim 的工作范围）

### Skill 档案结构
位置：`专案/.claude/skills/{skill-name}/SKILL.md`（专案层级）
或：`~/.claude/skills/{skill-name}/SKILL.md`（全域层级）

### 整合 Skill（Orchestrator）
协调整个团队的上层 skill。定义各情境的 agent 组成与 workflow。
范本请参考：`references/orchestrator-template.md`。
**必须明确标示执行模式** - Agent Team（预设）或 Subagent。
