# Quickstart — 5 分钟完成你的第一个 Harness

> **时间预算：5 分钟（严格）。** 如果 5 分钟内你还没做到 Step 5，请停下来并提交 issue，这是本文档的 bug，不是你的 bug。

<!-- TODO: Loom embed — 60s screen recording showing Steps 1→5 end-to-end. Replace this comment with the `<iframe>` once recorded. -->

**完成后你会拥有：** 一个可运作的 `.claude/agents/` 目录，内含 3–5 个针对领域特化的 agents，透过一句话 prompt 产生，并可直接拿来执行范例任务。

**开始前请先确认先决条件：**
- Claude Code **v2.x 或更新版本**（`claude --version` 应回传 `2.x` 或更高）
- 能在指令之间保留 `export` 的 shell（bash、zsh 或 fish）
- 可连线到 `github.com` 与 `api.anthropic.com`

---

## Step 1 — 加入 marketplace（60 秒）

```bash
claude plugin marketplace add revfactory/harness
```

**这会做什么：** 注册 `harness` marketplace，让 Claude Code 能发现由 `revfactory` 发布的 plugins。

**预期输出：** `Added marketplace: revfactory/harness`

---

## Step 2 — 安装 plugin 并启用 Experimental 旗标（40 秒）

```bash
claude plugin install harness@harness
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

*(若想让这个旗标在多次 shell session 间持续存在，请把 `export` 那一行加入 `~/.zshrc` 或 `~/.bashrc`。)*

**这会做什么：** 从 `harness` marketplace 安装 `harness` plugin，然后启用 Agent Teams，也就是 harness 用来编排多代理工作流程的 Claude Code API。关于为何需要这个旗标，请参阅 [`docs/experimental-dependency.md`](./experimental-dependency.md)。

**Failure FAQ #1 — `AGENT_TEAMS not found` / teams 无法建立**
**原因：** Claude Code 版本低于 v2.x（Agent Teams 是在 v2.0 才加入）。  
**修正方式：** 执行 `claude --version`。若低于 2.0，请用 `npm i -g @anthropic-ai/claude-code`（或你的发行版安装方式）升级，然后重新执行 Step 2。

---

## Step 3 — 用一句话产生一个 harness（2 分钟）

```bash
claude "build a harness for a fintech risk-assessment team"
```

**这会做什么：** 呼叫 `/harness:harness` meta-skill，分析你的领域描述句，并在目前目录的 `.claude/agents/` 与 `.claude/skills/` 中建立一组专业 agents 与其对应 skills。

**也可以试试这些替代 prompt** — 都可以运作：
- `claude "请帮我为金融科技风险评估团队建立 harness"`
- `claude "build a harness for an e-commerce fraud-detection workflow"`
- `claude "design an agent team for technical due diligence on open-source repos"`

**预期输出：** 画面会先串流显示规划，再确认已写入 3–5 个 agent `.md` 档案及其 skills。

**Failure FAQ #2 — 韩文 prompt 没有回应 / 英文可用但韩文不行**
**原因：** locale 或 tokenizer 路由错误；部分语言版本的触发短语在特定环境下可能比英文更容易失配。  
**修正方式：** 如果非英文 prompt 失败，请改用上面的英文 prompt 重新执行，底层 skill 是相同的。若仍失败，直接跳到 Failure FAQ #3。

---

## Step 4 — 验证产生出的档案（30 秒）

```bash
ls -la .claude/agents/
ls -la .claude/skills/
```

**这会做什么：** 确认 meta-skill 已将档案写入预期位置。

**预期输出：** 每个目录有 3–5 个档案，名称会反映你的领域（例如在 fintech 范例中可能是 `risk-analyst.md`、`compliance-reviewer.md`、`portfolio-monitor.md`）。

**Failure FAQ #3 —「没有产生任何内容」/ 目录是空的**
**原因：** plugin 实际上未安装，或在目前专案中未启用。  
**修正方式：** 执行 `claude plugin list`。若看不到 `harness@harness`，请重做 Step 2。若存在但未启用，请执行 `claude plugin enable harness@harness`，再重做 Step 3。

---

## Step 5 — 让新团队执行一个范例任务（90 秒）

复制一段接近 Jira ticket 风格的真实 prompt，交给你刚建立好的团队：

```bash
claude "Ticket FIN-427: A new corporate customer (mid-cap manufacturer, \$80M revenue, South Korea) has applied for a \$5M working-capital line. Produce a risk assessment covering (1) credit-history red flags, (2) sector concentration vs. our existing book, (3) regulatory exposure (KFTC, FSC). Output: a 1-page memo with a go/no-go recommendation."
```

**这会做什么：** Claude Code 会侦测 `.claude/agents/` 中的新 agents，把任务路由到 harness 产生的 team pattern（做风险工作时通常是 Producer-Reviewer 或 Expert Pool），并回传结构化 memo。

**Failure FAQ #4 —「团队没有执行 / 只有一个 agent 回应」**
**原因：** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 只在执行 Step 3 的 shell 中设定，但执行 Step 5 的 shell 没有设定（常见于新开 terminal）。  
**修正方式：** 在目前 shell 重新执行 `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`，然后重跑 Step 5。若要永久生效，请把这一行加入你的 shell rc 档。

**Failure FAQ #5 —「API 呼叫太多 / 很担心成本」**
**原因：** 多代理团队可能会对单一任务平行展开 5 次以上 Claude 呼叫。一张复杂 ticket 可能消耗 50K–200K tokens。  
**修正方式：** 每次执行只跑单一任务（不要用 `&&` 连锁多次 harness 呼叫）；若你的 Claude Code 版本支援，可使用 `--max-turns` 旗标。正式环境中，建议在 harness 呼叫外再包一层具成本意识的 wrapper，请参见 `docs/cost-controls.md` *(forthcoming)*。

---

## 你完成了

此时你应该已经拥有：

- [x] 一个包含领域特化 agents 的 `.claude/agents/` 目录
- [x] 一个包含其支援 skills 的 `.claude/skills/` 目录
- [x] 至少一次成功的范例任务执行
- [x] 一个可运作的 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 环境

**接下来可阅读：**
- [`docs/experimental-dependency.md`](./experimental-dependency.md) — 为何需要此旗标，以及它变动时我们会怎么做
- [`revfactory/harness-100`](https://github.com/revfactory/harness-100) — 100+ 个预先建立好的领域 harness 目录，如果你想直接 clone 而不是自行产生
- [`revfactory/claude-code-harness`](https://github.com/revfactory/claude-code-harness) — 我们用来在 15 个任务上测得 +60% 品质的 A/B test harness

**如果你遇到本指南未涵盖的情况：** 请用 `quickstart-gap` label 开 issue，并附上：(a) 失败的是哪一步，(b) `claude --version`，(c) 完整错误讯息。`quickstart-gap` issue 的 SLA 是 **48 小时内**首次回复（见 `CONTRIBUTING.md`）。
