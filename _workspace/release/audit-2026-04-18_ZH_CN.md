# 发布稽核 —— 2026-04-18

**负责人：** release-engineer agent
**目标储存库：** `/Users/robin/IdeaProjects/harness` (revfactory/harness)
**上位策略文件：** `/Users/robin/Downloads/harness-research/revfactory-harness_Jcurve_strategy_2026-04-18.md` §3.2 P-04
**依据：** 研究报告 §1.5、§4.7 弱点第 4 项（tag、version 不一致）

---

## 1. 目前状态（Before）

| 来源 | 版本 | 档案路径 | 备注 |
|------|------|-----------|------|
| README.md badge | **1.0.1** | `README.md:6` | `version-1.0.1-brightgreen.svg` |
| README_KO.md badge | **1.0.1** | `README_KO.md:6` | 与 EN 相同字串 |
| README_JA.md badge | **1.0.1** | `README_JA.md:6` | 与 EN 相同字串 |
| plugin.json | **1.2.0** | `.claude-plugin/plugin.json:4` | Claude Code 实际读取的权威来源 |
| marketplace.json | **1.1.0** | `.claude-plugin/marketplace.json:14` | `plugins[0].version` |
| CHANGELOG 最新项 | **[1.2.0]** | `CHANGELOG.md:5` | 日期为 2026-04-08 |
| 最新 git tag | **（无）** | — | `git tag -l` 输出为空，tagged release 0 件 |
| 最新 commit | `3bfc442` | HEAD (main) | `v1.2.0: simplify with CLAUDE.md pointer policy...` |

### 1.1 不一致摘要

**三重不一致状态** —— 这是可能在 enterprise 审批与 marketplace 信任建立流程中，第一个就被淘汰的 hygiene 问题。

- README badges（3 种）vs plugin.json：**2 个版本差距**（1.0.1 → 1.2.0）
- marketplace.json vs plugin.json：**1 个版本差距**（1.1.0 → 1.2.0）
- plugin.json vs git tag：**缺少 tag**（虽然宣告为 1.2.0，但 release artifacts 为 0）

### 1.2 不一致的影响程度

| 影响面向 | 症状 |
|----------|------|
| 可信度 | 访客看到 README badge 后，会误以为「1.0.1 才是最新版本」→ 先入为主地认为是旧版本 |
| 安装体验 | 在 marketplace 安装时会以 1.1.0 meta 注册，但实际 plugin 是 1.2.0 → 后续更新无法追踪 |
| Release 追踪 | `git tag -l` 为空 → `gh release list` 为空 → 使用者无法追踪各版本 CHANGELOG |
| Enterprise 审批 | 若没有 tagged release，就无法建立 CVE、SBOM 与 audit trail |

---

## 2. 决定正确版本

### 选定：**v1.2.0**

### 依据

1. **plugin.json 优先原则** —— 因为 Claude Code plugin system 实际会读取它，所以它最具权威性（角色定义 Step 2 的优先顺位）
2. **与最新 CHANGELOG 一致** —— `[1.2.0] - 2026-04-08` 作为最新 entry 存在，且与 plugin.json 相符
3. **与最新 commit message 一致** —— `3bfc442 v1.2.0: simplify with CLAUDE.md pointer policy...`（两个来源可交叉佐证）

→ 将 3 种 README badges（1.0.1）与 marketplace.json（1.1.0）向上同步到 **v1.2.0**

### 额外判断：将本次作业本身记录为 v1.2.1

- 本次作业（版本一致性 + positioning 宣告 + CONTRIBUTING + docs/ + Issue #3 回应）属于 `v1.2.0` 之后的 patch/minor 级改善，因此在 CHANGELOG 中新增 **[1.2.1] - 2026-04-18** entry
- SemVer 判断：没有 breaking change，且新增功能（CONTRIBUTING、docs/）属于 additive，但使用者看到的 skill API 没有任何变更 → 判定为 **patch**
- 若有模糊空间，通常可考虑 minor，但这个储存库对使用者可见的「skill 执行表面」完全没变，因此维持 patch

---

## 3. 同步内容（After）

| 档案 | Before | After | 变更方式 |
|------|--------|-------|----------|
| `README.md:6` | `version-1.0.1-brightgreen` | `version-1.2.0-brightgreen` | Edit（替换 badge URL 字串） |
| `README_KO.md:6` | `version-1.0.1-brightgreen` | `version-1.2.0-brightgreen` | Edit |
| `README_JA.md:6` | `version-1.0.1-brightgreen` | `version-1.2.0-brightgreen` | Edit |
| `.claude-plugin/marketplace.json:14` | `"version": "1.1.0"` | `"version": "1.2.0"` | Edit |
| `.claude-plugin/plugin.json:4` | `"version": "1.2.0"` | （无变更） | 已是正确版本 |
| `CHANGELOG.md` | 最新为 `[1.2.0]` | 新增 `[1.2.1] - 2026-04-18` 区段 | Edit（插入前面） |

### 3.1 已修改的档案清单（5 项）

```
 M CHANGELOG.md
 M README.md
 M README_JA.md
 M README_KO.md
 M .claude-plugin/marketplace.json
```

### 3.2 新增档案（1 项）

```
?? _workspace/release/audit-2026-04-18.md   （本稽核文件）
```

### 3.3 **不修改** plugin.json

因为它已经是正确版本（`1.2.0`），所以不变更。下一个版本（1.2.1）发布时再另外进行 bump。

---

## 4. git tag 计划（等待执行批准）

**禁止执行** —— 下列命令仅能在 main orchestrator 明确批准后执行。目前只做文件化记录。

### 4.1 补建旧版 tag（3 项）

| Tag | 目标 commit | Commit 日期 | 依据 |
|------|----------|----------|------|
| `v1.0.0` | `dd0d0db` | 2026-03-27 | 「准备提交至 marketplace：新增 CHANGELOG、description 加入英文对照、整理 requirements」—— 首次把 [1.0.0] 区段写入 CHANGELOG 的 commit |
| `v1.0.1` | `22bdbff` | 2026-03-29 | 「新增 README badge 并同步 plugin.json 版本 1.0.1」—— 真正将 plugin.json 从 1.0.0 bump 到 1.0.1 的 commit |
| `v1.1.0` | `2d84863` | 2026-04-05 | 「v1.1.0: Phase 0 现况稽核、CLAUDE.md 自动同步、加入营运／维护 workflow」—— v1.1.0 最终 release commit（同日较早的 commit `8604b11` 为中间阶段） |

### 4.2 新增 tag（1 项）

| Tag | 目标 commit | 依据 |
|------|----------|------|
| `v1.2.0` | `3bfc442` | 目前 HEAD，「v1.2.0: simplify with CLAUDE.md pointer policy, add hybrid execution mode」 |

### 4.3 预定执行命令（等待批准）

```bash
cd /Users/robin/IdeaProjects/harness

# 补建旧版 tag —— 仅使用 annotated tag（禁止 lightweight，角色定义 §6）
git tag -a v1.0.0 dd0d0db -m "v1.0.0: 初次公开 harness meta-skill

- 基于 6 个 Phase workflow 建立 harness
- 6 种 agent 架构模式
- agent team / subagent 执行模式
- 基于 Progressive Disclosure 的 skill 撰写指南"

git tag -a v1.0.1 22bdbff -m "v1.0.1: 移除 SKILL.md 重复内容并同步 plugin.json 版本

- 移除 SKILL.md 与 references 间的重复内容（330 行 → 285 行）
- 将 Phase 2-1、2-3、3、5-2 转为 references 指标"

git tag -a v1.1.0 2d84863 -m "v1.1.0: Phase 0 现况稽核、CLAUDE.md 同步与 harness 演化机制

- Phase 0：现况稽核与 3 分支路由（新建 / 扩充 / 维护）
- Phase 5-4：CLAUDE.md harness context 登录
- Phase 7：harness 演化机制（回馈 → 反映 → 变更记录）
- 支援 orchestrator 后续工作"

git tag -a v1.2.0 3bfc442 -m "v1.2.0: CLAUDE.md pointer policy 与 hybrid execution mode

- 简化 CLAUDE.md 登录政策（context → pointer）
- Phase 2-1 hybrid execution mode（team + subagent 组合）
- Phase 5-0 hybrid orchestrator pattern
- Phase 5-1 基于回传值的资料传递（subagent 模式）"

# 确认
git tag -l --sort=-v:refname
git show v1.2.0 --stat | head -20
```

### 4.4 远端 push（等待第二次批准）

```bash
# ⚠️ 在验证完上述 4 个本地 tag 后，且取得 main orchestrator 第二次批准后，才可执行
git push origin v1.0.0 v1.0.1 v1.1.0 v1.2.0
```

**原则：** 不使用 `git push --tags`（整批 push）。必须明确逐一 push 这 4 个 tags，以避免出错。

---

## 5. GitHub Release 草稿（等待批准）

**禁止执行** —— `gh release create` 包含 `draft` 在内，一律等待批准。以下仅提供命令文字建议。

### 5.1 v1.2.0（目前的正确版本）

```bash
cd /Users/robin/IdeaProjects/harness

gh release create v1.2.0 \
  --title "v1.2.0 — CLAUDE.md pointer policy & hybrid execution mode" \
  --notes "$(cat <<'EOF'
> ⚠️ **Experimental**: Claude Code plugin system 目前仍处于 Experimental 阶段。若要导入 production，建议采用 pin-to-tag 策略。

## Changed

- **简化 CLAUDE.md 登录政策（移除重复）** — 将 Phase 5-4 的「context 登录」改为「pointer 登录」。从 CLAUDE.md 移除 agent 清单、skill 清单、目录结构与详细执行规则，只保留 **触发规则 + 变更历史**
- **删除 Phase 3/4 临时同步步骤** — 降低 CLAUDE.md 同步负担
- **重新定义核心原则第 3 点** — 「context 登录」→「pointer 登录」

## Added

- **Phase 2-1: hybrid execution mode** — 在 agent team / subagent 之外新增 hybrid pattern
- **Phase 2-1 execution mode 比较表** — team / subagent / hybrid 三种决策顺序
- **Phase 5-0 hybrid orchestrator pattern**
- **Phase 5-1 基于回传值的资料传递**（仅用于 subagent 模式）

## Migration

若你在前一版（v1.1.0）中让 CLAUDE.md 的「harness context」区段变得过于庞大，请参考 `docs/migration-1.2.md`（准备中）改成 pointer 区块。

## Full Changelog

[CHANGELOG.md §1.2.0](https://github.com/revfactory/harness/blob/main/CHANGELOG.md)
EOF
)" \
  --draft
```

### 5.2 v1.0.0 / v1.0.1 / v1.1.0（补建旧版 release）

建立 tag 后，再从 CHANGELOG 撷取对应区段作为 `--notes` 内容。本次稽核中省略命令提案（待 v1.2.0 批准后，再作为第二批处理）。

### 5.3 执行批准检查清单

main orchestrator 在批准执行 `gh release create` 前，需先确认：

- [ ] 4 个本地 tags 是否都挂在正确的 SHA 上（以 `git show <tag>` 验证）
- [ ] `git push origin v*` 完成后，是否能在 GitHub 上看到 tags
- [ ] release note 开头是否包含 Experimental 警告（角色定义 Step 6）
- [ ] 是否已确认 content-creator 能把 banner image 附加到 release 上

---

## 附录 A. 下一次稽核时的检查清单

- [ ] 本次稽核之后新增了多少 commits
- [ ] 这段期间内 plugin.json 版本是否有变更
- [ ] CHANGELOG 是否新增了新的 entry
- [ ] 最新 tag 版本与 plugin.json 之间是否仍有 gap
- [ ] 3 种 README badges 的同步状态

## 附录 B. 上位文件关联

- 策略报告 §3.2 P-04「版本／release 一致性」—— 本作业的直接触发点
- 策略报告 §4.7「enterprise 审批路径」—— tagged release 的需求来源
- 研究报告 §1.5「储存库量化指标」—— release 0 件状态的成因
- 研究报告 §4.7 弱点 4「tag／version 不一致」—— 本作业要解决的对象
