# Post-M0 Audit — 2026-04-18

**負責人:** repo-auditor agent  
**目標儲存庫:** `/Users/robin/IdeaProjects/harness`  
**上層任務:** 整合驗證 release-engineer / content-creator / launch-strategist / community-scout 4 個 agent 並行套用 M0 Quick Wins 的結果  
**驗證方式:** 唯讀（禁止 Edit/Write）。以 `git diff`、`git status`、逐檔 Read 判定一致性、衝突與區段遺失情況。

---

## 1. 驗證結果（PASS/FAIL 矩陣）

### A. 版本一致性（release-engineer）

| 區域 | 驗證項目 | 結果 | 備註 |
|------|-----------|------|------|
| A-1 | `README.md:6` badge `Version-1.2.0` | **PASS** | 維持 `brightgreen`，已確認從原本 `1.0.1` 改動 |
| A-2 | `README_KO.md:6` badge `Version-1.2.0` | **PASS** | 字串一致 |
| A-3 | `README_JA.md:6` badge `Version-1.2.0` | **PASS** | 字串一致 |
| A-4 | `.claude-plugin/marketplace.json:14` `"version": "1.2.0"` | **PASS** | 原本 `1.1.0` → `1.2.0` |
| A-5 | `.claude-plugin/plugin.json:4` 維持 `"version": "1.2.0"` | **PASS（數值）** / **FAIL（政策）** | version 欄位雖仍是 `1.2.0`，但 `description` 與 `keywords` 已被修改 — 參見 §4 衝突審查 |
| A-6 | `CHANGELOG.md` 的 [1.2.1] 條目 | **PASS** | 最上方存在 `[1.2.1] - 2026-04-18` 區段，含 Fixed/Added/Changed 3 個區塊 |
| A-7 | `_workspace/release/audit-2026-04-18.md` 存在 | **PASS** | 228 行，完整包含 5 個區段 + 2 個附錄 |

### B. README 的 "harness factory" 定位（content-creator）

| 區域 | 驗證項目 | EN | KO | JA | 備註 |
|------|-----------|----|----|----|------|
| B-1 | H1 `Harness — The Team-Architecture Factory for Claude Code`（各語言翻譯） | **PASS** | **PASS** | **PASS** | EN(L20)、KO(L20「團隊架構工廠」）、JA(L20「團隊架構工廠」) |
| B-2 | H1 下方 callout 段落（3 語觸發語並列） | **PASS** | **PASS** | **PASS** | EN(L24)、KO(L24)、JA(L24) — 全部都並列英/韓/日 3 種 trigger 語句 |
| B-3 | 3 種 badge（Layer / Sub-layer / i18n） | **PASS** | **PASS** | **PASS** | EN(L14–18)、KO(L14–18)、JA(L14–18) — 3 個 badge 都連到各自語言的 anchor |
| B-4 | "Category — Where Harness Sits" 4 列表格 | **PASS** | **PASS** | **PASS** | EN(L30–39 + L41 footnote)、KO(L30–41)、JA(L30–41) — 4 列表格 + Archon vs. Harness 摘要句 |
| B-5 | "Harness Evolution Mechanism" 區段 | **PASS** | **PASS** | **PASS** | EN(L61–74)、KO(L50–63)、JA(L50–63) — 含 delta capture ASCII 圖 |
| B-6 | "+60%" 防禦卡正式文案（n=15, author-measured, third-party replications pending） | **PASS** | **PASS** | **PASS** | EN(L273)、KO(L255)、JA(L262) — 三語都保有相同文案。FAQ Q1（EN:L286 / KO:L268 / JA:L275）也再次確認 |
| B-7 | "Coexistence" 5 列表格 | **PASS** | **PASS** | **PASS** | EN(L247–253)、KO(L229–235)、JA(L236–242) — 5 列（Archon、meta-harness、ECC、wshobson、LangGraph） |
| B-8 | "FAQ" 區段（Q1~Q3 details） | **PASS** | **PASS** | **PASS** | 三份都有 `<details>` 3 組（+60% / harness factory / Claude Code only） |

### C. `docs/` 目錄（launch-strategist）

| 區域 | 驗證項目 | 結果 | 備註 |
|------|-----------|------|------|
| C-1 | `docs/experimental-dependency.md`（約 150 行） | **PASS** | 共 154 行。包含 Current State / Dependency Graph / 3 Scenarios（A·B·C T+24/48/72h）/ Monitoring SLA 表 / Enterprise FAQ Q1–Q3 |
| C-2 | `docs/quickstart.md`（約 120 行，5 步驟·5 個 Failure FAQ） | **PASS** | 共 118 行。包含 Step 1–5 + 每一步對應的 Failure FAQ #1–#5。頂部標明 5 分鐘時間預算 |
| C-3 | `docs/show-hn-launch-kit.md`（約 220 行，2026-05-06 07:05 PT） | **PASS** | 共 224 行。排程表明列 `2026-05-06 Wed 07:05 PT`。包含 Title A/B/C、380 字 Body、T-72h~T+72h timeline、Post-launch 分支、5%-oversold 回應、Crossposting Rules |

### D. 治理（community-scout）

| 區域 | 驗證項目 | 結果 | 備註 |
|------|-----------|------|------|
| D-1 | `CONTRIBUTING.md` 公開 5 項 SLA 數值 | **PASS** | PR 初次回應 72h / Issue triage 48h / Bug P0–P1 14d / Security 7d / Release 2w — 5 項數值皆已公開於表格 |
| D-2 | `.github/ISSUE_TEMPLATE/bug_report.yml` | **PASS** | 具備 claude-code-version、experimental-flag dropdown、重現步驟、預期結果、實際結果、OS dropdown 等必填欄位 |
| D-3 | `.github/ISSUE_TEMPLATE/feature_request.yml` | **PASS** | 具備 problem / proposal / alternatives / related-pattern dropdown（6 種 pattern + N）結構 |
| D-4 | `.github/ISSUE_TEMPLATE/question.yml` | **PASS** | 具備 question / tried / docs 3 個欄位 |
| D-5 | `.github/ISSUE_TEMPLATE/config.yml` | **PASS** | `blank_issues_enabled: false` + Discussions 連結 + security mailto |
| D-6 | `.github/PULL_REQUEST_TEMPLATE.md` | **PASS** | Summary/Motivation/Scope 8 種 checkbox/Tests/CHANGELOG/SemVer 4 選 1 |
| D-7 | `_workspace/community/issue-3-reply.md`（英文） | **PASS** | 提及 Gemini PoC roadmap P-01、SaehwanPark/meta-harness、Gizele1/harness-init、OpenRig 作為替代方案 |
| D-8 | `_workspace/community/issue-2-reply.md`（英文） | **PASS** | 直接引用 hesreallyhim（"really good stuff ... Nice job."），並提到新增 badge + "Harness Factories" 分類提案 |

---

## 2. 發現的問題

| # | 嚴重度 | 位置 | 問題 | 建議處置 |
|---|--------|------|------|----------|
| **1** | **Critical** | `.claude-plugin/plugin.json:3, 12–28` | **原先已明確指示 `plugin.json`「不該被修改」，但實際上 `description` 被全面重寫，且新增了 7 個 `keywords`。** release-engineer 的稽核文件（`audit-2026-04-18.md:89–91`）宣稱「plugin.json 未修改」，但實際 `git diff` 顯示該檔已被變更。判斷這是 **content-creator 為了統一定位而未經授權編輯** 所留下的衝突痕跡。 | 二選一：(a) **接受**：在 `CHANGELOG` 1.2.1 的 Changed 區塊中**明確新增**「plugin.json description·keywords 已與定位宣言對齊」，並把 release-engineer audit §3.3 的「未修改」敘述修正為「description·keywords 由 content-creator 調整，version 維持不變」。 (b) **還原**：以 `git restore .claude-plugin/plugin.json` 回復原狀，另開 PR 處理。— 若直接在目前狀態提交，會留下「稽核文件與實際狀態矛盾」的衛生問題。 |
| **2** | Minor | `README.md:42` vs `README_KO.md` / `README_JA.md` | EN README 保留了 `## Star History` 區段（L43–51），但 KO/JA **沒有**該區段。這在原始 HEAD 中也是如此，因此**不是被刪除**；但若以「三語檔案對稱性」來看，仍存在不一致。 | 這次 release 可**接受**（維持原狀）。建議下一個 PR 開立 `docs/i18n-parity` issue，在 KO/JA 也於相同位置（Category 區段後）補上 Star History。 |
| **3** | Minor | `README.md:15–17` / `README_KO.md:15–17` / `README_JA.md:15–17` | `Layer` badge 在各語言使用不同 anchor（EN: `#category--where-harness-sits`、KO: `#category-harness-location-ko`、JA: `#category-harness-location-ja`）。理論上應符合 GitHub 自動產生 anchor 規則，但 GitHub 對非英文 anchor 的規則可能因特殊符號而變動，仍需再驗證。 | 建議提交前用 GitHub Preview 或本地 grip 驗證渲染。若失效，可改用更保守的 ASCII anchor，或直接加入 `<a name=\"\">` 顯式 anchor。JA 也需同樣注意。 |
| **4** | Info | `_workspace/release/audit-2026-04-18.md:156` | §4.4 中列有 `git push origin v1.0.0 v1.0.1 v1.1.0 v1.2.0` 的待執行項，但本次 M0 內容並未包含 tag 建立 / push — 這是**有意保留等待批准**的狀態，不算問題。不過進入下一階段前仍需決定是否處理這 4 個 tag。 | 4 個 tag + GitHub Release 草稿可在 M1 開始前另行處理，不屬於本次 M0 稽核範圍。 |
| **5** | Info | `docs/experimental-dependency.md:65` | Scenario A 的「Nightly CI 在 P-13 偵測到」連結寫成 `[P-13](#)`，目前只是 placeholder。實際 roadmap / issue 編號尚未指定。 | 等真正開出 roadmap P-13 issue 後，再改成對應的 `#數字`。屬於 launch-strategist 後續工作。 |

---

## 3. 5 秒規則評估

### 3.1 頂部 5 秒掃描情境

訪客在 `README.md` 頂部最先接觸到的視覺資訊順序如下：

1. **Banner image**（L1–3）— `harness_banner.png`
2. **基本 badge 6 種**（L5–12）— Version `1.2.0` / License Apache 2.0 / Claude Code Plugin / 6 Architectures / Agent Teams / GitHub Stars
3. **定位 badge 3 種**（L14–18）— `Layer: L3 Meta-Factory` / `Sub-layer: Team-Architecture Factory` / `README: EN | KO | JA`
4. **H1**（L20）— `Harness — The Team-Architecture Factory for Claude Code`
5. **語言切換**（L22）— `English | 繁體中文 | 日本語`
6. **Callout 區塊**（L24）— 以 3 種語言並列 trigger 語句的一句摘要

### 3.2 5 秒規則判定

| 標準 | 評估 |
|------|------|
| 能否在短時間內理解它是「team-architecture factory」？ | **PASS** — H1 + Sub-layer badge + Callout 三重曝光。可在 5 秒內理解到 L3 Meta-Factory |
| 是否把 trigger 句子視覺化呈現？ | **PASS** — Callout 並列 `"build a harness for this project"` / `"請幫我建立 harness"` / `"請構建這個 harness"` |
| 是否同時露出信任訊號（版本、star、授權）？ | **PASS** — 第一排即為 6 種基本 badge |
| 三語使用者是否獲得相同體驗？ | **PASS** — EN/KO/JA 都採用相同的三段式結構（圖片→badge→H1→Callout），僅字串翻譯不同 |
| 是否有浪費視線的元素（廣告型 badge、重複連結）？ | **PASS** — 共 9 個 badge（基本 6 + 定位 3），位於 Trending repo 常見範圍上限（5–7）附近，但仍不算過多 |

### 3.3 區段順序邏輯評估

以 EN 為準的區段順序：

```
(1) Overview → (2) Category — Where Harness Sits → (3) Star History → (4) Key Features
→ (5) Harness Evolution Mechanism → (6) Workflow → (7) Installation → (8) Plugin Structure
→ (9) Usage（模式·模式類型）→ (10) Output → (11) Use Cases 8種 → (12) Coexistence
→ (13) Built with Harness (100 + A/B 研究) → (14) Requirements → (15) FAQ Q1–Q3 → (16) License
```

- **PASS** — 從「我是什麼（1–2）→ 我如何演化（5）→ 怎麼安裝（7）→ 怎麼使用（9–11）→ 如何與其他方案共存（12）→ 證據（13）→ FAQ / 反駁（15）」的順序很自然。
- 不過在 KO/JA 中缺少 (3) Star History，因此會直接從 (2) 跳到 (4)。就視線流動而言反而更順，故不構成問題。

---

## 4. Agent 衝突稽核

### 4.1 各檔案編輯歸屬表

| 檔案 | release-engineer | content-creator | launch-strategist | community-scout |
|------|------------------|-----------------|-------------------|-----------------|
| `README.md` | badge L6（Version） | H1、Callout、badge 3 種、Category、Evolution、Coexistence、FAQ | — | — |
| `README_KO.md` | badge L6 | H1、Callout、badge、Category、Evolution、Coexistence、FAQ | — | — |
| `README_JA.md` | badge L6 | H1、Callout、badge、Category、Evolution、Coexistence、FAQ | — | — |
| `.claude-plugin/marketplace.json` | L14 version | — | — | — |
| `.claude-plugin/plugin.json` | **（宣告為不修改）** | **編輯了 description、keywords（衝突）** | — | — |
| `CHANGELOG.md` | 新增 [1.2.1] 區塊 | — | — | — |
| `CONTRIBUTING.md` | — | — | — | 新增 |
| `.github/ISSUE_TEMPLATE/*` | — | — | — | 新增（4 種） |
| `.github/PULL_REQUEST_TEMPLATE.md` | — | — | — | 新增 |
| `docs/experimental-dependency.md` | — | — | 新增 | — |
| `docs/quickstart.md` | — | — | 新增 | — |
| `docs/show-hn-launch-kit.md` | — | — | 新增 | — |
| `_workspace/release/audit-2026-04-18.md` | 新增 | — | — | — |
| `_workspace/community/issue-{2,3}-reply.md` | — | — | — | 新增（2 種） |

### 4.2 是否存在同一行的同時編輯

- **README 3 份的 badge 行（L6）** — release-engineer（僅替換 Version badge 的 L6 字串）vs content-creator（改寫 H1 以下區段）。**無重疊**。content-creator 也只是新增 L14–18 的 **badge 區塊**，並未改動 L6，因此無衝突。**PASS**
- **README H1（L20）** — release-engineer 未編輯，由 content-creator 單獨修改。**PASS**
- **`.claude-plugin/plugin.json`** — release-engineer 的政策是連 L4(version) 都不動，實際上 L4 確實未變；但 L3(description) 與 L12–28(keywords) **已被編輯**。若這些編輯出自 content-creator，則與 release-engineer audit 文件 §3.3 形成**宣告與實際不一致**。這不是單純 merge 衝突，而是**違反政策性質的協作衝突**。→ 參見 **2-1 Critical 問題**
- `_workspace/release/audit-2026-04-18.md` — 僅由 release-engineer 編寫。**PASS**

### 4.3 遺失的原始區段

| 區段 | 原始（HEAD）是否存在 | 現 EN | 現 KO | 現 JA | 判定 |
|------|-----------------|-------|-------|-------|------|
| Star History | 僅 EN 有 | 保留（L43） | 原本就沒有 | 原本就沒有 | **PASS**（遺失 0 件） |
| Installation | EN/KO/JA 皆有 | 保留（L92） | 保留（L81） | 保留（L81） | **PASS** |
| Plugin Structure | EN/KO/JA 皆有 | 保留（L113） | 保留（L102） | 保留（L102） | **PASS** |
| Usage mode / pattern | EN/KO/JA 皆有 | 保留（L132–162） | 保留（L121–151） | 保留（L121–151） | **PASS** |
| Use Cases 8 種 | EN/KO/JA 皆有 | 保留（L183–241） | 保留（L172–223） | 保留（L172–230） | **PASS** |
| Built with Harness（100 + A/B 研究） | EN/KO/JA 皆有 | 保留（L255–275） | 保留（L237–257） | 保留（L244–264） | **PASS** |
| Requirements / License | EN/KO/JA 皆有 | 保留 | 保留 | 保留 | **PASS** |

**總結：** 原始區段遺失 0 件。合併方式採「在既有文字中插入新區段」，因此可在無衝突下平行完成。

---

## 5. 結論

### 5.1 綜合 PASS/FAIL

- **區域 A（版本一致性）:** 7 項中 6 PASS / 1 **政策 FAIL**（plugin.json description、keywords 被未授權編輯）
- **區域 B（定位）:** 8 × 3 語 = 24 項全部 PASS
- **區域 C（docs/）:** 3 PASS
- **區域 D（治理）:** 8 PASS
- **5 秒規則:** PASS
- **Agent 衝突:** 1 件 Critical（plugin.json 政策違反）+ 2 件 Minor（i18n anchor 渲染驗證 / KO、JA 缺少 Star History）

**Critical 問題總數：1 件**  
**Minor 問題總數：2 件**  
**Info（建議）項目：2 件**

### 5.2 是否可提交

**可在附帶條件下提交。** 提交前需要先決定以下 1 件事：

#### 必要先行處置 — 解決 `plugin.json` 衝突（二選一）

- **Option A（建議）: 接受** — 修改 `_workspace/release/audit-2026-04-18.md` 的 §3 表格與 §3.3 文字，明確寫出「包含 description、keywords 變更」。並在 `CHANGELOG.md` 的 [1.2.1] Changed 區段補上一行：
  > - `.claude-plugin/plugin.json` description 及 keywords 已與 "harness factory" 定位宣言對齊（version 1.2.0 維持不變）
- **Option B: 還原** — 以 `git restore .claude-plugin/plugin.json` 還原，並在後續另開正式 PR 由 content-creator 提案。

→ **repo-auditor 建議採用 Option A。** 理由如下：  
(a) 變更內容本身與定位一致，且無害；  
(b) `.claude-plugin/plugin.json:4` 的 version 維持 `1.2.0`，不影響 Claude Code runtime；  
(c) 若直接還原，反而會造成 README / marketplace.json 的新 description 與 plugin.json 舊 description 間出現**新的不一致**。

#### 建議的 commit message（若採用 Option A）

```
feat: M0 Quick Wins — 公開定位宣言、版本一致性與治理

- 將 3 份 README（EN/KO/JA）頂部改寫為「Team-Architecture Factory」定位
  （新增 Category、Evolution、Coexistence、FAQ 區段，補上 Layer/Sub-layer/i18n 3 個 badge）
- 同步版本 1.2.0：README 3 個 badge（1.0.1→1.2.0）、marketplace.json（1.1.0→1.2.0）
- 讓 plugin.json description 與 keywords 對齊定位宣言（version 1.2.0 維持不變）
- 新增 CHANGELOG [1.2.1] 條目
- 新增 CONTRIBUTING.md：公開 5 項 SLA 數值（PR 72h / Issue 48h / P0 14d / 安全 7d / 發布 2 週）
- 新增 4 種 `.github/ISSUE_TEMPLATE`（bug/feature/question/config）與 PR template
- 新增 `docs/`：experimental-dependency（3 種情境 SLA）、quickstart（5 分鐘 5 步驟）、show-hn-launch-kit（2026-05-06 07:05 PT）
- `_workspace/community`：Issue #2（awesome-claude-code curator）/ Issue #3（Gemini 問題）回覆草稿
- `_workspace/release/audit-2026-04-18.md` + `post-m0-audit-2026-04-18.md`：稽核記錄
```

### 5.3 不需先修改、但值得記錄的建議事項（Info）

- **補建 4 個 tag（v1.0.0/v1.0.1/v1.1.0/v1.2.0）並建立 GitHub Release 草稿** — `_workspace/release/audit-2026-04-18.md` §4、§5 已列出指令文字但尚未執行。可於 M1 開始前另行處理。
- **在 KO/JA README 補上 Star History 區段** — 建議拆成下一個 PR（`docs/i18n-parity`）。
- **驗證 GitHub anchor 渲染** — 建議在 `gh pr create --draft` 後，於 Preview 分頁目視檢查 Layer/Sub-layer badge 在 KO/JA 是否可正常點擊。

---

## 附錄：稽核依據檔案清單

- `/Users/robin/IdeaProjects/harness/README.md`（317 行）
- `/Users/robin/IdeaProjects/harness/README_KO.md`（299 行）
- `/Users/robin/IdeaProjects/harness/README_JA.md`（306 行）
- `/Users/robin/IdeaProjects/harness/.claude-plugin/plugin.json`（已修改，見 §2.1 Critical）
- `/Users/robin/IdeaProjects/harness/.claude-plugin/marketplace.json`
- `/Users/robin/IdeaProjects/harness/CHANGELOG.md`
- `/Users/robin/IdeaProjects/harness/CONTRIBUTING.md`
- `/Users/robin/IdeaProjects/harness/.github/ISSUE_TEMPLATE/{bug_report,feature_request,question,config}.yml`
- `/Users/robin/IdeaProjects/harness/.github/PULL_REQUEST_TEMPLATE.md`
- `/Users/robin/IdeaProjects/harness/docs/experimental-dependency.md`
- `/Users/robin/IdeaProjects/harness/docs/quickstart.md`
- `/Users/robin/IdeaProjects/harness/docs/show-hn-launch-kit.md`
- `/Users/robin/IdeaProjects/harness/_workspace/release/audit-2026-04-18.md`
- `/Users/robin/IdeaProjects/harness/_workspace/community/issue-{2,3}-reply.md`

稽核命令記錄：`git status`、`git diff --stat`、`git diff .claude-plugin/plugin.json`、`git show HEAD:README.md`、以及對各檔案執行 Read 工具。
