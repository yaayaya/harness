---
name: harness
description: "建构 Harness。这是一个定义专业 agent 并建立该 agent 所使用 skill 的 meta-skill。适用于：(1) 收到「帮我配置 Harness」、「帮我建立 Harness」请求时，(2) 收到「Harness 设计」、「Harness 工程」请求时，(3) 要为新领域/新专案建立以 Harness 为基础的自动化体系时，(4) 要重构或扩充 Harness 配置时，(5) 收到「检查 Harness」、「审核 Harness」、「Harness 现况」、「agent/skill 同步」等既有 Harness 营运/维护请求时使用。"
---

# Harness — Agent Team & Skill Architect

针对对应领域/专案配置 Harness，定义各 agent 的角色，并建立 agent 会使用的 skill 的 meta-skill。

**核心原则：**
1. 建立 agent 定义（`.claude/agents/`）与 skill（`.claude/skills/`）。
2. **将 Agent Teams 作为预设执行模式。**
3. **在 CLAUDE.md 注册 Harness 指标。** — 只记录最小必要的指标（触发规则 + 变更历程），让新的 session 能触发 orchestrator skill。
4. **Harness 不是固定不变的成品，而是持续演化的系统。** — 每次执行后都纳入回馈，持续更新 agent、skill 与 CLAUDE.md。

## 工作流程

### Phase 0: 现况稽核

当 Harness skill 被触发时，首先要检查既有 Harness 现况。

1. 读取 `专案/.claude/agents/`、`专案/.claude/skills/`、`专案/CLAUDE.md`
2. 根据现况切分执行模式：
   - **新建**：agent/skill 目录不存在或为空 → 从 Phase 1 开始完整执行
   - **既有扩充**：既有 Harness 存在，且收到新增 agent/skill 的请求 → 依下方 Phase 选择矩阵，只执行需要的 Phase
   - **营运/维护**：既有 Harness 的稽核、修正、同步请求 → 移动到 Phase 7-5 营运/维护工作流程

   **既有扩充时的 Phase 选择矩阵：**
   | 变更类型 | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Phase 6 |
   |----------|---------|---------|---------|---------|---------|---------|
   | 新增 agent | 跳过（使用 Phase 0 结果） | 只决定配置 | 必要 | 仅在需要专属 skill 时 | 修改 orchestrator | 必要 |
   | 新增/修改 skill | 跳过 | 跳过 | 跳过 | 必要 | 仅在连结有变更时 | 必要 |
   | 架构变更 | 跳过 | 必要 | 只处理受影响 agent | 只处理受影响 skill | 必要 | 必要 |
3. 比对既有 agent/skill 清单与 CLAUDE.md 纪录，侦测不一致（drift）
4. 向使用者摘要报告稽核结果，并确认执行计划

### Phase 1: 领域分析
1. 从使用者请求辨识领域/专案
2. 识别核心工作类型（生成、验证、编辑、分析等）
3. 根据 Phase 0 稽核结果，分析与既有 agent/skill 的冲突或重复
4. 探索专案 codebase —— 了解技术堆叠、资料模型、主要模组
5. **侦测使用者熟练度** —— 透过对话脉络线索（使用术语、提问层次）判断技术水准，并调整后续沟通语气。对程式经验较少的使用者，不要在没有说明的情况下直接使用像 `assertion`、`JSON schema` 这类术语。

### Phase 2: 团队架构设计

#### 2-1. 选择执行模式

**Agent Teams 是最优先的预设值。** 只要有两个以上 agent 协作，就必须先评估 Agent Teams。成员之间可以直接通讯（SendMessage），并透过共享工作清单（TaskCreate）自我协调；共享发现、讨论冲突、补齐遗漏，都能提升结果品质。

| 模式 | 何时使用 | 特性 |
|------|----------|------|
| **Agent Teams**（预设） | 2 人以上协作、需要即时协调/交换回馈、中间产物需要互相参照 | 透过 `TeamCreate` + `SendMessage` + `TaskCreate` 进行自我协调 |
| **Sub-agents**（替代） | 单一 agent 作业、只需把结果回传给主流程、团队通讯开销过高时 | 直接呼叫 `Agent` 工具，搭配 `run_in_background` 进行平行化 |
| **Hybrid** | 各 Phase 特性不同时 —— 例如：平行收集（sub）→ 共识整合（team） | 依 Phase 混合 team/sub 模式 |

**决策顺序：**
1. 先检查是否可用 Agent Teams 设计 —— 只要有 2 人以上就是预设值
2. 只有在团队通讯结构上确实不必要（只需传递结果），且 team 的开销大于收益时，才选用 sub-agent
3. 若各 Phase 特性差异明显，再考虑 Hybrid —— 并在 orchestrator 中明确标示各 Phase 的执行模式

> 详细比较表与各 pattern 的决策树，请参考 `references/agent-design-patterns.md` 的「执行模式」。

#### 2-2. 选择架构 pattern

1. 将工作拆解为专业领域
2. 决定 Agent Team 结构（架构 pattern 请参考 `references/agent-design-patterns.md`）
   - **Pipeline**：依序相依的工作
   - **Fan-out/Fan-in**：平行且独立的工作
   - **Expert Pool**：依情境选择性呼叫
   - **Producer-Reviewer**：先生成再做品质审查
   - **Supervisor**：中央 agent 管理状态并动态分派
   - **Hierarchical Delegation**：上层 agent 递回委派给下层

#### 2-3. Agent 拆分标准

依专业性、平行性、context、可重用性四个面向判断。详细标准表请参考 `references/agent-design-patterns.md` 的「agent 拆分标准」。

### Phase 3: 建立 agent 定义

**所有 agent 都必须定义为 `专案/.claude/agents/{name}.md` 档案。** 禁止在没有 agent 定义档的情况下，直接把角色写进 Agent 工具的 prompt。原因如下：
- agent 定义必须以档案形式存在，才能在下次 session 重复使用
- 必须明确写出团队通讯协定，才能保证 agent 之间的协作品质
- Harness 的核心价值是分离 agent（谁做）与 skill（怎么做）

即使使用 built-in type（`general-purpose`、`Explore`、`Plan`），也必须建立 agent 定义档。built-in type 透过 Agent 工具的 `subagent_type` 参数指定，而 agent 定义档则负责承载角色、原则与协定。

**模型设定：** 所有 agent 都使用 `model: "opus"`。呼叫 Agent 工具时，务必明确带上 `model: "opus"` 参数。Harness 的品质与 agent 的推理能力直接相关，而 opus 能提供最佳品质。

**重组团队：** 每个 session 只能启用一个 Agent Team，但可以在不同 Phase 之间解散并重建新团队。若像 Pipeline pattern 那样，每个 Phase 需要不同的专家组合，就先把前一个团队的产出存成档案，再整理旧团队并建立新团队。

将每个 agent 定义在 `专案/.claude/agents/{name}.md`。必要区段：核心角色、工作原则、输入/输出协定、错误处理、协作。在 Agent Team 模式下，还要新增 `## 团队通讯协定` 区段，说明讯息接收/发送对象与工作请求范围。

> 定义范本与完整实际档案内容，请参考 `references/agent-design-patterns.md` 的「agent 定义结构」与 `references/team-examples.md`。

**若包含 QA agent，必须遵守：**
- QA agent 请使用 `general-purpose` 类型（`Explore` 为唯读，无法执行验证 script）
- QA 的核心不是「确认有没有」，而是 **「交叉比对边界面」** —— 同时读取 API 回应与前端 hook，再比对 shape
- QA 不是在全部完成后只做 1 次，而是 **每个模组一完成就渐进执行**（incremental QA）
- 详细指南：请参考 `references/qa-agent-guide.md`

### Phase 4: 建立 skill

将各 agent 会使用的 skill 建立在 `专案/.claude/skills/{name}/SKILL.md`。详细撰写指南请参考 `references/skill-writing-guide.md`。

#### 4-1. Skill 结构

```
skill-name/
├── SKILL.md (必填)
│   ├── YAML frontmatter (name, description 必填)
│   └── Markdown 内文
└── Bundled Resources (选填)
    ├── scripts/    - 用于重复性/可决定性工作的可执行程式码
    ├── references/ - 条件式载入的参考文件
    └── assets/     - 用于输出的档案（范本、图片等）
```

#### 4-2. 撰写 description —— 主动促成触发

description 是 skill 唯一的触发机制。Claude 对触发条件通常判断保守，因此 description 要写得**积极（"pushy"）**。

**不好的例子：** `"处理 PDF 文件的 skill"`
**好的例子：** `"执行所有 PDF 工作，包括读取 PDF 档、撷取文字/表格、合并、分割、旋转、浮水印、加密、OCR 等。只要提到 .pdf 档案或要求 PDF 输出，就一定要使用这个 skill。"`

重点：同时描述这个 skill 做什么，以及哪些具体情况要触发，并且要能和相似但不应触发的情况区分开来。

#### 4-3. 内文撰写原则

| 原则 | 说明 |
|------|------|
| **解释 Why** | 不要只用像 "ALWAYS/NEVER" 这种强硬指令，而是要说明为什么。LLM 理解原因后，面对 edge case 也更能正确判断。 |
| **保持精简** | context window 是公共资源。SKILL.md 内文目标控制在 500 行内，不必要增加负担的内容要删掉或移到 references/。 |
| **一般化** | 与其写只适用于特定例子的狭窄规则，不如说明原理，让它能处理多种输入。避免 overfitting。 |
| **重复程式码要 bundle** | 若在测试执行中发现 agent 反复撰写相同 script，就先 bundle 到 `scripts/`。 |
| **使用命令式写法** | 采用「~做」、「~请执行」这类命令式/指示式语气。 |

#### 4-4. Progressive Disclosure（渐进式资讯揭露）

skill 透过 3 层载入系统管理 context：

| 阶段 | 载入时机 | 大小目标 |
|------|----------|----------|
| **Metadata**（name + description） | 永远存在于 context 中 | 约 100 字 |
| **SKILL.md 内文** | skill 被触发时 | <500 行 |
| **references/** | 只有在需要时 | 无上限（script 可不载入直接执行） |

**大小管理规则：**
- 当 SKILL.md 接近 500 行时，把细节拆到 references/，并在内文保留「何时应读这个档案」的指标
- 超过 300 行的 reference 档案，在开头加入 **目录（ToC）**
- 若存在领域/框架专属变体，请拆分到 references/ 子目录，只载入相关档案

```
cloud-deploy/
├── SKILL.md (工作流程 + 选择指南)
└── references/
    ├── aws.md    ← 只有在选择 AWS 时才载入
    ├── gcp.md
    └── azure.md
```

#### 4-5. Skill-agent 连结原则

- 1 个 agent ↔ 1~N 个 skill（1:1 或 1:多）
- skill 也可以由多个 agent 共用
- skill 负责「怎么做」，agent 负责「谁来做」

> 详细撰写 pattern、范例与资料 schema 标准，请参考 `references/skill-writing-guide.md`。

### Phase 5: 整合与 orchestration

orchestrator 是一种特殊型态的 skill，负责把个别 agent 与 skill 串成单一工作流程，协调整个团队。若说 Phase 4 建立的个别 skill 定义的是「各 agent 要做什么、怎么做」，那 orchestrator 定义的就是「谁在什么时候、依什么顺序合作」。具体范本请参考 `references/orchestrator-template.md`。

**既有扩充时修改 orchestrator：** 若不是新建，而是扩充既有配置，不要重建新的 orchestrator，而是修改既有 orchestrator。新增 agent 时，要把新 agent 纳入团队配置、工作分派与资料流，也要在 description 新增与新 agent 相关的触发关键字。

依照 Phase 2-1 选定的执行模式，orchestrator pattern 会有所不同：

#### 5-0. Orchestrator pattern（依模式）

**Agent Team pattern（预设）：**
orchestrator 透过 `TeamCreate` 建立团队，再用 `TaskCreate` 分派工作。团队成员用 `SendMessage` 直接通讯并自我协调。leader（orchestrator）负责监控进度并汇整结果。

```
[orchestrator/leader]
    ├── TeamCreate(team_name, members)
    ├── TaskCreate(tasks with dependencies)
    ├── 成员自我协调（SendMessage）
    ├── 收集并汇整结果
    └── 整理解散团队
```

**Sub-agent pattern（替代）：**
orchestrator 直接透过 `Agent` 工具呼叫 sub-agent。平行执行时使用 `run_in_background: true`，结果只回传给主流程。适用于不需要团队通讯、希望降低开销的情况。

```
[orchestrator]
    ├── Agent(agent-1, run_in_background=true)
    ├── Agent(agent-2, run_in_background=true)
    ├── 等待并收集结果
    └── 产生整合输出
```

**Hybrid pattern：**
各 Phase 混用不同模式。常见组合：
- **平行收集（sub）→ 共识整合（team）**：在 Phase 2 用 sub-agent 平行收集独立资料 → 在 Phase 3 建立 team 进行讨论、共识式整合
- **team 生成 → sub 验证**：在 Phase 2 由 team 产生初稿 → 在 Phase 3 由单一 sub-agent 独立验证
- **跨 Phase 重组 team**：每个 Phase 都先 `TeamDelete` 再 `TeamCreate`，中间插入 sub-agent 呼叫

若选择 Hybrid，请在 orchestrator 的各 Phase 区段开头明确标示该 Phase 的执行模式（例如：`**执行模式：** Agent Teams`）。

#### 5-1. 资料传递协定

在 orchestrator 中明确规范 agent 之间如何传递资料：

| 策略 | 方式 | 适用模式 | 适合情境 |
|------|------|----------|-----------|
| **讯息型** | 以 `SendMessage` 让成员直接通讯 | team | 即时协调、交换回馈、轻量状态传递 |
| **任务型** | 以 `TaskCreate`/`TaskUpdate` 分享工作状态 | team | 追踪进度、管理相依性、请求工作本身 |
| **档案型** | 在约定路径写入/读取档案 | team + sub | 大量资料、结构化产物、需要稽核追踪 |
| **回传值型** | 使用 `Agent` 工具的回传讯息 | sub | 主流程直接收集 sub-agent 结果 |

**建议组合（team 模式）：** 任务型（协调） + 档案型（产物） + 讯息型（即时沟通）
**建议组合（sub 模式）：** 回传值型（结果收集） + 档案型（大型产物）
**Hybrid：** 依各 Phase 的执行模式套用对应组合

使用档案型传递时的规则：
- 在工作目录下建立 `_workspace/` 资料夹，用来存放中间产物
- 档名惯例：`{phase}_{agent}_{artifact}.{ext}`（例如：`01_analyst_requirements.md`）
- 最终产物才输出到使用者指定路径，中间档案（`_workspace/`）要保留（供事后验证与稽核追踪）

#### 5-2. 错误处理

在 orchestrator 中加入错误处理方针。核心原则：先重试 1 次，若再次失败，就在没有该结果的情况下继续进行（并在报告中标示缺漏）；若资料互相冲突，不要删除，而是保留来源并列出。

> 各种错误类型的策略表与实作细节，请参考 `references/orchestrator-template.md` 的「错误处理」。

#### 5-3. 团队规模指引

| 工作规模 | 建议成员数 | 每位成员负责工作数 |
|----------|------------|--------------------|
| 小型（5~10 个工作） | 2~3 人 | 3~5 个 |
| 中型（10~20 个工作） | 3~5 人 | 4~6 个 |
| 大型（20 个以上工作） | 5~7 人 | 4~5 个 |

> 成员越多，协调开销越高。3 位专注的成员通常比 5 位分散的成员更好。

#### 5-4. 在 CLAUDE.md 注册 Harness 指标

当 Harness 配置完成后，在专案的 `CLAUDE.md` 注册最小必要指标。因为 CLAUDE.md 每个新 session 都会载入，只需记录 Harness 的存在与触发规则，剩下的由 orchestrator skill 负责。

**CLAUDE.md 范本：**

````markdown
## Harness: {领域名称}

**目标：** {Harness 核心目标的一句话}

**触发规则：** 收到与 {领域} 相关的工作请求时，使用 `{orchestrator-skill-name}` skill。若只是简单问题，可以直接回答。

**变更历程：**
| 日期 | 变更内容 | 对象 | 原因 |
|------|----------|------|------|
| {YYYY-MM-DD} | 初始配置 | 全部 | - |
````

**不要放进 CLAUDE.md 的内容：** agent 清单、skill 清单、目录结构、详细执行规则。原因：agent/skill 清单已由 orchestrator skill 与 `.claude/agents/`、`.claude/skills/` 管理，重复了；目录结构可直接从档案系统确认。CLAUDE.md 只保留 **指标（触发规则） + 变更历程**。

#### 5-5. 支援后续工作

orchestrator 不只要处理初次执行，也要能处理后续工作。请确保下列三点：

**1. 在 orchestrator description 中纳入后续工作关键字：**
如果只写初次建立相关关键字，后续请求就不会被触发。description 必须包含：
- 「重新执行」、「再跑一次」、「更新」、「修改」、「补强」
- 「只重跑 {领域} 的 {部分工作}」
- 「基于先前结果」、「改善结果」

**2. 在 orchestrator 的 Phase 1 加入 context 检查步骤：**
工作流程启动时，先确认既有产物是否存在，再决定执行模式：
- `_workspace/` 存在 + 使用者要求部分修改 → **部分重跑**（只重新呼叫对应 agent）
- `_workspace/` 存在 + 使用者提供新输入 → **新执行**（将旧 `_workspace` 移到 `_workspace_prev/`）
- `_workspace/` 不存在 → **初始执行**

**3. 在 agent 定义中加入重新呼叫指引：**
在各 agent 的 `.md` 档中明确写出「已有先前产物时该如何处理」：
- 若先前结果档存在，先读取并反映改善点
- 若有使用者回馈，仅修改对应部分

> 请参考 orchestrator 范本中 `references/orchestrator-template.md` 的「Phase 0: context 检查」区段

### Phase 6: 验证与测试

验证生成好的 Harness。详细测试方法请参考 `references/skill-testing-guide.md`。

#### 6-1. 结构验证

- 确认所有 agent 档都在正确位置
- 验证 skill 的 frontmatter（name、description）
- 确认 agent 间参照一致
- 确认没有建立 command

#### 6-2. 依执行模式验证

- **Agent Teams**：检查成员间通讯路径、工作相依性、团队规模是否合适
- **Sub-agents**：检查各 agent 的输入/输出连结、`run_in_background` 设定、回传值收集逻辑
- **Hybrid**：确认各 Phase 的执行模式是否明确标示在 orchestrator 中，并检查 Phase 边界的资料传递是否中断（team → sub 切换时，team 的产物是否有正确连接为 sub 的输入）

#### 6-3. Skill 执行测试

针对每个建立好的 skill，实际进行执行测试：

1. **撰写测试 prompt** —— 每个 skill 撰写 2~3 个具体且自然、符合真实使用者情境的测试 prompt。

2. **比较 With-skill 与 Without-skill 的执行** —— 若可行，平行执行有 skill 与无 skill 的版本，确认 skill 的附加价值。为此建立两个 agent：
   - **With-skill**：读取 skill 后执行工作
   - **Without-skill (baseline)**：在没有 skill 的情况下，用相同 prompt 执行

3. **评估结果** —— 从质性（使用者评论）与量化（基于 assertion）两个层面评估输出品质。若产物可客观验证（例如档案生成、资料撷取），定义 assertion；若较主观（例如语气、设计），就依赖使用者回馈。

4. **反复改善回圈** —— 若测试中发现问题：
   - 将回馈**一般化**后再修改 skill（避免只针对单一例子做狭窄修补）
   - 修改后重新测试
   - 持续反复，直到使用者满意或已无实质可改善空间

5. **Bundle 重复 pattern** —— 若在测试执行中发现 agent 反复撰写相同程式码（例如每次都生成相同 helper script），就先把它 bundle 到 `scripts/`。

#### 6-4. 触发验证

验证每个 skill 的 description 是否会被正确触发：

1. **Should-trigger 查询**（8~10 个）—— 各种应该触发 skill 的表达方式（正式/口语、明示/暗示）
2. **Should-NOT-trigger 查询**（8~10 个）—— 关键字相似，但实际上更适合其他工具/skill 的「near-miss」查询

**撰写 near-miss 的重点：** 像「帮我写 Fibonacci 函式」这种明显无关的查询，测试价值很低。像「帮我把这个 excel 档里的图表汇出成 PNG」（xlsx skill vs 图片转换）这种**边界模糊的查询**才是好的测试案例。

这个阶段也要检查与既有 skill 是否发生触发冲突。

#### 6-5. Dry-run 测试

- 检查 orchestrator skill 的 Phase 顺序是否合理
- 确认资料传递路径中没有空白区段（dead link）
- 确认所有 agent 的输入都能对应到前一个 Phase 的输出
- 确认各种错误情境的 fallback 路径都可执行

#### 6-6. 撰写测试情境

- 在 orchestrator skill 中新增 `## 测试情境` 区段
- 至少描述 1 个正常流程 + 1 个错误流程

### Phase 7: Harness 演化

Harness 不是建立一次就结束的静态产物，而是会随使用者回馈持续演化的系统。

#### 7-1. 执行后搜集回馈

每次 Harness 执行完成后，都向使用者索取回馈：
- 「结果有没有哪里需要改善？」
- 「Agent Team 配置或工作流程有没有想调整的地方？」

若没有回馈就继续，不要强迫，但一定要提供这个机会。

#### 7-2. 反映回馈的路径

依回馈类型，修改对象不同：

| 回馈类型 | 修改对象 | 例子 |
|-----------|----------|------|
| 产物品质 | 对应 agent 的 skill | 「分析太浅」→ 在 skill 新增深度标准 |
| agent 角色 | agent 定义 `.md` | 「也需要做安全审查」→ 新增 agent |
| 工作流程顺序 | orchestrator skill | 「应该先验证」→ 调整 Phase 顺序 |
| 团队配置 | orchestrator + agent | 「这两个感觉可以合并」→ 合并 agent |
| 触发漏掉 | skill description | 「这种说法不会触发」→ 扩充 description |

#### 7-3. 变更历程

所有变更都要记录在 CLAUDE.md 的 **变更历程** 表格中（与 Phase 5-4 范本中的「变更历程」区段相同）：

```markdown
**变更历程：**
| 日期 | 变更内容 | 对象 | 原因 |
|------|----------|------|------|
| 2026-04-05 | 初始配置 | 全部 | - |
| 2026-04-07 | 新增 QA agent | agents/qa.md | 使用者反映产物品质验证不足 |
| 2026-04-10 | 新增语气指南 | skills/content-creator | 收到「太生硬」的回馈 |
```

透过这份历程，可以追踪 Harness 是如何演化的，也能避免 regression。

#### 7-4. 演化触发时机

不只在使用者明确说「请帮我修改 Harness」时才演化，以下情况也要主动提出：
- 同类型回馈重复出现 2 次以上
- 发现 agent 反复失败的 pattern
- 观察到使用者绕过 orchestrator 改成手动作业

#### 7-5. 营运/维护工作流程

有系统地执行既有 Harness 的检查、修正与同步。当 Phase 0 进入「营运/维护」分支时，依照此流程进行。

**Step 1: 现况稽核**
- 比对 `.claude/agents/` 档案清单与 orchestrator skill 中的 agent 配置 → 产生不一致清单
- 比对 `.claude/skills/` 目录清单与 orchestrator skill 中的 skill 配置 → 产生不一致清单
- 将稽核结果回报给使用者

**Step 2: 渐进式新增/修正**
- 依使用者请求执行 agent 的新增/修改/删除，以及 skill 的新增/修改/删除
- 每次只做一项变更，每做完一项立刻执行 Step 3（同步）

**Step 3: 更新 CLAUDE.md 变更历程**
- 在变更历程表中记录日期、变更内容、对象、原因

**Step 4: 验证变更**
- 依 Phase 6-1 标准验证修改过的 agent/skill 结构
- 若修改范围会影响触发条件，则依 Phase 6-4 进行触发验证
- 若是大型变更（架构调整、一次新增/删除 3 个以上 agent），则进一步执行 Phase 6-3（执行测试）与 6-5（dry-run）
- 最后再次确认 CLAUDE.md 与实际档案是否一致

## 产物检查清单

建立完成后确认：

- [ ] `专案/.claude/agents/` — **必须建立 agent 定义档**（即使是 built-in type，也一定要建立档案）
- [ ] `专案/.claude/skills/` — skill 档案（SKILL.md + references/）
- [ ] 1 个 orchestrator skill（包含资料流 + 错误处理 + 测试情境）
- [ ] 明确标示执行模式（Agent Teams / Sub-agents / Hybrid 三选一；若为 Hybrid，要写出各 Phase 模式）
- [ ] 所有 Agent 呼叫都明确带上 `model: "opus"` 参数
- [ ] `.claude/commands/` — 不建立任何内容
- [ ] 与既有 agent/skill 无冲突
- [ ] skill description 以积极（"pushy"）方式撰写 —— **包含后续工作关键字**
- [ ] SKILL.md 内文控制在 500 行内，超出则拆到 references/
- [ ] 已用 2~3 个测试 prompt 完成执行验证
- [ ] 已完成触发验证（should-trigger + should-NOT-trigger）
- [ ] **在 CLAUDE.md 注册 Harness 指标**（触发规则 + 变更历程）
- [ ] **在 CLAUDE.md 的变更历程记录 agent/skill 的新增/删除/修改**
- [ ] **在 orchestrator 的 Phase 1 加入 context 检查步骤**（判断初始/后续/部分重跑）

## 参考资料

- Harness pattern：`references/agent-design-patterns.md`
- 既有 Harness 范例（含完整实际档案内容）：`references/team-examples.md`
- orchestrator 范本：`references/orchestrator-template.md`
- **Skill 撰写指南**：`references/skill-writing-guide.md` — 撰写 pattern、范例、资料 schema 标准
- **Skill 测试指南**：`references/skill-testing-guide.md` — 测试/评估/反复改善方法论
- **QA agent 指南**：`references/qa-agent-guide.md` — 在 build Harness 时若要纳入 QA agent 可参考。包含整合一致性验证方法、边界面 bug pattern、QA agent 定义范本，并以实际专案中发现的 7 个 bug 案例为基础。
