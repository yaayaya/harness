# QA Agent 设计指南

在 Build Harness 中纳入 QA Agent 时可参考的指南。这份指南以实际专案（SatangSlide）中发现的 bug 模式与其根本原因分析为基础，提供一套系统化的验证方法，帮助捕捉 QA 容易漏掉的缺陷。

---

## 目录

1. QA Agent 容易遗漏的缺陷模式
2. 整合一致性验证（Integration Coherence Verification）
3. QA Agent 设计原则
4. 验证检查清单范本
5. QA Agent 定义范本

---

## 1. QA Agent 容易遗漏的缺陷模式

### 1-1. 边界面不一致（Boundary Mismatch）

这是最常见的缺陷。两个元件各自都「正确」实作了，但在连接点上的契约却对不上。

| 边界面 | 不一致范例 | 容易漏掉的原因 |
|--------|-----------|-----------|
| API 回应 → 前端 hook | API 回传 `{ projects: [...] }`，hook 却预期 `SlideProject[]` | 各自单独验证时都正常，但没有做交叉比对 |
| API 回应栏位名称 → 型别定义 | API 使用 `thumbnailUrl`（camelCase），型别使用 `thumbnail_url`（snake_case） | 若用 TypeScript generic 进行 casting，compiler 抓不到 |
| 档案路径 → 连结 href | 页面在 `/dashboard/create`，但连结写成 `/create` | 没有交叉比对档案结构与 href |
| 状态转移图 → 实际 status 更新 | 图上定义 `generating_template → template_approved`，但程式码漏了这段转移 | 只确认图存在，没有追踪所有更新程式码 |
| API endpoint → 前端 hook | API 存在，但没有对应的 hook（未被呼叫） | 没有把 API 清单与 hook 清单做 1:1 对应 |
| 即时回应 → 非同步结果 | API 立即回传 `{ status }`，前端却去读 `data.failedIndices` | 没有区分同步／非同步回应，只检查型别 |

### 1-2. 为什么静态程式码审查抓不到

- **TypeScript generic 的限制**：`fetchJson<SlideProject[]>()`，即使执行期回应其实是 `{ projects: [...] }`，仍然能通过编译
- **`npm run build` 通过 ≠ 正常运作**：只要用了 type casting、`any` 或 generic，build 虽然成功，执行期仍可能失败
- **存在验证 vs 连接验证的差异**：「API 是否存在？」与「API 回应是否符合呼叫端预期？」是完全不同的验证问题

---

## 2. 整合一致性验证（Integration Coherence Verification）

这是 QA Agent 必须纳入的 **交叉比对验证** 区域。

### 2-1. API 回应 ↔ 前端 hook 型别交叉验证

**方法**：比较各 API route 中的 `NextResponse.json()` 呼叫处，与对应 hook 的 `fetchJson<T>` 型别参数。

```
验证步骤：
1. 从 API route 中撷取传给 NextResponse.json() 的物件 shape
2. 确认对应 hook 中 fetchJson<T> 的 T 型别
3. 比较 shape 与 T 是否一致
4. 检查是否有 wrapping（若 API 回传 { data: [...] }，hook 是否有取出 .data）
```

**特别要注意的模式：**
- 分页 API：`{ items: [], total, page }` vs 前端预期阵列
- snake_case DB 栏位 → camelCase API 回应 → 前端型别定义之间的不一致
- 即时回应（202 Accepted）与最终结果 shape 不同

### 2-2. 档案路径 ↔ 连结／路由路径对应

**方法**：撷取 `src/app/` 底下 page 档案的 URL 路径，并与程式码中的所有 `href`、`router.push()`、`redirect()` 值比对。

```
验证步骤：
1. 从 src/app/ 底下 page.tsx 档案路径撷取 URL pattern
   - (group) → 从 URL 中移除
   - [param] → 动态 segment
2. 搜集程式码中所有 href=、router.push(、redirect( 值
3. 确认每个连结是否都能对应到实际存在的 page 路径
4. 注意 route group 内页面的 URL 前缀（例如：dashboard/ 底下）
```

### 2-3. 状态转移完整性追踪

**方法**：撷取程式码中所有 `status:` 更新，并与状态转移图比对。

```
验证步骤：
1. 从状态转移图（STATE_TRANSITIONS）中撷取允许的转移清单
2. 在所有 API route 中搜寻 .update({ status: "..." }) pattern
3. 确认每个转移都已在图中定义
4. 找出图中有定义、但程式码未执行的转移（dead transition）
5. 特别确认：从中间状态（例如 generating_template）到最终状态（template_approved）的转移是否遗漏
```

### 2-4. API endpoint ↔ 前端 hook 1:1 对应

**方法**：列出所有 API route 与前端 hook，确认是否一一成对。

```
验证步骤：
1. 从 src/app/api/ 底下 route.ts 撷取各 HTTP method 的 endpoint 清单
2. 从 src/hooks/ 底下 use*.ts 撷取 fetch 呼叫 URL 清单
3. 找出 API endpoint 中未被 hook 呼叫的项目 → 标记为「未使用」
4. 判断「未使用」是否为预期（例如管理 API），或其实是漏掉呼叫
```

---

## 3. QA Agent 设计原则

### 3-1. 使用 general-purpose 类型，而不是 Explore 类型

如果 QA Agent 是 `Explore` 类型，它只能读取内容。但有效的 QA 需要：
- 用 Grep 搜寻 pattern（例如撷取所有 `NextResponse.json()`）
- 执行 script 自动比对（API shape vs hook 型别）
- 必要时也能直接修改

**建议**：将类型设定为 `general-purpose`，但在 agent 定义中明确写出「验证 → 回报 → 提出修正请求」的流程。

### 3-2. 检查清单应优先重视「交叉比对」，而非「存在确认」

| 较弱的检查清单 | 较强的检查清单 |
|---------------|---------------|
| API endpoint 是否存在？ | API endpoint 的回应 shape 是否与对应 hook 型别一致？ |
| 状态转移图是否有定义？ | 所有 status 更新程式码是否与图中的转移一致？ |
| 页面档案是否存在？ | 程式码中所有连结是否都指向实际存在的页面？ |
| 是否开启 TypeScript strict mode？ | 是否存在用 generic casting 绕过的型别安全问题？ |

### 3-3. 「两边同时读」原则

若 QA 想抓出边界面 bug，就不能只读一边。一定要：
- 将 API route **和** 对应 hook **一起** 看
- 将状态转移图 **和** 实际更新程式码 **一起** 看
- 将档案结构 **和** 连结路径 **一起** 看

请在 agent 定义中明确写下这个原则。

### 3-4. QA 不该只在 build 后执行，而应在各模组完成后立刻执行

若 orchestrator 只把 QA 放在「Phase 4：全部完成后」：
- bug 会累积，修正成本变高
- 早期的边界面不一致会传播到后续模组

**建议 pattern**：每当某个后端 API 完成时，就立刻对该 API 与对应 hook 做交叉验证（incremental QA）。

---

## 4. 验证检查清单范本

可放入 QA Agent 定义中的 Web 应用整合一致性检查清单。

```markdown
### 整合一致性验证（Web app）

#### API ↔ Frontend 连接
- [ ] 所有 API route 的回应 shape 与对应 hook 的 generic 型别一致
- [ ] 被包裹的回应（{ items: [...] }）有在 hook 中正确 unwrap
- [ ] snake_case ↔ camelCase 转换套用一致
- [ ] 前端有区分即时回应（202）与最终结果的 shape
- [ ] 每个 API endpoint 都有对应的前端 hook，且实际有被呼叫

#### 路由一致性
- [ ] 程式码中所有 href/router.push 值都与实际的 page 档案路径相符
- [ ] 路径验证时有考虑 route group（(group)）会从 URL 中移除
- [ ] 动态 segment（[id]）会以正确参数填入

#### 状态机一致性
- [ ] 所有已定义的状态转移都会在程式码中执行（没有 dead transition）
- [ ] 程式码中的所有 status 更新都已定义在转移图中（没有未授权转移）
- [ ] 从中间状态到最终状态的转移没有遗漏
- [ ] 前端中基于状态的分支（if status === "X"）之 X 实际可达

#### 资料流一致性
- [ ] DB schema 栏位名称与 API 回应栏位名称的对应一致
- [ ] 前端型别定义与 API 回应栏位名称一致
- [ ] optional 栏位的 null/undefined 处理在两边都一致
```

---

## 5. QA Agent 定义范本

可放入 Build Harness QA Agent 的核心区段。

```markdown
---
name: qa-inspector
description: "QA 验证专家。验证规格遵循、整合一致性与设计品质。"
---

# QA Inspector

## 核心角色
验证实作是否符合规格，并确认**模组之间的整合一致性**。

## 验证优先顺序

1. **整合一致性**（最高）— 边界面不一致是执行期错误的主要来源
2. **功能规格遵循** — API / state machine / data model
3. **设计品质** — 色彩 / typography / 响应式
4. **程式码品质** — 未使用程式码、命名规则

## 验证方法：「同时阅读两侧」

边界面验证时，必须**同时打开两边的程式码**进行比对：

| 验证对象 | 左侧（生产者） | 右侧（消费者） |
|----------|-------------|---------------|
| API 回应 shape | route.ts 的 NextResponse.json() | hooks/ 中的 fetchJson<T> |
| 路由 | src/app/ page 档案路径 | href、router.push 值 |
| 状态转移 | STATE_TRANSITIONS 图 | .update({ status }) 程式码 |
| DB → API → UI | 资料表栏位名称 | API 回应栏位 → 型别定义 |

## 团队沟通协定

- 一旦发现问题，立刻向对应 agent 发出具体修正请求（档案:行号 + 修正方式）
- 边界面问题要**同时**通知两侧的 agent
- 向 leader 回报：验证报告（区分通过／失败／未验证项目）
```

---

## 实际案例：SatangSlide 中发现的 bug

本指南的所有内容，都来自下列真实 bug 所萃取出的教训：

| bug | 边界面 | 原因 |
|------|--------|------|
| `projects?.filter is not a function` | API→hook | API 回传 `{projects:[]}`，hook 预期阵列 |
| Dashboard 所有连结都 404 | 档案路径→href | 漏掉 `/dashboard/` 前缀 |
| Theme 图片看不到 | API→component | `thumbnailUrl` vs `thumbnail_url` |
| Theme 选择无法储存 | API→hook | select-theme API 存在，但没有 hook |
| 生成页面永远等待中 | 状态转移→程式码 | 漏掉 `template_approved` 转移程式码 |
| `data.failedIndices` crash | 即时回应→前端 | 在即时回应中存取背景结果 |
| 完成后查看 slide 404 | 档案路径→href | `/projects/` → `/dashboard/projects/` |
