# Skill 测试与迭代改进指南

用于验证在 Harness 中建立之 skill 品质，并持续迭代改善的方法论。这是对 `SKILL.md` Phase 6 的补充参考。

---

## 目录

1. [测试框架概览](#1-测试框架概览)
2. [测试 prompt 撰写方式](#2-测试-prompt-撰写方式)
3. [执行测试：With-skill vs Baseline](#3-执行测试with-skill-vs-baseline)
4. [量化评估：基于 assertion 的评分](#4-量化评估基于-assertion-的评分)
5. [善用专业 Agent](#5-善用专业-agent)
6. [迭代改进循环](#6-迭代改进循环)
7. [Description 触发验证](#7-description-触发验证)
8. [Workspace 结构](#8-workspace-结构)

---

## 1. 测试框架概览

skill 品质验证是**定性评估**与**定量评估**的组合。

| 评估类型 | 方法 | 适合的 skill |
|----------|------|-----------|
| **定性** | 由使用者直接审查产出物 | 文风、设计、创作物等主观品质 |
| **定量** | 以 assertion 为基础的自动评分 | 档案建立、资料撷取、程式码生成等可客观验证的项目 |

核心循环：**撰写 → 执行测试 → 评估 → 改进 → 再测试**

---

## 2. 测试 prompt 撰写方式

### 原则

测试 prompt 应该是**真实使用者可能输入的、具体且自然的句子**。抽象或过度人工化的 prompt，测试价值很低。

### 不好的例子

```
"处理这份 PDF"
"撷取资料"
"产生图表"
```

### 好的例子

```
"请从下载资料夹中的 'Q4_营收_最终_v2.xlsx' 使用 C 栏（营收）和 D 栏（成本）
新增一个利润率（%）栏位，并依利润率做递减排序。"
```

```
"请把这份 PDF 第 3 页的表格撷取出来并转成 CSV。表头共有两列，
第一列是类别，第二列才是真正的栏位名称。"
```

### prompt 多样性

- 混合**正式 / 轻松**语气
- 混合**明示 / 暗示**意图（例如直接说档案格式 vs 必须从上下文推论）
- 混合**简单 / 复杂**任务
- 部分范例可包含缩写、错字、口语表达

### 涵盖范围

先从 2 到 3 个 prompt 开始，但要设计成至少涵盖：
- 1 个核心使用情境
- 1 个 edge case
- （可选）1 个复合任务

---

## 3. 执行测试：With-skill vs Baseline

### 3-1. 比较执行结构

针对每个测试 prompt，**同时**启动两个 subagent：

**With-skill 执行：**
```
提示词："{测试提示词}"
skill 路径：{skill 路径}
输出路径：_workspace/iteration-N/eval-{id}/with_skill/outputs/
```

**Baseline 执行：**
```
提示词："{测试提示词}"（相同）
skill：无
输出路径：_workspace/iteration-N/eval-{id}/without_skill/outputs/
```

### 3-2. Baseline 选择

| 情境 | Baseline |
|------|----------|
| 建立新 skill | 不使用 skill，直接执行相同 prompt |
| 改进既有 skill | 修改前的 skill 版本（保留 snapshot） |

### 3-3. 撷取时序资料

在 subagent 完成通知中，必须**立即**保存 `total_tokens` 与 `duration_ms`。这些资料只在通知当下可取得，之后无法恢复。

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

---

## 4. 量化评估：基于 assertion 的评分

### 4-1. 撰写 assertion

如果产出物可以客观验证，就应定义 assertion 来做自动评分。

**好的 assertion：**
- 可以客观判断真／假
- 名称具描述性，只看结果就知道在检查什么
- 能验证该 skill 的核心价值

**不好的 assertion：**
- 不论有没有 skill 都会通过（例如「有输出存在」）
- 需要主观判断（例如「写得很好」）

### 4-2. 可程式化验证

若 assertion 能以程式码验证，就请写成 script。这会比人工目视更快、更可靠，而且能在每次 iteration 中重复使用。

### 4-3. 注意 Non-discriminating assertion

若某个 assertion 在「两种配置都 100% 通过」，就无法测出 skill 的差异价值。发现这类 assertion 时，应移除或改成更具挑战性的 assertion。

### 4-4. 评分结果 schema

```json
{
  "expectations": [
    {
      "text": "已新增利润率栏位",
      "passed": true,
      "evidence": "确认 E 栏存在 `profit_margin_pct` 栏位"
    },
    {
      "text": "已依利润率做递减排序",
      "passed": false,
      "evidence": "未排序，仍保留原始顺序"
    }
  ],
  "summary": {
    "passed": 1,
    "failed": 1,
    "total": 2,
    "pass_rate": 0.50
  }
}
```

---

## 5. 善用专业 Agent

在测试／评估过程中运用专门角色的 agent，可以提升品质。

### 5-1. Grader（评分者）

负责执行以 assertion 为基础的评分，并从产出物中撷取可验证的 claim，再进行交叉验证。

**角色：**
- 针对每个 assertion 判定通过／失败，并提供依据
- 从产出物中撷取事实性主张并验证
- 对 eval 本身的品质提供回馈（例如 assertion 太简单或过于模糊时提出建议）

### 5-2. Comparator（盲测比较者）

将两份产出匿名成 A/B，在不知道哪一份使用了 skill 的情况下，判定其品质优劣。

**适用时机：** 当你想更严谨地确认「新版本是否真的更好」时。一般的迭代改进流程中可省略。

**判定标准：**
- 内容：正确性、完整度
- 结构：组织性、格式、可用性
- 综合分数

### 5-3. Analyzer（分析者）

分析 benchmark 资料中的统计模式：
- Non-discriminating assertion（两种配置都通过 → 无差异性）
- 高变异 eval（每次执行结果差很多 → 不稳定）
- 时间／token 取舍（skill 提升品质，但成本也变高）

---

## 6. 迭代改进循环

### 6-1. 搜集回馈

把产出物展示给使用者并收集回馈。若回馈为空，代表「没有发现问题」。

### 6-2. 改进原则

1. **将回馈泛化** — 不要只为单一测试案例做狭义修补，否则会 overfit。请从原则层级修正。
2. **拿掉不值得其成本的内容** — 阅读 transcript，若 skill 要 agent 做的是没有生产力的工作，就删除那一段。
3. **说明 Why** — 即使使用者回馈很简短，也要理解它为何重要，并把这个理解反映到 skill 中。
4. **把重复工作打包** — 如果每次测试都会建立同样的 helper script，就应该预先放进 `scripts/`。

### 6-3. 迭代流程

```
1. 修改 skill
2. 在新的 iteration-N+1/ 目录中重新执行所有测试案例
3. 向使用者展示结果（与前一轮 iteration 比较）
4. 搜集回馈
5. 再次修改 → 重复
```

**结束条件：**
- 使用者满意
- 所有回馈皆为空（所有产出物都没有问题）
- 已无明显可再提升之处

### 6-4. 草稿 → 复审 pattern

修改 skill 时，先写出草稿，再**以新的角度重新阅读**后进一步改进。不要期待一次就写到完美，而是透过草稿与审阅循环逐步打磨。

---

## 7. Description 触发验证

### 7-1. 撰写触发 Eval query

准备 20 个 eval query：10 个 should-trigger + 10 个 should-NOT-trigger。

**query 品质标准：**
- 真实使用者可能输入的、具体且自然的句子
- 包含档案路径、个人情境、栏位名称、公司名称等具体细节
- 混合不同长度、语气与格式
- 与其追求明确标准答案，更应聚焦在**边界案例（edge case）**

**Should-trigger query（8 到 10 个）：**
- 同一意图的不同表达方式（正式／口语）
- 没有明说 skill / 档案类型，但明显需要此 skill 的情况
- 非主流使用情境
- 会和其他 skill 竞争，但理应由这个 skill 胜出的情况

**Should-NOT-trigger query（8 到 10 个）：**
- **Near-miss 是重点** — 关键字相近，但更适合其他工具／skill 的 query
- 明显无关的 query（例如「写 Fibonacci 函式」）几乎没有测试价值
- 邻近领域、模糊表述、关键字重叠但上下文不同的情况

### 7-2. 验证是否与既有 skill 冲突

确认新 skill 的 description 不会与既有 skill 的触发范围重叠：

1. 搜集既有 skill 清单中的 description
2. 确认新 skill 的 should-trigger query 不会误触发既有 skill
3. 若发现冲突，就把 description 的边界条件写得更清楚

### 7-3. 自动最佳化（选用进阶功能）

若需要最佳化 description：

1. 将 20 个 eval query 切分为 Train（60%）/ Test（40%）
2. 用目前的 description 测量触发准确率
3. 分析失败案例并产生改良后的 description
4. 以 Test set 表现选出最佳 description（不是以 Train set 为准，避免过拟合）
5. 最多重复 5 次

> 这个流程会用到 `claude -p` 的自动化 script。由于 token 成本较高，建议等 skill 足够稳定后，再在最后阶段执行。

---

## 8. Workspace 结构

用来系统化管理测试／评估结果的目录结构：

```
{skill-name}-workspace/
├── iteration-1/
│   ├── eval-descriptive-name-1/
│   │   ├── eval_metadata.json
│   │   ├── with_skill/
│   │   │   ├── outputs/
│   │   │   ├── timing.json
│   │   │   └── grading.json
│   │   └── without_skill/
│   │       ├── outputs/
│   │       ├── timing.json
│   │       └── grading.json
│   ├── eval-descriptive-name-2/
│   │   └── ...
│   └── benchmark.json
├── iteration-2/
│   └── ...
└── evals/
    └── evals.json
```

**规则：**
- eval 目录请使用**描述性名称**而不是数字（例如 `eval-multi-page-table-extraction`）
- 每个 iteration 都要保留在独立目录中（不要覆写前一轮 iteration）
- 不要删除 `_workspace/` — 这是为了事后验证与稽核追踪
