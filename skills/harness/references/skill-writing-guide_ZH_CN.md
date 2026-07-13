# Skill 撰写指南

用于提升 Harness 产生之 skill 品质的详细撰写指南。这是 `SKILL.md` Phase 4 的补充参考资料。

---

## 目录

1. [Description 撰写模式](#1-description-撰写模式)
2. [本文撰写风格](#2-本文撰写风格)
3. [输出格式定义模式](#3-输出格式定义模式)
4. [范例撰写模式](#4-范例撰写模式)
5. [Progressive Disclosure 模式](#5-progressive-disclosure-模式)
6. [script bundling 判断标准](#6-script-bundling-判断标准)
7. [资料 schema 标准](#7-资料-schema-标准)
8. [不要放进 skill 的内容](#8-不要放进-skill-的内容)

---

## 1. Description 撰写模式

`Description` 是 skill 唯一的 trigger 机制。Claude 会只根据 `available_skills` 清单中的 name + description，决定是否使用该 skill。

### 理解 trigger 机制

Claude 倾向不会为了可以用自身基本工具轻松处理的简单工作呼叫 skill。像「帮我读这份 PDF」这种简单请求，即使 description 写得再完整，也可能不会被 trigger。工作越复杂、步骤越多、越具专业性，skill 被 trigger 的机率就越高。

### 撰写原则

1. 同时描述 **skill 会做什么** + **具体的 trigger 情境**
2. 明确写出边界条件，区分相似但不应 trigger 的情况
3. 稍微写得更「pushy」一些，以补偿 Claude 倾向保守判断 trigger 的特性

### 好的范例

```yaml
description: "执行所有 PDF 相关工作，包括读取档案、撷取文字与表格、合并、
  分割、旋转、加浮水印、加密或解密，以及 OCR。只要提到 .pdf 档案
  或要求产出 PDF 成果物，就应该使用此 skill。当需求不只是单纯
  '帮我读这份 PDF'，而是包含转换、编辑或分析时尤其适用。"
```

```yaml
description: "处理所有 spreadsheet 工作，包括为 Excel/CSV/TSV 新增栏位、
  计算公式、调整格式、建立图表与资料清理。只要使用者提到 spreadsheet
  档案，即使只是随口说『下载资料夹里那个 xlsx』，也应该使用此 skill。"
```

### 不好的范例

- `"处理资料的 skill"` — 太模糊，无法判断是什么档案或工作
- `"与 PDF 相关的工作"` — 没有列出具体动作，也没描述 trigger 情境

---

## 2. 本文撰写风格

### Why-First 原则

LLM 理解原因后，就能在 edge case 中做出更正确的判断。与其使用强硬规则，不如传达脉络，效果更好。

**不好的范例：**
```markdown
ALWAYS use pdfplumber for table extraction. NEVER use PyPDF2 for tables.
```

**好的范例：**
```markdown
表格撷取使用 pdfplumber。PyPDF2 擅长纯文字撷取，但无法稳定保留表格的
列与栏结构；pdfplumber 则能辨识储存格边界，回传更结构化的资料。
```

### 一般化原则

当从回馈或测试结果中发现问题时，不要只做刚好符合特定范例的狭义修正，而要在 **原理层级进行一般化**。

**overfit 的修正：**
```markdown
如果存在「Q4 营收」栏位，就将该栏转成数值型别。
```

**一般化后的修正：**
```markdown
若栏位名称包含「营收」、「金额」、「数量」等暗示数值的关键字，
就将该栏转成数值型别；若转换失败，保留原始值。
```

### 命令式语气

不要使用「会...」、「可以...」这类语气，改用「执行...」、「请将...」这种明确的命令形式。skill 是一份指示书。

### 节省 context

context window 是公共资源。要不断自问每一句话是否足以合理化它的 token 成本：
- 「这是 Claude 已经知道的内容吗？」→ 删除
- 「没有这段说明，Claude 会犯错吗？」→ 保留
- 「一个具体范例是否比一大段说明更有效？」→ 改用范例

---

## 3. 输出格式定义模式

适用于输出格式很重要的 skill：

```markdown
## 报告结构
请严格遵循以下模板：

# [标题]
## 摘要
## 关键发现
## 建议事项
```

格式定义要简洁，如果附上实际范例会更有效。

---

## 4. 范例撰写模式

范例通常比长篇说明更有效：

```markdown
## Commit Message 格式

**范例 1：**
输入：新增以 JWT token 为基础的使用者验证
输出：feat(auth): implement JWT-based authentication

**范例 2：**
输入：修正登入页面密码显示按钮无法运作的 bug
输出：fix(login): fix password visibility toggle
```

---

## 5. Progressive Disclosure 模式

### 模式 1：依领域拆分

```
bigquery-skill/
├── SKILL.md (总览 + 领域选择指南)
└── references/
    ├── finance.md (营收、计费指标)
    ├── sales.md (商机、Pipeline)
    └── product.md (API 使用量、功能)
```

当使用者询问营收时，只载入 `finance.md`。

### 模式 2：条件式细节

```markdown
# DOCX 处理

## 文件建立
使用 docx-js 建立新文件。→ 参考 [DOCX-JS.md](references/docx-js.md)

## 文件编辑
简单编辑可直接修改 XML。
**若需要追踪修订**：参考 [REDLINING.md](references/redlining.md)
```

### 模式 3：大型 reference 档案结构

超过 300 行的 reference 档案，应在顶部包含目录：

```markdown
# API 参考

## 目录
1. [验证](#验证)
2. [端点列表](#端点列表)
3. [错误代码](#错误代码)
4. [速率限制](#速率限制)

---

## 验证
...
```

---

## 6. script bundling 判断标准

在执行测试时，观察 agent 们的 transcript。若出现下列模式，就代表应该 bundling：

| 讯号 | 措施 |
|------|------|
| 3 个测试中有 3 个都产生相同的 helper script | bundling 到 `scripts/` |
| 每次都执行相同的 pip install/npm install | 在 skill 中明确写出依赖安装步骤 |
| 重复相同的多步骤做法 | 在 skill 本文中写成标准程序 |
| 每次都遇到类似错误后套用相同 workaround | 在 skill 中记录已知问题与解法 |

已 bundling 的 script 必须经过实际执行测试。

---

## 7. 资料 schema 标准

为了让 skill 之间的资料交换保持一致，请使用标准 schema。这也可用于 Harness 产生之 skill 的测试与评估。

### `eval_metadata.json`

各测试案例的 metadata：

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "使用者的工作提示词",
  "assertions": [
    "成果物中包含 X",
    "已产生 Y 格式的档案"
  ]
}
```

### `grading.json`

以 assertion 为基础的评分结果：

```json
{
  "expectations": [
    {
      "text": "成果物中包含「台北」",
      "passed": true,
      "evidence": "在第 3 个步骤确认有「撷取台北地区资料」"
    }
  ],
  "summary": {
    "passed": 2,
    "failed": 1,
    "total": 3,
    "pass_rate": 0.67
  }
}
```

**栏位名称注意：** 必须精确使用 `text`、`passed`、`evidence`（禁止改成 `name`、`met`、`details` 等变形）。

### `timing.json`

执行时间 / token 测量：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

在 subagent 完成通知中，要立刻保存 `total_tokens` 与 `duration_ms`。这些资料只能在通知当下取得，之后无法复原。

---

## 8. 不要放进 skill 的内容

- `README.md`、`CHANGELOG.md`、`INSTALLATION_GUIDE.md` 等附加文件
- skill 产生过程的 metadata（测试结果、迭代历程）
- 面向使用者的说明文件（skill 是给 AI agent 的指示书）
- Claude 已经知道的一般性知识

---

## 9. 技能重复使用设计

建立新技能前，先确认是否与既有技能重复。反复建立 Harness 时，功能重叠的技能很容易以不同名称累积。

| 情况 | 处理方式 |
|------|----------|
| 既有技能已完全涵盖新功能 | 禁止建立新的技能，改为将既有技能连结到代理人 |
| 既有技能部分涵盖，且可以一般化 | 将既有技能一般化并扩充 |
| 部分涵盖是刻意的领域特化 | 建立新的技能，维持为独立技能 |
| 功能范围完全不同 | 建立新的技能 |

**原则：** 单一技能越专注于一个角色，重复越少、可重用性越高。若技能同时负责两种以上角色，先检查是否应拆分。

### 一般化到什么程度

一般化可以无限进行，因此应在**预期的责任范围**内停止。保留刻意的领域特化，只移除偶然形成的相依性。

例如「金融科技风险评估 PDF」技能：

| 阶段 | 结果 |
|------|------|
| 移除金融科技相依 | 「评估结果 PDF」；若责任范围是评估报告，应在此停止 |
| 移除评估相依 | 「PDF 排版」；若已存在相同技能，不要建立新的技能，应重复使用既有技能 |

若技能的预期责任范围就是「金融科技风险评估」，则不应一般化，应维持为独立技能。

扩充技能可能改变依赖它的代理人行为。扩充前先确认相依性，并在 description 中反映扩充后的使用范围。
