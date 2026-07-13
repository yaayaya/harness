# Orchestrator 技能范本

Orchestrator 是协调整个团队的上层 skill。依照执行模式，提供 3 种范本：

- **范本 A：Agent Team 模式（预设）** - 2 人以上协作时的最优先选择
- **范本 B：Subagent 模式（替代方案）** - 不需要团队通讯时使用
- **范本 C：Hybrid 模式** - 可在各 Phase 间混合不同模式

---

## 范本 A：Agent Team 模式（预设，最优先选择）

当 2 位以上 agent 协作时，**最先评估的预设模式**。使用 `TeamCreate` 建立团队，并透过共享工作清单与 `SendMessage` 进行协调。

```markdown
---
name: {domain}-orchestrator
description: "{领域} Agent Team 的协调 orchestrator。{初次执行关键字}。后续工作：当请求修改 {领域} 结果、局部重跑、更新、补强、重新执行，或改善先前结果时，也一定要使用这个 skill。"
---

# {Domain} Orchestrator

协调 {领域} 的 Agent Team，产出 {最终产出物} 的整合 skill。

## 执行模式：Agent Team

## Agent 组成

| 团队成员 | Agent 类型 | 角色 | Skill | 输出 |
|------|-------------|------|------|------|
| {teammate-1} | {自订或内建} | {角色} | {skill} | {output-file} |
| {teammate-2} | {自订或内建} | {角色} | {skill} | {output-file} |
| ... | | | | |

## 工作流程

### Phase 0: 确认 context（支援后续工作）

确认是否已有既有产出物，并据此决定执行模式：

1. 确认 `_workspace/` 目录是否存在
2. 决定执行模式：
   - **`_workspace/` 不存在** → 初次执行。进入 Phase 1
   - **`_workspace/` 存在 + 使用者要求局部修改** → 局部重跑。只重新呼叫对应的 agent，并且只覆写既有产出中需要修改的部分
   - **`_workspace/` 存在 + 提供了新的输入** → 全新执行。先将既有 `_workspace/` 移到 `_workspace_{YYYYMMDD_HHMMSS}/`，再进入 Phase 1
3. 局部重跑时：在 agent prompt 中附上先前产出物的路径，指示 agent 读取既有结果并反映回馈

### Phase 1: 准备
1. 分析使用者输入 — {要厘清的内容}
2. 在工作目录中建立 `_workspace/`
   - **初次执行**：建立新的 `_workspace/`
   - **全新执行**：将既有 `_workspace/` 移到 `_workspace_{YYYYMMDD_HHMMSS}/` 后，重新建立新的 `_workspace/`
3. 将输入资料存入 `_workspace/00_input/`

### Phase 2: 建立团队

1. 建立团队：
   ```
   TeamCreate(
     team_name: "{domain}-team",
     members: [
       { name: "{teammate-1}", agent_type: "{type}", model: "opus", prompt: "{角色说明与工作指示}" },
       { name: "{teammate-2}", agent_type: "{type}", model: "opus", prompt: "{角色说明与工作指示}" },
       ...
     ]
   )
   ```

2. 注册任务：
   ```
   TaskCreate(tasks: [
     { title: "{任务1}", description: "{细节}", assignee: "{teammate-1}" },
     { title: "{任务2}", description: "{细节}", assignee: "{teammate-2}" },
     { title: "{任务3}", description: "{细节}", depends_on: ["{任务1}"] },
     ...
   ])
   ```

   > 每位团队成员分配 5 到 6 个任务最合适。有依赖关系的任务请用 `depends_on` 明确标示。

### Phase 3: {主要工作，例如：研究 / 生成 / 分析}

**执行方式：** 团队成员自行协调

团队成员从共享任务清单中认领工作（claim），并各自独立执行。
Leader 监控进度，必要时再介入。

**团队成员间的通讯规则：**
- {teammate-1} 透过 SendMessage 将 {某些资讯} 传给 {teammate-2}
- {teammate-2} 完成任务后，将结果存成档案并通知 Leader
- 若团队成员需要其他成员的结果，就用 SendMessage 发出请求

**产出物储存：**

| 团队成员 | 输出路径 |
|------|----------|
| {teammate-1} | `_workspace/{phase}_{teammate-1}_{artifact}.md` |
| {teammate-2} | `_workspace/{phase}_{teammate-2}_{artifact}.md` |

**Leader 监控：**
- 团队成员进入闲置状态时，自动接收通知
- 特定成员卡住时，用 SendMessage 下达指示或重新分派任务
- 用 TaskGet 确认整体进度

### Phase 4: {后续工作，例如：验证 / 整合}
1. 等待所有团队成员完成任务（用 TaskGet 确认状态）
2. 用 Read 收集各成员的产出物
3. {整合 / 验证逻辑}
4. 生成最终产出物：`{output-path}/{filename}`

### Phase 5: 收尾
1. 向团队成员发送结束请求（SendMessage）
2. 清理团队（TeamDelete）
3. 保留 `_workspace/` 目录（不要删除中间产出物，供后续验证与稽核追踪）
4. 向使用者回报结果摘要

> **若需要重组团队：** 如果不同 Phase 需要不同的专家组合，先用 TeamDelete 清理目前团队，再用新的 TeamCreate 为下一个 Phase 组队。前一个团队的产出物会保留在 `_workspace/`，因此新团队可以透过 Read 存取。

## 资料流

```
[Leader] → TeamCreate → [teammate-1] ←SendMessage→ [teammate-2]
                          │                           │
                          ↓                           ↓
                    artifact-1.md              artifact-2.md
                          │                           │
                          └───────── Read ────────────┘
                                     ↓
                              [Leader: 整合]
                                     ↓
                              最终产出物
```

## 错误处理

| 情况 | 策略 |
|------|------|
| 1 位团队成员失败 / 中止 | Leader 侦测到后 → 用 SendMessage 确认状态 → 重新启动或建立替代成员 |
| 超过半数团队成员失败 | 告知使用者并确认是否继续 |
| Timeout | 使用目前为止已收集的部分结果，并结束未完成的成员 |
| 团队成员之间资料冲突 | 标明来源后并列保留，不删除 |
| 任务状态延迟 | Leader 用 TaskGet 确认后，手动执行 TaskUpdate |

## 测试情境

### 正常流程
1. 使用者提供 {输入}
2. 在 Phase 1 得出 {分析结果}
3. 在 Phase 2 建立团队（{N} 位成员 + {M} 个任务）
4. 在 Phase 3 由团队成员自行协调并执行工作
5. 在 Phase 4 整合产出物并生成最终结果
6. 在 Phase 5 清理团队
7. 预期结果：产生 `{output-path}/{filename}`

### 错误流程
1. 在 Phase 3 中，{teammate-2} 因错误而中止
2. Leader 收到闲置通知
3. 用 SendMessage 确认状态 → 尝试重新启动
4. 若重启失败，将 {teammate-2} 的工作改派给 {teammate-1}
5. 以其余结果进入 Phase 4
6. 在最终报告中注明「{teammate-2} 区块部分资料未收集」
```

---

## 范本 B：Subagent 模式（替代方案）

适用于不需要团队通讯成本的情况。直接使用 `Agent` 工具呼叫，并从回传值搜集结果。

```markdown
---
name: {domain}-orchestrator
description: "{领域} agent 的协调 orchestrator。{初次执行关键字}。包含后续工作关键字。"
---

## 执行模式：Subagent

## Agent 组成

| Agent | subagent_type | 角色 | Skill | 输出 |
|---------|--------------|------|------|------|
| {agent-1} | {内建或自订} | {角色} | {skill} | {output-file} |
| {agent-2} | ... | ... | ... | ... |

## 工作流程

### Phase 0: 确认 context
（与 Template A 相同，依 `_workspace/` 是否存在分流）

### Phase 1: 准备
1. 分析输入
2. 建立 `_workspace/`（初次执行时建立，或在全新执行时先将既有 `_workspace/` 移到封存目录后再建立）

### Phase 2: 平行执行
在单一讯息中同时呼叫 N 个 Agent 工具：

| Agent | 输入 | 输出 | model | run_in_background |
|---------|------|------|-------|-------------------|
| {agent-1} | {来源} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |
| {agent-2} | {来源} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |

### Phase 3: 整合
1. 收集各 agent 的返回值
2. 对于档案型产出物，用 Read 收集
3. 套用整合逻辑 → 产生最终产出物

### Phase 4: 收尾
1. 保留 `_workspace/`
2. 回报结果摘要

## 错误处理
- 1 个 agent 失败：重试 1 次。若再次失败，标明缺漏后继续
- 超过半数失败：告知使用者并确认是否继续
- Timeout：使用目前为止已收集的部分结果
```

---

## 范本 C：Hybrid 模式

在不同 Phase 使用不同执行模式。需在各 Phase 标题上方标注 `**执行模式:** {团队 | 子代理}`。

```markdown
---
name: {domain}-orchestrator
description: "{领域} orchestrator（Hybrid）。{关键字}。包含后续工作关键字。"
---

## 执行模式：Hybrid

| Phase | 模式 | 原因 |
|-------|------|------|
| Phase 2（平行收集） | Subagent | 独立收集资料，不需要团队通讯 |
| Phase 3（共识整合） | Agent Team | 需要讨论与协调相互冲突的资料 |
| Phase 4（独立验证） | Subagent | 由 1 位 QA agent 进行客观验证 |

## 工作流程

### Phase 2: 平行收集资料
**执行模式：** Subagent

在单一讯息中用 Agent 工具平行呼叫 N 个 agent（`run_in_background: true`）。
各结果存到 `_workspace/02_{agent}_raw.md`。

### Phase 3: 以共识为基础的整合
**执行模式：** Agent Team

1. 用 `TeamCreate` 建立整合团队（editor + fact-checker + synthesizer）
2. 用 `TaskCreate` 分派任务，所有人都 Read Phase 2 的 `_workspace/02_*` 档案
3. 团队成员透过 `SendMessage` 讨论互相冲突的资料，并以档案为基础整理出共识版本
4. 生成最终整合版 `_workspace/03_integrated.md`
5. 用 `TeamDelete` 清理团队

### Phase 4: 独立验证
**执行模式：** Subagent

由单一 QA subagent 读取 `_workspace/03_integrated.md` 作为输入，产生验证报告。
```

**Hybrid 切换规则：**
- 团队 → 子代理：一定要先用 `TeamDelete` 清理团队，再呼叫 Agent 工具
- 子代理 → 团队：将 subagent 的档案产出透过 Read 路径提供给团队成员
- 团队 → 团队：整理旧团队后，再 `TeamCreate` 新团队（每个 session 同时只能启用 1 个团队）

---

## 撰写原则

1. **先明确标示执行模式** - 在 orchestrator 开头标明「Agent Team」/「Subagent」/「Hybrid」其中之一。若是 Hybrid，必须提供各 Phase 模式表
2. **团队模式需具体说明 TeamCreate/SendMessage/TaskCreate 用法** - 包含团队组成、任务注册、通讯规则
3. **Subagent 模式需完整标示 Agent 工具参数** - name、subagent_type、prompt、run_in_background、model
4. **档案路径必须明确** - 禁止相对路径，需清楚以 `_workspace/` 为基准
5. **标示 Phase 间依赖关系** - 说明哪个 Phase 依赖哪个 Phase 的结果。Hybrid 尤其要强调模式切换点
6. **Error handling 要务实** - 不要假设「所有事情都会成功」
7. **必须提供测试情境** - 至少 1 个正常流程 + 1 个错误流程

## 撰写 description 时的后续工作关键字

Orchestrator 的 description 不能只写初次执行关键字。必须包含以下后续工作表达：

- 重新执行／再次执行／更新／修改／补强
- 「只重做 {domain} 的 {部分}」
- 「基于先前结果」、「改善结果」
- 与 domain 相关的日常请求（例如 launch strategy harness 可包含「launch」、「promotion」、「trending」等）

如果没有后续关键字，第一次执行后这个 harness 实际上就会变成 dead code。

## 实际 Orchestrator 参考

Fan-out/Fan-in pattern 的 orchestrator 基本结构：
准备 → Phase 0（确认 context）→ TeamCreate + TaskCreate → N 位团队成员平行执行 → Read + 整合 → 收尾。
请参考 `references/team-examples.md` 中的 research team 范例。
