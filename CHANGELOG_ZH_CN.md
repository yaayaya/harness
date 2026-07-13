# 变更纪录

本专案遵循 [Semantic Versioning](https://semver.org/)。

## [1.2.1] - 2026-04-18

### 修正

- **版本一致性同步** — `README.md` / `README_KO.md` / `README_JA.md` 的 badge 显示 `v1.0.1`、`.claude-plugin/marketplace.json` 为 `1.1.0`、`.claude-plugin/plugin.json` 为 `1.2.0`，原本共有三处版本不一致；现已全部统一为 **v1.2.0**（以 `plugin.json` 为准）
- **为解决「尚无 tagged release」状态预作准备** — 制定 `v1.0.0` / `v1.0.1` / `v1.1.0` / `v1.2.0` 的补标签计划（请参考 `_workspace/release/audit-2026-04-18.md` 第 4 节）

### 新增

- **定位宣告："harness factory"** — 在 README 顶部加入类别自我定义文字，强调这是一个「能依领域产出 agent 与 skill 的 harness factory」，以便与单一 agent / prompt framework 做出区隔
- **`CONTRIBUTING.md`** — 新增贡献指南与 SLA，明确标示 PR 首次回应 72 小时内、Issue triage 48 小时内，降低社群参与门槛
- **`docs/` 目录** — 新增长篇文件的放置空间，用于后续存放架构、迁移与模式目录，避免 README 过度膨胀并提升可搜寻性
- **Issue #3 回应政策** — 新增社群议题的正式回应范本与 triage 流程

### 变更

- `.claude-plugin/marketplace.json` 版本：`1.1.0` → `1.2.0`
- README badge（EN/KO/JA 三个版本）：`Version-1.0.1` → `Version-1.2.0`
- **重写 `.claude-plugin/plugin.json` 的 description** — 从 `"Agent Team & Skill Architect — Meta-skill that designs..."` 改为 `"The team-architecture factory for Claude Code — a meta-skill that turns a domain description into an agent team and the skills they use, with six pre-defined team-architecture patterns..."`（英韩并列，反映 L3 Meta-Factory 定位）
- **扩充 `.claude-plugin/plugin.json` 的 keywords** — 从 5 个增加到 17 个，新增 `harness-factory`、`team-architecture-factory`、`claude-code-plugin`、`agent-scaffolding`、`multi-agent` 以及 6 种模式相关关键字

## [1.2.0] - 2026-04-08

### 变更

- **简化 `CLAUDE.md` 注册政策（去除重复）** — 将 Phase 5-4 的「上下文注册」改为「指标注册」，从 `CLAUDE.md` 中移除 agent 清单、skill 清单、目录结构与执行规则细节，只保留 **触发规则与变更历史**。agent / skill 清单改由 `.claude/agents/`、`.claude/skills/` 与 orchestrator skill 作为单一来源
- **移除 Phase 3/4 的临时同步步骤** — 为减少 `CLAUDE.md` 的同步负担，删除 Phase 3/4 中的临时同步指示，最终的指标注册仅在 Phase 5-4 进行一次
- **重新定义第 3 条核心原则** — 从「在 `CLAUDE.md` 注册 harness 上下文」改为「在 `CLAUDE.md` 注册 harness 指标」
- **删除 `CLAUDE.md` 与 orchestrator 的角色分工表** — 由于指标政策已简化，该表不再必要

### 新增

- **Phase 2-1：混合执行模式** — 除了 Agent Teams / Subagents 外，新增可按阶段混用模式的 hybrid pattern，并明示常见组合（平行搜集 → 共识整合、先建团队 → 再验证、各 Phase 重组团队）
- **Phase 2-1 执行模式比较表** — 提供 Team / Subagent / Hybrid 三者特性与三步骤决策顺序
- **Phase 5-0 混合式 orchestrator pattern** — 规定在 hybrid 配置下，需于各 Phase 开头标示执行模式
- **Phase 5-1 基于回传值的资料传递** — 为 Subagent 模式新增回传值导向的资料传递策略（在原有讯息 / task / 档案传递之外）
- **Phase 5-1 建议组合（Subagent / Hybrid）** — 明列非 Team 模式下的资料传递建议组合

## [1.1.0] - 2026-04-05

### 新增

- **Phase 0：现况稽核** — 触发时先检查现有 harness 状态，再分流到新建、既有扩充或营运维护三种情境
- **既有扩充的 Phase 选择矩阵** — 依 agent 新增、skill 新增、架构变更，提供所需 Phase 的决策表
- **Phase 3/4 `CLAUDE.md` 临时同步** — 在 agent / skill 生成后立即写回 `CLAUDE.md`，提升中断恢复能力
- **Phase 5-4：于 `CLAUDE.md` 注册 harness 上下文** — 记录 agent team 结构、skill 清单、执行规则、目录结构与变更历史，并包含 `CLAUDE.md` 与 orchestrator 的角色分工表
- **Phase 5-5：支援后续工作** — 要求 orchestrator description 必须包含后续工作关键字，并透过 Phase 0 判别初次执行、局部重跑与新一轮执行
- **Phase 5 orchestrator 修改路径** — 在既有扩充情境下，提供修改既有 orchestrator 而非重建的指南
- **Phase 7：Harness 演化机制** — 透过执行后回馈搜集 → 根据回馈类型对应修改对象 → 记录变更历史 → 自动触发演化
- **Phase 7-5：营运 / 维护工作流** — 提供现况稽核 → 渐进式修正 → `CLAUDE.md` 同步 → 变更验证的四步流程
- **description 中新增营运 / 维护触发词** — 例如「harness 点检」、「harness 稽核」、「harness 现况」、「agent/skill 同步」
- **加强产出检查清单** — 新增 `CLAUDE.md` 同步完成、变更历史记录与 Phase 0 上下文确认项目
- 在 orchestrator 范本中加入 Phase 0（上下文确认）— 适用于 Agent Teams 与 Subagent 两种模式
- 在 orchestrator description 范本中加入后续工作关键字规则

### 变更

- 核心原则从 2 条扩充为 4 条（加入 `CLAUDE.md` 注册与演化系统）
- **统一将「evolution log」改称「变更历史」** — 名称与格式（4 栏：日期 / 变更内容 / 对象 / 原因）在所有章节一致
- **Phase 1 Step 3** — 改为依据 Phase 0 的稽核结果进行冲突分析，以避免重复工作
- **5-4 `CLAUDE.md` 范本程式区块** — 修正巢状渲染错误（3 个反引号 → 4 个反引号）
- **扩充角色分工表** — 新增 skill 清单、目录结构与变更历史列
- **orchestrator 范本** — 新增 Phase 0 上下文确认与后续工作关键字指南

## [1.0.1] - 2026-03-28

### 变更

- 移除 `SKILL.md` 与 `references/` 之间的重复内容（330 行 → 285 行）
  - Phase 2-1：将执行模式比较表 / 条列改为核心原则 + `agent-design-patterns.md` 指标
  - Phase 2-3：将 agent 拆分标准条列改为 4 轴摘要 + `agent-design-patterns.md` 指标
  - Phase 3：将 agent 定义范本程式码区块改为必要章节清单 + `references/` 指标
  - Phase 5-2：将错误处理 5 列表格改为核心原则 + `orchestrator-template.md` 指标

## [1.0.0] - 2026-03-27

### 新增

- 基于 6 个 Phase 工作流的 harness 建构 meta-skill
- 6 种 agent 架构模式（Pipeline、Fan-out/Fan-in、Expert Pool、Producer-Reviewer、Supervisor、Hierarchical Delegation）
- 支援 Agent Teams / Subagents 执行模式
- 基于 Progressive Disclosure 的 skill 生成指南
- orchestrator 范本（Agent Teams 模式 + Subagent 模式）
- QA agent 整合指南（根据 7 个真实专案 bug 案例）
- skill 测试 / 评估方法（With-skill 与 Without-skill 比较）
- 5 组实战团队配置范例（研究、小说、Webtoon、程式码审查、迁移）
