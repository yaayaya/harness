# Agent Team Design Patterns

## 执行模式：Agent Teams vs Sub-agents

理解两种执行模式的核心差异，并选择合适的模式。

### Agent Teams — 预设模式

team leader 使用 `TeamCreate` 组成团队，而 team 成员会以独立的 Claude Code instance 执行。成员之间可透过 `SendMessage` 直接通讯，并以共享工作清单（`TaskCreate`/`TaskUpdate`）自我协调。

```
[Leader] ←→ [MemberA] ←→ [MemberB]
  ↕          ↕          ↕
  └──── Shared Task List ────┘
```

**核心工具：**
- `TeamCreate`: 建立 team + 启动 team 成员
- `SendMessage({to: name})`: 传送讯息给特定成员
- `SendMessage({to: "all"})`: 广播（成本高，应少用）
- `TaskCreate`/`TaskUpdate`: 管理共享工作清单

**特性：**
- 成员之间可直接对话、挑战、验证
- 不需经过 leader，即可在成员间交换资讯
- 使用共享工作清单进行自我协调（也可自行提出工作请求）
- 成员若进入闲置状态，会自动通知 leader
- 可透过 plan approval mode，在高风险操作前先审查

**限制：**
- 每个 session 只能有一个 **active** team（但可以在不同 Phase 解散后重建新 team）
- 不支援巢状 team（team 成员不能再建立自己的 team）
- leader 固定（不可转移）
- token 成本较高

**重组 team 的 pattern：**
若各 Phase 需要不同专家组合，流程为：先将前一个 team 的产物写入档案 → 整理解散 team → 建立新 team。前一个 team 的产物保存在 `_workspace/`，因此新 team 可以透过 Read 存取。

### Sub-agents — 轻量模式

主 agent 使用 `Agent` 工具建立 sub-agent。sub-agent 只会把工作结果回传给主 agent，彼此之间不会通讯。

```
[Main] → [SubA] → Return result
      → [SubB] → Return result
      → [SubC] → Return result
```

**核心工具：**
- `Agent(prompt, subagent_type, run_in_background)`: 建立 sub-agent

**特性：**
- 轻量且快速
- 结果会摘要后回到主 context
- token 效率较高

**限制：**
- sub-agent 之间无法通讯
- 所有协调都由主 agent 负责
- 无法进行即时协作/挑战

### 模式选择决策树

```
是否有 2 个以上的 agent？
├── Yes → agent 之间是否需要通讯？
│         ├── Yes → Agent Teams（预设）
│         │         透过交叉验证、共享发现、即时回馈来提升品质。
│         │
│         └── No → 也可以使用 Sub-agents
│                  适合只需要传结果的生成-验证、Expert Pool 等情境。
│
└── No（1 个） → Sub-agents
               单一 agent 不需要建立 team。
```

> **核心原则：** Agent Teams 是预设值。当你想选 Sub-agents 时，先自问：「team 成员之间真的完全不需要通讯吗？」

---

## Agent Team 架构类型

### 1. Pipeline
顺序式工作流程。前一个 agent 的输出会成为下一个 agent 的输入。

```
[Analysis] → [Design] → [Implementation] → [Validation]
```

**适合情境：** 每个阶段都高度依赖前一阶段产物  
**例子：** 小说写作 —— 世界观 → 角色 → 剧情 → 写作 → 编辑  
**注意：** 任一瓶颈都会拖慢整条 Pipeline。每个阶段都应尽可能独立设计。  
**适用的 team 模式：** 因为顺序相依性很强，team 模式的优势较有限。但若 Pipeline 内存在可平行化区段，team 模式仍然有价值。

### 2. Fan-out/Fan-in
先平行处理，再整合结果。同时执行彼此独立的工作。

```
         ┌→ [ExpertA] ─┐
[Dispatch] → ├→ [ExpertB] ─┼→ [Integration]
         └→ [ExpertC] ─┘
```

**适合情境：** 针对同一份输入，需要从不同观点/领域进行分析  
**例子：** 综合研究 —— 同步调查官方/媒体/社群/背景资料 → 整合报告  
**注意：** 整合阶段的品质会决定最终品质。  
**适用的 team 模式：** 这是最自然的 Agent Teams pattern。**必须使用 Agent Teams。** 成员可以互相分享发现与提出挑战，一个 agent 的新发现能即时修正其他 agent 的调查方向，因此比各自独立调查的品质更高。

### 3. Expert Pool
依情境选择合适的专家进行呼叫。

```
[Router] → { ExpertA | ExpertB | ExpertC }
```

**适合情境：** 根据输入类型需要不同处理方式  
**例子：** 程式码审查 —— 从安全、效能、架构专家中只呼叫对应领域  
**注意：** router 的分类准确度是关键。  
**适用的 team 模式：** 更适合用 Sub-agents。因为只需呼叫需要的专家，没必要维持常驻 team。

### 4. Producer-Reviewer
生成 agent 与验证 agent 成对运作。

```
[Producer] → [Reviewer] → (if issues) → [Producer] rerun
```

**适合情境：** 产物品质保证很重要，且存在客观验证标准  
**例子：** Webtoon —— artist 生成 → reviewer 审查 → 有问题的 panel 重新生成  
**注意：** 为避免无限回圈，必须设定最大重试次数（2~3 次）。  
**适用的 team 模式：** Agent Teams 很有帮助。可透过 SendMessage 让 producer 与 reviewer 即时交换回馈。

### 5. Supervisor
中央 agent 管理工作状态，并动态把工作分派给下层 agent。

```
         ┌→ [WorkerA]
[Supervisor] ─┼→ [WorkerB]    ← supervisor 观察状态后动态分派
         └→ [WorkerC]
```

**适合情境：** 工作量可变，或需要在执行期间动态决定如何分派工作  
**例子：** 大型程式码 migration —— supervisor 分析档案清单，再分批指派给 workers  
**与 Fan-out 的差异：** Fan-out 是事先固定分派工作；Supervisor 则会根据进度动态调整  
**注意：** 委派粒度要够大，避免 supervisor 成为瓶颈。  
**适用的 team 模式：** Agent Teams 的共享工作清单和 Supervisor pattern 非常契合。使用 TaskCreate 登记工作，成员再自行请领。

### 6. Hierarchical Delegation
上层 agent 会递回委派给下层 agent，将复杂问题逐层拆解。

```
[Lead] → [TeamLeadA] → [ExecutorA1]
                     → [ExecutorA2]
       → [TeamLeadB] → [ExecutorB1]
```

**适合情境：** 问题本身天然适合分层拆解  
**例子：** Full-stack app 开发 —— 总负责 → 前端 team lead →（UI/逻辑/测试）+ 后端 team lead →（API/DB/测试）  
**注意：** 深度超过 3 层时，延迟与 context 损耗会大增。建议控制在 2 层内。  
**适用的 team 模式：** Agent Teams 不支援巢状（team 成员不能再建立 team）。第一层可用 team，第二层改用 sub-agent，或干脆展平成单一 team。

## 复合 pattern

实务上，比起单一 pattern，更常见的是复合 pattern：

| 复合 pattern | 组成 | 例子 |
|----------|------|------|
| **Fan-out + Producer-Reviewer** | 平行生成后逐一验证 | 多语翻译 —— 4 种语言平行翻译 → 各自由 native reviewer 审查 |
| **Pipeline + Fan-out** | 在顺序式流程中将部分阶段平行化 | 分析（顺序）→ 实作（平行）→ 整合测试（顺序） |
| **Supervisor + Expert Pool** | supervisor 动态呼叫专家 | 客服处理 —— supervisor 先分类问题，再分派合适专家 |

### 复合 pattern 下的执行模式

**原则上所有复合 pattern 都优先使用 Agent Teams。** 团队成员之间活跃的沟通，是提升结果品质的关键动力。

| 情境 | 建议模式 | 原因 |
|---------|----------|------|
| **研究 + 分析** | Agent Teams | 调查者之间可共享发现，即时讨论矛盾资讯 |
| **设计 + 实作 + 验证** | Agent Teams | 设计者、实作者、验证者之间能形成回馈回圈 |
| **Supervisor + Worker** | Agent Teams | 可用共享工作清单做动态分派，也能共享进度 |
| **生成 + 验证** | Agent Teams | 生成者与验证者即时交换回馈，减少返工 |

> 只有在单一 agent 执行完全隔离、一次性的工作时，才考虑混用 Sub-agents。

## 选择 agent 类型

呼叫 agent 时，透过 Agent 工具的 `subagent_type` 参数指定类型。Agent Team 的成员也可以使用自订 agent 定义。

### Built-in type

| 类型 | 工具存取 | 适合用途 |
|------|----------|-----------|
| `general-purpose` | 完整（包含 WebSearch、WebFetch） | 网路调查、通用工作 |
| `Explore` | 唯读（无 Edit/Write） | 探索 codebase、分析 |
| `Plan` | 唯读（无 Edit/Write） | 架构设计、规划 |

### 自订 type

若在 `.claude/agents/{name}.md` 定义了 agent，就能用 `subagent_type: "{name}"` 呼叫。自订 agent 可使用完整工具集。

### 选择标准

| 情境 | 建议 | 原因 |
|------|------|------|
| 角色复杂，且会跨多个 session 重复使用 | **自订 type**（`.claude/agents/`） | 可把 persona 与工作原则管理在档案中 |
| 只是单纯调查/搜集，prompt 就已足够 | **`general-purpose`** + 详细 prompt | 不需要额外 agent 档，直接在 prompt 下指令 |
| 只需要读程式码（分析/审查） | **`Explore`** | 避免误改档案 |
| 只需要做设计/规划 | **`Plan`** | 专注分析，避免变更程式码 |
| 需要修改档案的实作工作 | **自订 type** | 完整工具存取 + 专业化指示 |

**原则：** 所有 agent 都必须定义在 `.claude/agents/{name}.md` 档案中。即使是 built-in type，也要建立 agent 定义档，明确写出角色、原则与协定。只有以档案形式存在，才能在后续 session 重复使用，也只有明确写出团队通讯协定，才能保证协作品质。

**模型：** 所有 agent 都使用 `model: "opus"`。呼叫 Agent 工具时，务必带上 `model: "opus"` 参数。

## agent 定义结构

```markdown
---
name: agent-name
description: "1-2 句角色说明。列出触发关键字。"
---

# Agent Name — 角色一句话摘要

你是 [领域] 的 [角色] 专家。

## 核心角色
1. 角色1
2. 角色2

## 工作原则
- 原则1
- 原则2

## 输入/输出协定
- 输入：[从哪里接收什么]
- 输出：[写到哪里、写什么]
- 格式：[档案格式、结构]

## 团队通讯协定（Agent Team 模式）
- 接收讯息：[会从谁收到什么讯息]
- 发送讯息：[会传给谁什么讯息]
- 工作请求：[会在共享工作清单请求哪种类型的工作]

## 错误处理
- [失败时怎么做]
- [逾时时怎么做]

## 协作
- 与其他 agent 的关系
```

## agent 拆分标准

| 标准 | 拆分 | 整合 |
|------|------|------|
| 专业性 | 领域不同就拆分 | 领域重叠就整合 |
| 平行性 | 能独立执行就拆分 | 若有顺序依赖则考虑整合 |
| context | context 负担大就拆分 | 若轻量且快速可整合 |
| 可重用性 | 若其他 team 也会用就拆分 | 若只在本 team 使用可考虑整合 |

## 区分 skill 与 agent

| 区分 | Skill | Agent |
|------|-------|-------|
| 定义 | 程序性知识 + 工具 bundle | 专家 persona + 行为原则 |
| 位置 | `.claude/skills/` | `.claude/agents/` |
| 触发方式 | 使用者请求关键字比对 | 透过 Agent 工具明确呼叫 |
| 大小 | 小到大皆可（workflow） | 较小（角色定义） |
| 用途 | 「怎么做」 | 「谁来做」 |

skill 是 agent 执行工作时参考的 **程序性指南**。  
agent 是活用 skill 的 **专家角色定义**。

## skill ↔ agent 的连结方式

agent 使用 skill 的 3 种方式：

| 方式 | 实作 | 适合情境 |
|------|------|-----------|
| **呼叫 Skill 工具** | 在 agent prompt 中明示 `Skill 工具呼叫 /skill-name` | skill 是可独立执行的 workflow，且也可能被使用者直接呼叫 |
| **直接内嵌于 prompt** | 直接把 skill 内容放进 agent 定义 | skill 很短（50 行以下），且只供这个 agent 使用 |
| **载入 reference** | 需要时以 `Read` 载入 skill 的 references/ 档案 | skill 内容较大，且只在特定条件下需要 |

建议：可重用性高就用 Skill 工具、专属用途就内嵌、大型内容就用 reference 载入。
