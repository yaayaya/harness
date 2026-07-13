# 贡献 Harness

感谢你考虑为 **Harness** 贡献内容。Harness 是一个为 Claude Code 设计、能建立 agent team 并生成 skill 的 meta-skill factory。

本文涵盖：回应 SLA、如何参与、开发环境设定、PR 惯例、commit 讯息规则、行为准则与维护者名单。

---

## 回应 SLA（服务承诺）

以下是此 repository 维护者的回应目标。这些数字采保守估计，让小型维护团队在专案成长时也能维持。

| 项目 | 目标 | 说明 |
|------|------|------|
| PR 首次回应 | **< 72h** | 以工作日计算。所谓「首次回应」至少包含加上 label 与一则确认已收到 PR 的留言。 |
| Issue triage 与标记 | **< 48h** | 每个新 issue 会在 48 小时内移除 `needs-triage`，并补上类型标签（`bug` / `enhancement` / `question` / `discussion`）。 |
| Bug 修复（P0 / P1） | **< 14d** | P0 = 资料遗失 / 安全问题 / 安装失败；P1 = 常见使用路径故障。P2 / P3 会纳入 roadmap，但不承诺硬性 SLA。 |
| 安全通报 | **< 7d** | 7 天内给出初步确认。修补目标为 30 天内。私下通报方式请见下方 **Security** 章节。 |
| 发版频率 | **每两周一次** | 原则上每两周打一个 tag；若没有可发布内容则略过。P0 问题可能会插入非排程的 patch release。 |

若我们未达成 SLA，欢迎你在 issue / PR 里提醒，这不是失礼，而是约定好的回馈机制。

---

## 如何贡献

不同类型的贡献适合走不同入口，请选择最符合你情况的方式。

### Bug 回报

- 请使用 **Bug report** 表单建立 issue（`.github/ISSUE_TEMPLATE/bug_report.yml`）。
- 必填资讯：Claude Code 版本、`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` flag 状态、重现步骤、预期结果与实际结果、作业系统。
- 若能提供小型重现案例（少于 30 行）最好。若需要完整专案，请附上公开 fork 连结。

### 功能请求

- 请使用 **Feature request** 表单建立 issue。
- 至少需要一段简短说明：「这要解决什么问题？」如果你已有提案，建议整理成接近可 PR 的形式，例如：它是延伸还是取代 6 种 team-architecture pattern 的哪一种？

### 问题

- 请使用 **Question** 表单建立 issue，**或** 若议题较开放，可改在 [GitHub Discussions](https://github.com/revfactory/harness/discussions) 开讨论串。

### 讨论（接近 RFC 规模的想法）

- 优先使用 GitHub Discussions。等方向大致有共识后，再转成 issue。

### Pull Request

- 请参考下方 **Pull Request Guidelines**。
- 小型 PR 会更快合并。差异行数超过 400 行的 PR，通常应该先有一篇 Discussion。

### Security

- 对于可能被滥用的问题，**不要** 开公开 issue。
- 请寄信到：`robin.hwang@kakaocorp.com`，主旨加上 `[harness-security]`。
- 我们目标是在 7 天内回复（详见上方 SLA 表）。

---

## 开发环境设定

### 先决条件

- Claude Code `v2.x`（需要 Agent Teams API）
- Node.js `>= 18`（供 CI 使用的本地工具）
- Git

### 环境旗标

Harness 目前需要 Claude Code 的实验性 Agent Teams 功能。请在 shell profile 或个别 session 中设定：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

此相依性记录于 `docs/experimental-dependency.md`。若 Anthropic 将该 flag 升级为正式功能，我们会依上述 SLA 在 72 小时内更新 README。

### 本地外挂连结

若你想在不发布到 marketplace 的情况下，于本地 Claude Code session 测试变更，可使用：

```bash
# 在你的 checkout 目录执行
claude plugin link ./harness

# 验证
claude plugin list | grep harness
```

完成后可用 `claude plugin unlink harness` 解除连结。

### 执行 meta-skill

```bash
claude "build a harness for a fintech risk-assessment team"
```

生成出的 agent 与 skill 会位于目标专案的 `.claude/agents/` 与 `.claude/skills/`。

### 测试与 lint

- Markdown lint：`npx markdownlint '**/*.md'`
- YAML lint（issue template 与 workflow）：`npx yaml-lint .github/`
- Skill metadata 验证：`python scripts/validate_skills.py`（若存在）

CI 会在每个 PR 上执行这些检查。鼓励本地先跑，但不是硬性要求；若 CI 抓到的是可在 merge 前轻松修正的小问题，我们不会因此卡住合并流程。

---

## Pull Request 指南

### 分支命名

请使用 `type/short-description` 的格式：

| 前缀 | 用途 | 范例 |
|------|------|------|
| `feat/` | 新增使用者可见功能 | `feat/expert-pool-variance-mode` |
| `fix/` | 修 bug | `fix/agent-teams-flag-detection` |
| `docs/` | 仅文件修改 | `docs/quickstart-gemini-section` |
| `refactor/` | 内部结构调整，无行为变更 | `refactor/skill-loader-split` |
| `chore/` | 建置、依赖、杂务 | `chore/upgrade-markdownlint` |
| `test/` | 仅测试 | `test/fan-out-fan-in-e2e` |

### Commit 讯息语言

- **韩文与英文都可以接受。** 使用你能表达得最精准的语言。
- 若这次变更会出现在 CHANGELOG 或 release note 中，请在 PR 说明中另外提供英文标题，方便下游读者理解。

### PR 范本

每个 PR 会自动套用 `.github/PULL_REQUEST_TEMPLATE.md`。请完整填写：

- **Summary**（做了什么、为什么做，2–4 句）
- **Motivation**（连结 issue、引用研究，或给一段简短理由）
- **Scope of change**（本次涉及哪些范围的勾选清单）
- **Tests**（你执行或新增了哪些测试）
- **CHANGELOG**（是否更新 `CHANGELOG.md`？Y / N / NA）
- **SemVer impact**（patch / minor / major，请见下节）

### Review 期望

- 至少需要一位 maintainer 核准。
- 我们会尽量在 72 小时内对 PR 做出回应（详见 SLA）。若你被卡住了，可以提醒。

---

## Commit 讯息惯例

我们采用一个较轻量的 **Conventional Commits** 变体，并直接对应到 SemVer。

```text
<type>(<scope>)!: <short summary>

<body — optional>

<footer — optional>
```

### 类型与 SemVer 对应

| Commit 类型 | SemVer 影响 | 范例 |
|-------------|-------------|------|
| `feat!:` 或 footer 出现 `BREAKING CHANGE:` | **major**（例如 1.x → 2.0） | `feat!: rename primary pattern "Supervisor" → "Orchestrator"` |
| `feat:` | **minor**（例如 1.2 → 1.3） | `feat: add Producer-Reviewer variance metric` |
| `fix:` | **patch**（例如 1.2.3 → 1.2.4） | `fix: correct flag detection on zsh` |
| `docs:` / `chore:` / `refactor:` / `test:` | 不提升版本 | `docs: clarify Gemini roadmap` |

- 其他语言摘要也可以，例如：`feat: 为 Expert Pool 模式加入变异度指标`
- `!` 后缀（或 `BREAKING CHANGE:` footer）是 **唯一** 的 major version 触发条件，请勿轻率使用。

### Release 标记

- 依照 SLA，每两周发一次 release。
- 在 CI 通过且 `CHANGELOG.md` 已更新后，从 `main` 打 tag。
- Tag 格式为 `vMAJOR.MINOR.PATCH`（例如 `v1.3.0`）。

---

## 行为准则

本专案遵循 **Contributor Covenant v1.4**。简单来说：

- 欢迎且包容，并预设他人是善意的。
- 不得骚扰、做人身攻击、使用歧视性语言。
- 批评的是想法，不是人；尽可能用参考资料支持你的主张。
- 维护者有权调整、编辑或移除违反这些原则的留言 / commit / issue / PR，必要时也可以封锁违规者。

完整内容：<https://www.contributor-covenant.org/version/1/4/code-of-conduct/>

若要私下回报违反行为准则的情况，请寄信到 `robin.hwang@kakaocorp.com`，主旨加上 `[harness-coc]`。

---

## 维护者

| 角色 | 帐号 | 负责领域 |
|------|------|----------|
| Lead maintainer | [@revfactory](https://github.com/revfactory) | 专案方向、发版、最终审查 |
| Contributor | [@hnts03](https://github.com/hnts03) | Skill 范本、韩文文件 |
| Contributor | [@JunghwanNA](https://github.com/JunghwanNA) | Agent 模式、整合测试 |
| Contributor | [@shaun0927](https://github.com/shaun0927) | Tooling、CI、基础设施 |

若你是持续贡献者，之后会列在这里，而不只是一次 PR 就加入。若你想讨论 maintainer 路线，也欢迎在 Discussion 里提出。

---

## 授权

只要你提交贡献，就表示你同意以与本 repository 相同的授权方式授权你的内容（请见 [`LICENSE`](./LICENSE)）。
