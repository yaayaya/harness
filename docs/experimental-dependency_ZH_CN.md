# Experimental Flag 相依性

> **状态：** 启用中 · **负责人：** revfactory · **最后更新：** 2026-04-18 · **SLA：** 请参阅[监控承诺](#监控承诺)

本文件说明为何 `harness` 需要 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`、此旗标可能出现的三种合理未来情境，以及本储存库在各情境下将采取的对应措施，并搭配有时限的承诺，方便企业采用者据以规划。

---

## 目前状态

### 为什么需要这个旗标

`harness` 是建立在 Claude Code **Agent Teams API** 之上的 meta-skill 工厂。每当使用者执行 `claude "build a harness for <domain>"` 时，Claude Code 内部都会呼叫三个原语：

| 原语 | 用途 | 受旗标控管？ |
|-----------|---------|-------------|
| `TeamCreate` | 建立具有共享上下文的多代理团队 | **是** |
| `SendMessage` | 在团队成员之间路由讯息（supervisor ↔ worker） | **是** |
| `TaskCreate` | 在团队内建立长时间执行的子任务 | **是** |
| `Agent` tool (invoke) | 单代理派送 | 否（GA） |

上述三个受旗标控管的原语都需要：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

如果在启动 `claude` 的 shell 中没有设定这个变数，harness 产生的团队就会退回单代理执行，并且悄悄破坏 Pipeline / Fan-out-in / Supervisor / Hierarchical Delegation 这些模式。

### Anthropic 参考资料（提交 issue 前请先阅读）

这个旗标的设计理由与发展路线图，记录在三篇 Anthropic Engineering 文章中。评估是否导入 harness 的使用者，至少应先阅读第一篇：

1. [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — 定义 Anthropic 所背书的「harness」类别，以及长时间执行代理的契约。
2. [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) — 说明 `harness` 所具体化的模式（Pipeline、Producer-Reviewer、Supervisor 等）。
3. [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents) — 可能取代 Experimental 旗标的后续方向（见情境 B）。

---

## 相依关系图

```
harness (v1.2.0)
  └── Agent Teams API (Claude Code)
        ├── TeamCreate            ← EXPERIMENTAL_AGENT_TEAMS=1
        ├── SendMessage           ← EXPERIMENTAL_AGENT_TEAMS=1
        ├── TaskCreate            ← EXPERIMENTAL_AGENT_TEAMS=1
        └── Agent (invoke)        ← GA (flag-independent)
              └── Anthropic Roadmap
                    ├── Scenario A: Flag removed (GA promotion)
                    ├── Scenario B: Managed Agents GA (parallel path)
                    └── Scenario C: Breaking signature change
```

**请由上往下阅读这张图：** harness 依赖 Agent Teams API，Agent Teams API 依赖单一 Experimental 旗标，而这个旗标又受 Anthropic 自身路线图影响。只要任一上游节点改变，本储存库就有责任在下述 SLA 期限内完成调整。

---

## 三种情境

每个情境都列出 **侦测触发条件**（我们如何知道事情发生了）、本储存库承诺的 **T+24h / T+48h / T+72h 行动**，以及每个检查点可见的 **使用者可见产出**。

### 情境 A — 旗标移除（Agent Teams 升级为 GA）

**触发侦测：** Anthropic Claude Code Changelog 发布「Agent Teams is now GA」，**或是** `claude-code` binary 已不再需要 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`（由 [P-13](#) 的 nightly CI 侦测）。

**机率（主观）：** 高 — 上面三篇文章所透露的方向就是这条路。

| 检查点 | 行动 | 产出 |
|------------|--------|----------|
| **T+24h** | 开启 `feat/drop-experimental-flag` 分支。从所有 README / docs / Quickstart 移除 `export` 行。在 `plugin.json` 补上 `claude-code >= X.Y.Z` 的最低版本限制。 | 分支 + PR（draft） |
| **T+48h** | 发布 `docs/migrating-from-experimental.md`。将 `docs/experimental-dependency.md`（本档）标题更新为「自 vX.Y 起不再需要旗标」。钉选 GitHub issue：「Action required: drop the export line」。 | 迁移指南 + 钉选 issue |
| **T+72h** | 发布 **v1.3.0** 版本，内容包含：(a) CHANGELOG 条目，(b) `gh release create` 与迁移说明，(c) HN 后续贴文：「We dropped the experimental flag」。 | `v1.3.0` git tag + GH Release |

**对采用者的影响：** 正面。企业审核阻力下降，因为「不得使用 experimental flags」这个条件将可被满足。对 harness 使用者的程式码不会造成破坏性变更。

---

### 情境 B — Managed Agents 达到 GA（平行路线）

**触发侦测：** Anthropic 发布「[Managed Agents](https://www.anthropic.com/engineering/managed-agents) 已正式可用」，并提供稳定的 `claude-agents` CLI 或 SDK 介面。

**机率（主观）：** 90 天内中高。Managed Agents 是伺服器端执行模型；harness 的用户端团队编排方式**不会**自动转换过去。

| 检查点 | 行动 | 产出 |
|------------|--------|----------|
| **T+24h** | 开启 `feat/managed-agents-compat` PR。新增 `adapters/managed-agents/` 骨架，把 harness 的 6 种 team pattern 对应到 Managed Agents 的呼叫方式。标记不相容的模式（很可能是 Hierarchical Delegation）。 | 相容性 PR（draft） |
| **T+48h** | 在 Dev.to 与 repo 发布文章：**"Harness + Managed Agents: one layer up, not replaced"**。把 harness 重新定位为输出 Managed Agents 设定的**设计期**层，而不是执行期竞争者。 | 共存定位文章 |
| **T+72h** | 发布 `docs/managed-agents-migration.md`，提供逐 pattern 对照矩阵（6 种模式哪些可 1:1 对应、哪些需要改写）。更新 README 中的 sibling-repo 区块。 | 迁移指南 |

**策略说明：** harness 将重新定位为 **Managed Agents 之上的上层**，也就是「Managed Agents 负责执行团队，harness 负责设计团队」。这就是 GTM 计划 §4.2 的共存框架。

**对采用者的影响：** 中性偏正面。现有 harness 使用者可继续沿用 Experimental 旗标路线；新使用者则可选择输出 Managed Agents。

---

### 情境 C — 破坏性变更（API 签章变动）

**触发侦测：** nightly CI（`.github/workflows/nightly-compat.yml`，路线图编号 P-13）在 Claude Code 最新 nightly build 上失败，**或是** Changelog 宣告环境变数改名 / `TeamCreate` 签章变更。

**机率（主观）：** 中等。Experimental API 可能在没有弃用期的情况下被重新命名。

| 检查点 | 行动 | 产出 |
|------------|--------|----------|
| **T+0 到 T+24h** | Nightly CI 警报会送到 Slack/Discord。作者开启 `hotfix/compat-<date>` 分支，修补受影响的呼叫位置。尽最大努力让旧版与新版签章的单元测试都能通过。 | Hotfix 分支 |
| **T+24h** | 合并 hotfix。推送 `v1.2.x` patch tag。更新 `docs/compatibility-matrix.md` 中受影响 Claude Code 版本的对应列。 | `v1.2.x` patch 版本 |
| **T+72h** | 若变更较不单纯（会影响 harness 对外契约），就在 repo 的 Discussions 分页与 X 发布短公告；否则 CHANGELOG 条目即可。 | Discussions 公告（条件式） |

**对采用者的影响：** 锁定旧版 Claude Code 的既有使用者不受影响；使用最新版的使用者会在同一周收到修补版本。

---

## 监控承诺

我们承诺以下**可观察的 SLA**。若未达成，使用者可以 `sla-breach` label 提交 issue。

| 事件 | SLA | 测量方式 |
|-------|-----|-------------|
| Anthropic 在官方 Changelog 发布 Agent Teams / Managed Agents 变更 | 本文件于 **72 小时内**更新 | 比对 Changelog 贴文时间戳与本档 `Last updated` 行 |
| Nightly CI 侦测到相容性中断 | **24 小时内**开出 hotfix 分支 | GitHub Actions 执行时间戳 vs. 分支建立时间戳 |
| 新的 Claude Code 稳定版（minor 或 major）发布 | **7 天内**在 `docs/compatibility-matrix.md` 新增对应列 | Compatibility matrix diff |

**我们主动监控的来源：**

- Claude Code release notes — 透过 [Anthropic Engineering blog](https://www.anthropic.com/engineering) RSS 追踪
- `anthropics/claude-code` GitHub Releases（nightly tag）
- Anthropic Discord `#claude-code` 频道（社群讯号）

---

## 给企业采用者的 FAQ

### Q1. 我们属于受监管产业（金融、医疗、公部门），不能在正式环境启用 `EXPERIMENTAL` 旗标。要如何采用 harness？

**原因：** 许多合规框架（SOC 2 Type II、ISO 27001、K-ISMS）不允许在正式环境使用不稳定 / 预览功能。  
**做法：** 把 harness 只用在**设计期**：在 sandbox 工作站中执行它，来产生 `.claude/agents/` 与 `.claude/skills/` 档案，然后把产出的成品提交到正式 repo。正式环境中的 Claude Code 不需要这个旗标，只有受旗标控管的 `TeamCreate` 执行期才需要。产生出的单代理 skill 与 GA 路径相容。

### Q2. 如果 Agent Teams 之后 GA（情境 A），我现有由 harness 产生的程式码会坏掉吗？

**原因：** 依 Anthropic Claude Code 过往经验，GA 升级通常不会破坏产生出的成品；只是旗标不再需要。  
**做法：** 终端使用者无需采取动作。你的 `.claude/agents/*.md` 与 `.claude/skills/*` 都是纯 Markdown，仍然有效。GA 当天你就能 `unset CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`。我们会在 48 小时内发布迁移说明（见情境 A）。

### Q3. 你们是否提供书面的 SLA 保证？若没做到怎么办？

**原因：** 企业在批准前，通常需要契约化或至少可观察的承诺。  
**做法：** 上述 SLA 表格就是**公开承诺**，并透过以下机制执行：(a) 若在侦测到 Changelog 事件后超过 72 小时仍未更新本档，GitHub Action 会在此文件留言提醒，(b) 采用者可套用 `sla-breach` issue label，(c) 任何违反情况都必须在 `CONTRIBUTING.md` 中进行事后检讨。这不是付费 SLA，而是社群承诺。若需要付费 SLA，请联络维护者（见 repository README）。

---

**相关文件：**
- [`docs/quickstart.md`](./quickstart.md) — 5 分钟安装导览
- [`docs/show-hn-launch-kit.md`](./show-hn-launch-kit.md) — 公开发布套件
- `docs/compatibility-matrix.md` *(pending P-13)* — Claude Code × harness 版本对照表
