# GitHub Trending 整合发布计划 — Harness

> **专案**: Harness — Agent Team & Skill Architect (Claude Code Plugin)
> **GitHub**: https://github.com/revfactory/harness
> **撰写日期**: 2026-03-29
> **发布目标日**: 2026-04-07（星期二）
> **撰写依据**: 综合 repo-auditor、content-creator、community-scout 的产出

---

## 1. 策略摘要

### 目标
- **Primary**: 打进 GitHub Trending（All Languages）Top 25
- **Secondary**: 拿下 GitHub Trending（Markdown / Misc）#1
- **Stretch**: 在 Hacker News Front Page 停留 12 小时以上

### 目标类别
- GitHub Trending: `All Languages` + `Unknown languages`（由于是以 Markdown 为主的 repo，语言分类很可能会被判定为 Unknown/Misc）
- Hacker News: `Show HN`
- Product Hunt: `AI Coding Agents` / `Developer Tools`

### 核心 KPI

| 指标 | D-Day +6h | D-Day +24h | D+3 | D+7 | D+14 |
|------|-----------|------------|-----|-----|------|
| GitHub Stars | 100+ | 300+ | 500+ | 800+ | 1,200+ |
| Star Velocity (stars/h) | 15-20 | 10-15 | 5-8 | 3-5 | 2-3 |
| Forks | 10+ | 30+ | 50+ | 80+ | 120+ |
| HN Points | 50+ | 100+ | — | — | — |
| Twitter Impressions | 10k+ | 50k+ | 100k+ | — | — |

### 发布日期选择依据
- **选定星期二（2026-04-07）**
  - 周二到周四是最适合打进 GitHub Trending 的日期区间（可在周末流量下滑前先建立动能）
  - 排除星期一：周初工作量较高，开发者注意力分散
  - 与 HN 最佳发文时段相比，星期二最吻合
  - D-7 = 3/31（星期二），准备期以平日为主，作业效率较高

---

## 2. D-7 ~ D-1：Pre-Launch Prep

### D-7（3/31 周二）— Repo 核心最佳化

| # | 动作 | 依据 | 完成标准 | 时间 |
|---|------|------|-----------|------|
| 1 | **建立 GitHub Releases**（v1.0.0, v1.0.1） | Audit R4 — 侧边栏信任讯号，ROI 最高 | Release 页面可看到 2 个 release，包含 CHANGELOG 内容 | 30 分钟 |
| 2 | **设定 GitHub Topics** | Audit R9 — 搜寻 / Explore 曝光关键 | 完成设定 `claude-code`, `claude-code-plugin`, `agent-team`, `ai-agent`, `llm`, `skill-generation`, `orchestration`, `claude` | 10 分钟 |
| 3 | **设定 Repo Description** | Audit R13 — 搜寻结果曝光最佳化 | "Agent Team & Skill Architect — A Claude Code Plugin that designs domain-specific agent teams and generates skills" | 5 分钟 |
| 4 | **上传 Social Preview 图片** | Audit R14 — 社群分享时的视觉冲击 | 完成上传 1280×640px OG 图片 | 30 分钟 |
| 5 | **部署 GitHub Pages** | Audit R12 — 上线 landing page + 信任讯号 | 可连上 `revfactory.github.io/harness` | 20 分钟 |
| 6 | **在 Repo About 设定网站 URL** | Audit R15 | 连结到 Pages URL | 5 分钟 |

**D-7 所需时间**: 约 2 小时
**D-7 效果**: Score 5.5 → 7.0（Discoverability 大幅提升）

### D-6（4/1 周三）— 社群基础建设

| # | 动作 | 依据 | 完成标准 | 时间 |
|---|------|------|-----------|------|
| 7 | **新增 Issue Templates**（`bug_report.yml`, `feature_request.yml`） | Audit R5 | `.github/ISSUE_TEMPLATE/` 内有 2 个档案 | 30 分钟 |
| 8 | **新增 PR Template** | Audit R6 | 建立 `.github/PULL_REQUEST_TEMPLATE.md` | 15 分钟 |
| 9 | **撰写 CONTRIBUTING.md** | Audit R7 — 吸引新访客参与的关键 | 包含 bug report、PR guide、开发环境区段 | 30 分钟 |
| 10 | **新增 CODE_OF_CONDUCT.md** | Audit R8 | 套用 Contributor Covenant 范本 | 10 分钟 |
| 11 | **将 README 的 "Quick Start" 区段重新命名** | Audit R2 | 安装区段 → "Quick Start"（≤5 步，第一步为 one-liner） | 15 分钟 |
| 12 | **在 README 新增 "Contributing" 区段** | Audit R3 | 包含 CONTRIBUTING.md 连结 | 10 分钟 |

**D-6 所需时间**: 约 2 小时
**D-6 效果**: Score 7.0 → 7.5（Repo Structure 大幅改善）

### D-5（4/2 周四）— 信任讯号与 CI

| # | 动作 | 依据 | 完成标准 | 时间 |
|---|------|------|-----------|------|
| 13 | **新增 GitHub Actions CI workflow** | Audit R10 — 绿色 CI badge 是强力信任讯号 | Markdown lint + plugin.json 验证 + 在 README 加上 badge | 1 小时 |
| 14 | **新增基本有效性验证测试** | Audit R11 | plugin.json schema 验证、确认 `SKILL.md` 存在、验证 references 目录 | 1 小时 |

**D-5 所需时间**: 约 2 小时
**D-5 效果**: Score 7.5 → 8.0（Trust Signals 显著改善）

### D-4（4/3 周五）— 内容准备与前期关系建立

| # | 动作 | 分类 | 完成标准 | 时间 |
|---|------|------|-----------|------|
| 15 | **制作 Demo GIF/Screencast** | Audit R1 — 对 3 秒判断至关重要 | 执行 "build a harness" → 显示 Agent Team 生成过程的 30-60 秒 GIF | 2 小时 |
| 16 | **将 Demo GIF 放到 README 顶部** | | 放在 tagline 正下方 | 15 分钟 |
| 17 | **准备 3-4 张 Twitter/X thread 图片** | Content #3 | workflow diagram、A/B 结果图表、architecture pattern cards | 1 小时 |
| 18 | **最终校对所有内容文字** | | 检查 HN/Reddit/Twitter/Dev.to 草稿的文法与连结 | 30 分钟 |
| 19 | **开始联系 Product Hunt hunter** | Scout — PH 发布必备 | 私讯 2-3 位 hunter，分享预计发布日期 | 30 分钟 |
| 20 | **预先私讯 influencer** | Scout Tier 1 KOL | 向 Nick Saraev、Boris Cherny 传送事前介绍讯息 | 30 分钟 |

**D-4 所需时间**: 约 5 小时（工作量最大的一天）

### D-3 ~ D-2（4/4~4/5 周六~周日）— 最终检查与支持者准备

| # | 动作 | 完成标准 | 时间 |
|---|------|-----------|------|
| 21 | **确认 harness-100 repo 已公开** | README 已整理，连结可正常运作 | 30 分钟 |
| 22 | **确认 claude-code-harness（研究 repo）已公开** | 可存取 A/B 测试资料 / 论文 | 30 分钟 |
| 23 | **建立初期支持者群组** | 邀请 5-10 位同事 / 熟人于发布日协助 star/upvote。考量时区，确保可在 KST 晚间~夜间时段参与的人数 | 1 小时 |
| 24 | **预先准备 HN 常见问题回答** | 关于方法论限制、与其他工具比较、可否泛化等，先拟 5-7 组 Q&A | 1 小时 |
| 25 | **确认 Anthropic Discord 帐号活跃状态** | 确认可进入 #showcase 频道 | 15 分钟 |

### D-1（4/6 周一）— 最终彩排

| # | 动作 | 完成标准 | 时间 |
|---|------|-----------|------|
| 26 | **最终检查整体 checklist**（参见 Section 8） | 所有 Pre-Launch 项目皆已勾选 | 30 分钟 |
| 27 | **最终确认 GitHub Pages 已上线** | landing page 可开启 + 多语切换正常 | 10 分钟 |
| 28 | **把各平台发文内容复制到文字编辑器** | 完成复制贴上准备（避免格式跑掉） | 20 分钟 |
| 29 | **更新 Twitter 个人简介** | 加入 Harness 说明 | 5 分钟 |
| 30 | **设定闹钟** | D-Day 起床闹钟（KST 16:00 = UTC 07:00） | 5 分钟 |

---

## 3. D-Day：Launch Execution（4/7 周二）

### 时段策略

核心原则：**美国早晨（UTC 13:00-16:00 = PST 6-9am = EST 9am-12pm）是 HN/Reddit 流量高峰**。但 HN 需要**提早几小时发文，才能让登上 Front Page 的时间点刚好对上高峰**。换算成 KST，就是傍晚到深夜。

| 时间（UTC） | 时间（KST） | 平台 | 动作 | 预期效果 | Plan B |
|-----------|-----------|--------|------|-----------|--------|
| **07:00** | **16:00** | GitHub | 最终确认 README、demo GIF 是否正常 | 基本检查 | — |
| **08:00** | **17:00** | **Hacker News** | 发布 Show HN 贴文（Content #1 文字） | HN New → Rising。透过初期 2-3 个 upvote 进入 Rising | 若发文时机不佳，改在 UTC 12:00 重新发（HN 允许重发） |
| **08:15** | **17:15** | **初期支持者** | 在支持者群组分享 HN 连结 + GitHub 连结 | 初期 5-10 stars + 2-3 HN upvotes（临界动能） | 若支持者不足，动用个人网路补强 |
| **08:30** | **17:30** | **Twitter/X** | 发布发布 thread（Content #3, Tweet 1-9），并将 Tweet 1 置顶 | 追踪者初期 engagement、retweet 扩散 | 若 thread 互动偏低，就把核心推文单独重发 |
| **09:00** | **18:00** | **r/ClaudeAI** | 发布 Reddit 贴文（Content #2a） | 最 receptive 的目标社群，目标 50+ upvotes | 若贴文被删，询问 moderator 后调整语气再重发 |
| **09:00** | **18:00** | **r/SideProject** | 发布 Reddit 贴文（Scout Reddit 范本 D） | 容许自我宣传的社群，安全取得初期 traction | — |
| **09:30** | **18:30** | **r/opensource** | 发布 Reddit 贴文 | 曝光于开源社群 | — |
| **10:00** | **19:00** | **r/programming** | 发布 Reddit 贴文（Content #2c） | 接触更广泛的开发者受众。为避免 spam flag，与前一篇间隔 1 小时 | 若被删除，改写成更强调技术价值的版本 |
| **10:00** | **19:00** | **Product Hunt** | 启动 PH 发布（hunter 或亲自上）— 分类为 "AI Coding Agents" | 目标 PH Daily Top 5 | 若尚未找到 hunter，就自行发布并立刻补上 Maker comment |
| **10:30** | **19:30** | **Anthropic Discord** | 在 #showcase 频道分享专案 | 直接触及 Claude 社群 | 改用 #community-projects 作为替代频道 |
| **12:00** | **21:00** | **Dev.to** | 发布技术部落格文章（Content #4） | 长期 SEO、搜寻流量导入 | — |
| **12:00** | **21:00** | **HN 监控** | 确认是否进入 Front Page，开始回复留言 | 留言互动是 HN 排名关键 | 若未进 Front Page → 集中火力在 Reddit/Twitter |
| **13:00-18:00** | **22:00-03:00** | **全平台** | 即时监控 + 回复留言（详见下方） | 美国尖峰时段，最关键的 6 小时 | 若体力不足，只专注核心平台（HN + r/ClaudeAI） |
| **14:00** | **23:00** | **Awesome Lists Tier 1** | 提交 awesome-claude-code（hesreallyhim）issue + jqueryscript PR + awesome-claude-skills PR 共 2 件 | 与 trending 同步送出 PR，可最大化核准机率 | — |

### 即时监控指标与临界值

| 指标 | 检查周期 | 绿色（正常） | 黄色（注意） | 红色（紧急） |
|------|----------|------------|------------|------------|
| Star velocity | 30 分钟 | >10 stars/h | 5-10 stars/h | <5 stars/h |
| HN rank | 30 分钟 | Front Page（1-30） | Page 2（31-60） | Page 3+ |
| HN comments | 1 小时 | 5+ comments/h | 2-4 comments/h | <2 comments/h |
| Reddit upvotes（r/ClaudeAI） | 1 小时 | 50+ | 20-50 | <20 |
| Twitter thread impressions | 2 小时 | 5k+ | 1-5k | <1k |

### 紧急应对情境（Plan B）

| 情境 | 触发条件 | 立即应对 |
|---------|--------|----------|
| HN 发文后 3 小时内仍未进入 Front Page | UTC 11:00 时 Points < 10 | 集中火力在 Reddit/Twitter。HN 可考虑隔天重发 |
| Reddit 贴文被删除 | 收到 moderator 移除通知 | 重新确认该 subreddit 规则 → 调整语气后以 modmail 请求重新审核 |
| Star velocity < 5/h（全通路） | D-Day +6h 时点 | 紧急私讯 influencer（Nick Saraev、Boris Cherny）+ 第二波动员支持者 |
| 出现大量负面留言 | 批评留言达 3 则以上 | 立即礼貌回应。承认技术限制 + 分享 roadmap。绝对不要采取防卫姿态 |

---

## 4. D+1 ~ D+3：Amplification

### D+1（4/8 周三）

| 时间（UTC） | 动作 | 平台 | 触发条件 |
|-----------|------|--------|------------|
| 08:00 | **r/MachineLearning 贴文**（Content #2b — 研究导向） | Reddit | 无条件执行 |
| 10:00 | **Twitter Quote-tweet**: "研究结果最让人惊讶的部分是..." — 强调 scaling insight | Twitter/X | 无条件执行 |
| 10:00 | **提交 Ben's Bites 社群投票** | Newsletter | 无条件执行 |
| 12:00 | **Anthropic Discord 后续贴文** — 分享社群反应 | Discord | 达成 100+ Stars 时 |
| 14:00 | **深入回复 HN 留言** — 详细回答技术问题 | HN | HN 仍停留 Front Page 时 |
| Ongoing | **所有 GitHub Issues 在 24 小时内回复** | GitHub | 收到 issue 时 |

### D+2（4/9 周四）

| 时间（UTC） | 动作 | 平台 | 触发条件 |
|-----------|------|--------|------------|
| 08:00 | **接触 TLDR AI / TLDR Open Source 编辑团队** | Email | 若 Stars 200+，可加强 pitch |
| 10:00 | **接触 The Rundown AI 编辑团队** | Email | 无条件执行 |
| 10:00 | **提交 Console.dev** | Web | 无条件执行 |
| 12:00 | **转贴到 r/LocalLLaMA**（技术深度版） | Reddit | 若 r/ClaudeAI 反应正向 |
| 14:00 | **发文到 r/artificial** | Reddit | 无条件执行 |

### D+3（4/10 周五）

| 时间（UTC） | 动作 | 平台 | 触发条件 |
|-----------|------|--------|------------|
| 08:00 | **Twitter: "100 harnesses" 独立贴文** — 介绍 companion repo | Twitter/X | 无条件执行 |
| 10:00 | **提交 Changelog Weekly** | Newsletter | 无条件执行 |
| 12:00 | **提交 AI Tool Report** | Newsletter | 无条件执行 |
| 14:00 | **在 Star History 注册专案** + 把 star graph 嵌入 README | GitHub/Web | 若 Stars 300+，图表会更有说服力 |
| Ongoing | **里程碑推文**: "Launched 3 days ago → X stars" | Twitter/X | 达成 500+ Stars 时 |

---

## 5. D+4 ~ D+14：Sustain

### D+4 ~ D+7（4/11~4/14）

| 日期 | 动作 | 平台 |
|------|------|--------|
| D+4（周六） | **提交 Awesome Lists Tier 2 PR**: awesome-llm-agents, awesome-agents, awesome-ai-agents, awesome-ai-agents-2026, Awesome-Prompt-Engineering | GitHub |
| D+5（周日） | **Dev.to 后续文章**: "5 Architecture Patterns for AI Agent Teams"（常青内容） | Dev.to |
| D+5 | **接触 YouTube 创作者**: Nick Saraev（最高优先）、Sabrina Ramonov、freeCodeCamp | Email/DM |
| D+6（周一） | **确认 Trendshift badge 并嵌入 README** | GitHub |
| D+7（周二） | **每周里程碑推文**: "Week 1: X stars, Y forks, Z countries" + Star History 图表 | Twitter/X |
| D+7 | **登录 awesomeclaude.ai** | Web |

### D+8 ~ D+14（4/15~4/21）

| 日期 | 动作 | 平台 |
|------|------|--------|
| D+8~10 | **提交 Awesome Lists Tier 3 PR**: jim-schwoebel, webfuse-com, BehiSecc, alvinunreal | GitHub |
| D+10 | **接触 Superhuman AI、The Neuron 电子报** | Email |
| D+10 | **r/MachineLearning 专案 showcase 后续贴文**（加入实际使用案例 + 吸收社群回馈） | Reddit |
| D+12 | **Twitter：使用者回馈精选 thread** — "Here's what people are building with Harness" | Twitter/X |
| D+14 | **两周里程碑推文** + 分享 roadmap（下一版本规划） | Twitter/X |
| Ongoing | **持续在 48 小时内回复所有 GitHub Issues/PR** | GitHub |
| Ongoing | **回复所有 Twitter 提及 / 引用** | Twitter/X |

### 长期社群维系原则

1. **Issue 24-48 小时回复规则**：在 Trending 之后，新访客第一次开 issue 时，快速回应是建立社群的关键
2. **标记 "Good First Issue"**：有意识地创造简单的贡献机会，吸引 contributor 加入
3. **持续更新 CHANGELOG**：每次 release 都写详细 notes，建立专案活跃印象
4. **每月更新贴文**：把进度分享至 r/ClaudeAI + Twitter

---

## 6. 成功指标

### Star Velocity 目标（依时段）

| 时点 | 累积 Stars | Velocity (stars/h) | Trending 临界标准 |
|------|-----------|-------------------|-------------------|
| D-Day +2h | 20-30 | 10-15 | 开始进入 |
| D-Day +6h | 80-120 | 15-20 | Daily Trending 候选 |
| D-Day +12h | 150-200 | 10-15 | 进入 Daily Trending |
| D-Day +24h | 250-350 | 8-12 | 在 Daily Trending 站稳 |
| D+2 | 400-500 | 5-8 | Weekly Trending 候选 |
| D+3 | 500-600 | 4-6 | 进入 Weekly Trending |
| D+7 | 700-900 | 2-4 | 维持 Weekly Trending |
| D+14 | 1,000-1,500 | 1-3 | Monthly Trending |

### 综合成功指标

| 指标 | D-Day | D+3 | D+7 | D+14 | 备注 |
|------|-------|-----|-----|------|------|
| **GitHub Stars** | 300+ | 500+ | 800+ | 1,200+ | 核心指标 |
| **GitHub Forks** | 30+ | 50+ | 80+ | 120+ | 实际使用 proxy |
| **GitHub Trending 排名** | Top 50 | Top 25 | 维持 Top 25 或再次进榜 | — | Primary 目标 |
| **HN Points** | 100+ | — | — | — | Front Page 约等于 ~50+ points |
| **HN Comments** | 30+ | — | — | — | Engagement 深度 |
| **Product Hunt Rank** | Top 10 | — | — | — | Daily rank |
| **Reddit Total Upvotes** | 200+ | 400+ | — | — | 全部 subreddit 合计 |
| **Twitter Impressions** | 50k+ | 100k+ | 150k+ | — | thread + mentions |
| **Awesome List PRs Merged** | 2+ | 4+ | 6+ | 8+ | 长期可发现性 |
| **GitHub Issues Opened** | 5+ | 10+ | 20+ | 30+ | 社群健康指标 |
| **Contributors** | 1 | 2+ | 3+ | 5+ | 社群形成 |

---

## 7. 风险与缓解

| # | 风险 | 机率 | 影响 | 缓解策略 |
|---|--------|------|------|-----------|
| 1 | **HN 无反应** — Show HN 无法打进 Front Page | 中 | 高 | HN 本身带有赌博性。若失败就把火力集中在 Reddit/Twitter。也可考虑在 D+2~3 重发。另可参与 "Ask HN: What are you working on?" 月度讨论串 |
| 2 | **Reddit 自我宣传贴文被删** — moderator 移除贴文 | 中 | 中 | 依各 subreddit 调整语气（r/ClaudeAI 著重使用案例、r/programming 著重技术价值、r/MachineLearning 著重研究）。若发布前一周已有正常参与纪录会更有利 |
| 3 | **Star velocity 不足** — 未达 Trending 门槛（D-Day +12h 时 < 100 stars） | 中 | 高 | Plan B：紧急私讯 influencer + 第二波支持者动员 + 活用亚洲时区（韩国 / 日本）社群。已有日文 README，可在日本开发者社群（Zenn、Qiita）发布日文贴文 |
| 4 | **负面技术回馈** — "这不就是 prompt 吗？"、"A/B 测试方法论可疑" | 中 | 中 | 以预先准备的 Q&A 礼貌且技术性地回应。诚实承认限制，但以实际结果数据支撑。"You're right that X is a limitation — here's what we're working on for v2" |
| 5 | **Product Hunt 成绩不佳** — 无法进 Daily Top 10 | 中 | 低 | PH 是辅助通路。即使表现不佳，也不会直接影响 GitHub Trending。与其纠结 PH，不如专注 HN/Reddit |
| 6 | **竞品同日发布** — 同一天有相似 AI agent 工具打进 Trending | 低 | 中 | 强调 Harness 的差异化（meta-skill、A/B 研究结果、100 个预建范例）。预先准备好能清楚说明差异的留言 |
| 7 | **作者时区不利** — KST 与美国尖峰时段有 12-14 小时落差，导致即时回应延迟 | 高 | 中 | 规划 D-Day 晚上到凌晨集中监控（KST 17:00 ~ 03:00 = UTC 08:00 ~ 18:00）。D+1 上午开始补回留言。睡前先留一则 "I'll respond to all questions in the morning" |
| 8 | **GitHub 服务故障** — 发布当天 GitHub 当机 / 过慢 | 低 | 高 | 事前监控 githubstatus.com。若故障就延到隔天发布。内容都已备妥，可直接再利用 |

---

## 8. 最终检查清单

### Pre-Launch（D-1 前完成）

**Repo 最佳化**
- [ ] 建立 GitHub Releases v1.0.0、v1.0.1
- [ ] 设定 8 个 GitHub Topics
- [ ] 设定 Repo Description
- [ ] 上传 Social Preview 图片（1280×640）
- [ ] 部署 GitHub Pages + 在 About 设定 URL
- [ ] 新增 Issue Templates（bug_report.yml, feature_request.yml）
- [ ] 新增 PR Template
- [ ] 撰写 CONTRIBUTING.md
- [ ] 新增 CODE_OF_CONDUCT.md
- [ ] 新增 CI workflow + 绿色 badge
- [ ] 新增有效性验证测试
- [ ] 将 README 的 "Quick Start" 区段重新命名
- [ ] 在 README 新增 "Contributing" 区段
- [ ] 制作 demo GIF + 放到 README 顶部

**内容**
- [ ] 准备 HN Show HN 最终版本文字
- [ ] 完成 4 种 Reddit 贴文最终稿（r/ClaudeAI, r/programming, r/SideProject, r/opensource）
- [ ] 准备 Twitter/X 9 则推文 + 3-4 张图片
- [ ] 完成 Dev.to 文章最终稿
- [ ] 完成 Product Hunt 发布页草稿（tagline, description, images）
- [ ] 确认所有内容连结都能正常运作

**外联**
- [ ] 找到 Product Hunt hunter（或决定自行发布）
- [ ] 已向 Nick Saraev、Boris Cherny 发出预先 DM
- [ ] 确保有 5 到 10 位初期支持者，并确认 D-Day 当天可参与
- [ ] 完成 5-7 组 HN 预期问题 Q&A 草稿
- [ ] 确认可存取 Anthropic Discord

**Repo 联动**
- [ ] 公开 harness-100 repo + 整理 README
- [ ] 公开 claude-code-harness（研究 repo）
- [ ] 确认 3 个 repo 之间的 cross link 正常
- [ ] 更新 Twitter 个人简介

### D-Day（4/7 周二）

**发文顺序**
- [ ] UTC 08:00 — 发 HN Show HN
- [ ] UTC 08:15 — 向支持者群组分享连结
- [ ] UTC 08:30 — 发 Twitter/X thread + 置顶
- [ ] UTC 09:00 — 发 r/ClaudeAI + r/SideProject
- [ ] UTC 09:30 — 发 r/opensource
- [ ] UTC 10:00 — 发 r/programming + Product Hunt
- [ ] UTC 10:30 — 发 Anthropic Discord #showcase
- [ ] UTC 12:00 — 发 Dev.to 文章
- [ ] UTC 14:00 — 提交 Awesome Lists Tier 1 PR/issue（4 件）

**监控**
- [ ] 每 30 分钟检查一次 Star velocity
- [ ] 每 30 分钟检查一次 HN rank
- [ ] 每 1 小时检查一次 Reddit upvotes
- [ ] 所有留言在 1 小时内回复
- [ ] 立即回复 GitHub Issues

### Post-Launch（D+1 ~ D+14）

- [ ] D+1：发 r/MachineLearning 贴文 + Twitter QT + 提交 Ben's Bites
- [ ] D+2：联系 TLDR/Rundown/Console.dev
- [ ] D+3：发 "100 harnesses" 独立贴文 + 提交 Changelog + 登录 Star History
- [ ] D+4：提交 Awesome Lists Tier 2 的 5 件 PR
- [ ] D+5：发布 Dev.to 后续文章 + 联系 YouTube 创作者
- [ ] D+7：发每周里程碑推文
- [ ] D+8~10：提交 Awesome Lists Tier 3 的 4 件 PR + 接触 Tier 3 电子报
- [ ] D+14：分享两周里程碑 + roadmap

---

## 连锁效果（Cascade）设计

```
D-Day 08:00  HN Show HN ──────────────┐
D-Day 08:30  Twitter Thread ────────────┤
D-Day 09:00  Reddit (r/ClaudeAI) ───────┤
D-Day 10:00  Product Hunt ──────────────┤
                                        ▼
                              初期 Star Velocity
                              (3 小时内 30-50 stars)
                                        │
                                        ▼
                              GitHub Trending 演算法侦测
                              （Daily Trending 候选）
                                        │
                          ┌─────────────┼─────────────┐
                          ▼             ▼             ▼
                    Trendshift       Alpha Signal   GitNews
                    自动收录         自动追踪       自动收录
                          │             │             │
                          ▼             ▼             ▼
                    第二波流量导入 → Star Velocity 加速
                                        │
                                        ▼
                              稳定打进 GitHub Trending
                              (Top 25)
                                        │
                          ┌─────────────┼─────────────┐
                          ▼             ▼             ▼
                    TLDR AI 收录    电子报精选     Awesome List
                    (D+2~3)        (D+3~7)       加速 PR 核准
                          │             │             │
                          ▼             ▼             ▼
                    第三波流量 → 建立长期可发现性 → 1,000+ Stars
```

**核心**：每一阶段都扮演下一阶段的触发条件。前 24 小时的 Star velocity，是整体连锁反应能否被点燃的关键。

---

## 执行摘要

| 阶段 | 期间 | 核心目标 | 成功标准 |
|------|------|----------|----------|
| **Pre-Launch** | D-7 ~ D-1 | Repo Score 5.5 → 8.0 | Checklist 100% 完成 |
| **Launch** | D-Day | 达成 Star velocity > 10/h | 24 小时内 300+ stars |
| **Amplification** | D+1 ~ D+3 | 打进 Trending + 第二波扩散 | 进入 Top 25 + 500+ stars |
| **Sustain** | D+4 ~ D+14 | 建立长期可发现性 | 1,200+ stars + Awesome List 8+ merged |

> **最终目标**：把 Harness 定位成「Claude Code Plugin 的代表案例」，并透过 GitHub Trending 在全球 AI 开发者社群建立知名度。
