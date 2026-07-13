# Harness — GitHub Trending 就绪度稽核

**日期：** 2026-03-29
**Repo：** [revfactory/harness](https://github.com/revfactory/harness)
**标语：** Agent Team & Skill Architect — A Claude Code Plugin

---

## 关键优势

1. **极佳的 README 结构** — 首屏上方有横幅图片、6 个 badge、多语支援（EN/KO/JA）、清楚的工作流程图、架构 pattern 表格，以及丰富的 use-case prompt。对多数 trending repo 来说，这已经高于平均水准。
2. **Landing page (`index.html`)** — 具备精致深色主题与多语切换的 landing page。许多 trending repo 甚至完全没有任何网页呈现。
3. **强而有力的叙事** — README 包含一段 "Built with Harness" 章节，附有量化的 A/B test 结果（+60% 品质提升、100% 胜率）。这种证据相当少见，而且很有说服力。
4. **从第一天起就支援多语** — README 提供 3 种语言版本（EN、KO、JA），landing page 也有 i18n。可扩大在不同语言社群中的可发现性。
5. **清楚的 plugin 结构** — `plugin.json`、`SKILL.md` 与 references 目录组织良好，封装方式很专业。
6. **CHANGELOG** — 遵循 Semantic Versioning，且条目详细。展现出积极维护中的状态。
7. **Apache 2.0 License** — 宽松且对企业友善。

---

## 稽核评分

| 类别 | 分数 | 备注 |
|----------|:-----:|-------|
| 1. README 品质 | **8/10** | 很强。缺少：demo GIF/screencast、Quick Start 可以更醒目 |
| 2. Repo 结构 | **4/10** | 没有 issue templates、PR template、CONTRIBUTING.md、CODE_OF_CONDUCT.md，也没有 tags/releases |
| 3. 信任讯号 | **3/10** | 没有 CI/CD、没有测试、没有 docs site、没有 releases |
| 4. 可发现性 | **7/10** | 多语 README、landing page、badges。缺少：GitHub Topics、social preview、SEO description |

**总分：5.5 / 10**

---

## 详细发现与建议

### 1. README 品质 (8/10)

| 项目 | 状态 | 备注 |
|------|--------|-------|
| 标语 | ✅ | "Agent Team & Skill Architect — A Claude Code Plugin" |
| 首屏上方横幅图片 | ✅ | `harness_banner.png` |
| Badges (3-5) | ✅ | 6 个 badge，包含版本、授权、stars |
| Quick Start (≤5 steps) | ⚠️ | 有安装说明，但未标示为 "Quick Start" |
| Install 区段 | ✅ | Marketplace + 直接安装 |
| 使用范例 | ✅ | 8 个详细 prompt 范例 |
| Contributing 连结 | ❌ | 没有 CONTRIBUTING.md 或连结 |
| License | ✅ | Apache 2.0 |
| Demo GIF/screencast | ❌ | 没有显示 plugin 实际运作的动画 demo |

#### 建议

| # | 建议 | 影响 | 成本 |
|---|---------------|--------|--------|
| R1 | **新增一段 demo GIF/screencast**，展示 Harness 如何从单一 prompt 生成 agent team。请放在标语下方。这是 GitHub Trending 上影响力最高的单一视觉元素，因为访客会在 3 秒内做判断。 | **高** | **中** |
| R2 | **把 install 区段改名成 "Quick Start"**，并确保在 ≤5 个编号步骤内完成。第一步应该是一行可直接 copy-paste 的指令。 | **中** | **低** |
| R3 | **在 README 底部新增 "Contributing" 区段**，连到 CONTRIBUTING.md（见 R7）。 | **中** | **低** |

---

### 2. Repo 结构 (4/10)

| 项目 | 状态 |
|------|--------|
| `.github/ISSUE_TEMPLATE/` | ❌ 缺少 |
| `.github/PULL_REQUEST_TEMPLATE.md` | ❌ 缺少 |
| `CONTRIBUTING.md` | ❌ 缺少 |
| `CODE_OF_CONDUCT.md` | ❌ 缺少 |
| `.gitignore` | ✅ 已存在（精简） |
| Git tags / GitHub Releases | ❌ 没有 tags |
| GitHub Topics | ❌ 未设定 |
| LICENSE | ✅ 已存在 |
| CHANGELOG.md | ✅ 已存在 |

#### 建议

| # | 建议 | 影响 | 成本 |
|---|---------------|--------|--------|
| R4 | **建立 GitHub Releases**，包含 tag `v1.0.0` 与 `v1.0.1`。Releases 会显示在侧边栏，能传达专案成熟度。release notes 可直接取自 CHANGELOG.md。 | **高** | **低** |
| R5 | **新增 issue templates** — 至少包含：`bug_report.yml`、`feature_request.yml`。这能降低首次贡献者的参与门槛，也能展现社群就绪度。 | **高** | **低** |
| R6 | **新增 PR template**（`.github/PULL_REQUEST_TEMPLATE.md`），包含 checklist：description、testing、screenshots。 | **中** | **低** |
| R7 | **新增 CONTRIBUTING.md** — 即使是简短版本也可以，至少说明：如何回报 bug、如何提交 PR、开发环境如何设定。这对 trending 很关键，因为新访客会找这个。 | **高** | **低** |
| R8 | **新增 CODE_OF_CONDUCT.md** — 使用 Contributor Covenant 范本。GitHub 会在 community profile 显示 "Code of Conduct" badge。 | **中** | **低** |
| R9 | **在 repo 设定 GitHub Topics**：`claude-code`、`claude-code-plugin`、`agent-team`、`ai-agent`、`llm`、`skill-generation`、`orchestration`、`claude`。Topics 会影响 GitHub 搜寻与 "Explore" 推荐。 | **高** | **低** |

---

### 3. 信任讯号 (3/10)

| 项目 | 状态 |
|------|--------|
| CI/CD (GitHub Actions) | ❌ 无 |
| Tests | ❌ 没有 test suite |
| Docs site | ⚠️ 有 landing page，但没有专门的 docs |
| Recent commits | ✅ 活跃（最近 2 天内有多次 commit） |
| Issue response time | N/A（目前尚无 issues） |

#### 建议

| # | 建议 | 影响 | 成本 |
|---|---------------|--------|--------|
| R10 | **新增一个基本的 GitHub Actions CI workflow** — 即使只是验证 YAML/JSON、对 markdown 跑 linter，或检查 plugin.json 格式正确都可以。README 上的绿色 CI badge 是很强的信任讯号。 | **高** | **低** |
| R11 | **新增验证测试** — plugin 已经提到 "dry-run testing" 与 "with-skill vs without-skill comparison"。至少包装一个 smoke test，用来验证 plugin 结构（plugin.json schema、SKILL.md 存在、references 存在）。 | **高** | **中** |
| R12 | **将 landing page 部署到 GitHub Pages** — 为 repo 启用 Pages，让 `index.html` 可透过 `revfactory.github.io/harness` 存取。再把网址加到 repo 的 "About" 区块。这也能兼作 docs site。 | **高** | **低** |

---

### 4. 可发现性 (7/10)

| 项目 | 状态 |
|------|--------|
| GitHub Topics | ❌ 未设定 |
| SEO description (repo About) | ⚠️ 未知 — 需要在 GitHub UI 中设定 |
| Social preview image | ❌ 未设定（目前会使用 GitHub 自动产生） |
| 多语 README | ✅ EN、KO、JA |
| Landing page | ✅ 含 i18n 的 `index.html` |

#### 建议

| # | 建议 | 影响 | 成本 |
|---|---------------|--------|--------|
| R13 | **在 GitHub "About" 区块设定 repo description**："Agent Team & Skill Architect — A Claude Code Plugin that designs domain-specific agent teams and generates skills" | **高** | **低** |
| R14 | **上传 social preview image**（1280×640px），路径为 Settings → Social preview。这会决定 repo 在 Twitter/X、Discord、Slack 等平台被分享时的显示样式。建议使用调整成 2:1 比例的 banner image。 | **高** | **低** |
| R15 | **在 repo About 中设定网站 URL**，指向 GitHub Pages 网址（见 R12）。 | **中** | **低** |

---

## 优先矩阵（前 10 项行动）

依照 Impact ÷ Effort 比率排序，以达成最佳 trending 就绪度：

| Priority | Rec | Action | Impact | Effort |
|:--------:|:---:|--------|--------|--------|
| 1 | R4 | 建立 GitHub Releases（v1.0.0、v1.0.1） | High | Low |
| 2 | R9 | 设定 GitHub Topics | High | Low |
| 3 | R13 | 设定 repo description | High | Low |
| 4 | R14 | 上传 social preview image | High | Low |
| 5 | R12 | 将 landing page 部署到 GitHub Pages | High | Low |
| 6 | R5 | 新增 issue templates | High | Low |
| 7 | R7 | 新增 CONTRIBUTING.md | High | Low |
| 8 | R10 | 新增含 badge 的 CI workflow | High | Low |
| 9 | R1 | 新增 demo GIF/screencast | High | Medium |
| 10 | R11 | 新增验证测试 | High | Medium |

---

## 摘要

Harness repo 有一个 **很强的基础** — README 结构完整、支援多语、landing page 精致，而且 A/B testing 证据是非常突出的差异化优势。主要缺口在于 **社群基础设施**（没有 issue templates、PR template、CONTRIBUTING.md、CODE_OF_CONDUCT.md）与 **信任讯号**（没有 CI/CD、没有测试、没有 releases/tags）。好消息是，多数高影响修正都属于低成本 — 设定 topics、建立 releases、加入 templates，以及把 landing page 部署到 GitHub Pages，都能在单一工作阶段内完成，并把总分从 **5.5 提升到约 8/10**。
