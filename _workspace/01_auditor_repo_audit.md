# Harness — GitHub Trending 就緒度稽核

**日期：** 2026-03-29
**Repo：** [revfactory/harness](https://github.com/revfactory/harness)
**標語：** Agent Team & Skill Architect — A Claude Code Plugin

---

## 關鍵優勢

1. **極佳的 README 結構** — 首屏上方有橫幅圖片、6 個 badge、多語支援（EN/KO/JA）、清楚的工作流程圖、架構 pattern 表格，以及豐富的 use-case prompt。對多數 trending repo 來說，這已經高於平均水準。
2. **Landing page (`index.html`)** — 具備精緻深色主題與多語切換的 landing page。許多 trending repo 甚至完全沒有任何網頁呈現。
3. **強而有力的敘事** — README 包含一段 "Built with Harness" 章節，附有量化的 A/B test 結果（+60% 品質提升、100% 勝率）。這種證據相當少見，而且很有說服力。
4. **從第一天起就支援多語** — README 提供 3 種語言版本（EN、KO、JA），landing page 也有 i18n。可擴大在不同語言社群中的可發現性。
5. **清楚的 plugin 結構** — `plugin.json`、`SKILL.md` 與 references 目錄組織良好，封裝方式很專業。
6. **CHANGELOG** — 遵循 Semantic Versioning，且條目詳細。展現出積極維護中的狀態。
7. **Apache 2.0 License** — 寬鬆且對企業友善。

---

## 稽核評分

| 類別 | 分數 | 備註 |
|----------|:-----:|-------|
| 1. README 品質 | **8/10** | 很強。缺少：demo GIF/screencast、Quick Start 可以更醒目 |
| 2. Repo 結構 | **4/10** | 沒有 issue templates、PR template、CONTRIBUTING.md、CODE_OF_CONDUCT.md，也沒有 tags/releases |
| 3. 信任訊號 | **3/10** | 沒有 CI/CD、沒有測試、沒有 docs site、沒有 releases |
| 4. 可發現性 | **7/10** | 多語 README、landing page、badges。缺少：GitHub Topics、social preview、SEO description |

**總分：5.5 / 10**

---

## 詳細發現與建議

### 1. README 品質 (8/10)

| 項目 | 狀態 | 備註 |
|------|--------|-------|
| 標語 | ✅ | "Agent Team & Skill Architect — A Claude Code Plugin" |
| 首屏上方橫幅圖片 | ✅ | `harness_banner.png` |
| Badges (3-5) | ✅ | 6 個 badge，包含版本、授權、stars |
| Quick Start (≤5 steps) | ⚠️ | 有安裝說明，但未標示為 "Quick Start" |
| Install 區段 | ✅ | Marketplace + 直接安裝 |
| 使用範例 | ✅ | 8 個詳細 prompt 範例 |
| Contributing 連結 | ❌ | 沒有 CONTRIBUTING.md 或連結 |
| License | ✅ | Apache 2.0 |
| Demo GIF/screencast | ❌ | 沒有顯示 plugin 實際運作的動畫 demo |

#### 建議

| # | 建議 | 影響 | 成本 |
|---|---------------|--------|--------|
| R1 | **新增一段 demo GIF/screencast**，展示 Harness 如何從單一 prompt 生成 agent team。請放在標語下方。這是 GitHub Trending 上影響力最高的單一視覺元素，因為訪客會在 3 秒內做判斷。 | **高** | **中** |
| R2 | **把 install 區段改名成 "Quick Start"**，並確保在 ≤5 個編號步驟內完成。第一步應該是一行可直接 copy-paste 的指令。 | **中** | **低** |
| R3 | **在 README 底部新增 "Contributing" 區段**，連到 CONTRIBUTING.md（見 R7）。 | **中** | **低** |

---

### 2. Repo 結構 (4/10)

| 項目 | 狀態 |
|------|--------|
| `.github/ISSUE_TEMPLATE/` | ❌ 缺少 |
| `.github/PULL_REQUEST_TEMPLATE.md` | ❌ 缺少 |
| `CONTRIBUTING.md` | ❌ 缺少 |
| `CODE_OF_CONDUCT.md` | ❌ 缺少 |
| `.gitignore` | ✅ 已存在（精簡） |
| Git tags / GitHub Releases | ❌ 沒有 tags |
| GitHub Topics | ❌ 未設定 |
| LICENSE | ✅ 已存在 |
| CHANGELOG.md | ✅ 已存在 |

#### 建議

| # | 建議 | 影響 | 成本 |
|---|---------------|--------|--------|
| R4 | **建立 GitHub Releases**，包含 tag `v1.0.0` 與 `v1.0.1`。Releases 會顯示在側邊欄，能傳達專案成熟度。release notes 可直接取自 CHANGELOG.md。 | **高** | **低** |
| R5 | **新增 issue templates** — 至少包含：`bug_report.yml`、`feature_request.yml`。這能降低首次貢獻者的參與門檻，也能展現社群就緒度。 | **高** | **低** |
| R6 | **新增 PR template**（`.github/PULL_REQUEST_TEMPLATE.md`），包含 checklist：description、testing、screenshots。 | **中** | **低** |
| R7 | **新增 CONTRIBUTING.md** — 即使是簡短版本也可以，至少說明：如何回報 bug、如何提交 PR、開發環境如何設定。這對 trending 很關鍵，因為新訪客會找這個。 | **高** | **低** |
| R8 | **新增 CODE_OF_CONDUCT.md** — 使用 Contributor Covenant 範本。GitHub 會在 community profile 顯示 "Code of Conduct" badge。 | **中** | **低** |
| R9 | **在 repo 設定 GitHub Topics**：`claude-code`、`claude-code-plugin`、`agent-team`、`ai-agent`、`llm`、`skill-generation`、`orchestration`、`claude`。Topics 會影響 GitHub 搜尋與 "Explore" 推薦。 | **高** | **低** |

---

### 3. 信任訊號 (3/10)

| 項目 | 狀態 |
|------|--------|
| CI/CD (GitHub Actions) | ❌ 無 |
| Tests | ❌ 沒有 test suite |
| Docs site | ⚠️ 有 landing page，但沒有專門的 docs |
| Recent commits | ✅ 活躍（最近 2 天內有多次 commit） |
| Issue response time | N/A（目前尚無 issues） |

#### 建議

| # | 建議 | 影響 | 成本 |
|---|---------------|--------|--------|
| R10 | **新增一個基本的 GitHub Actions CI workflow** — 即使只是驗證 YAML/JSON、對 markdown 跑 linter，或檢查 plugin.json 格式正確都可以。README 上的綠色 CI badge 是很強的信任訊號。 | **高** | **低** |
| R11 | **新增驗證測試** — plugin 已經提到 "dry-run testing" 與 "with-skill vs without-skill comparison"。至少包裝一個 smoke test，用來驗證 plugin 結構（plugin.json schema、SKILL.md 存在、references 存在）。 | **高** | **中** |
| R12 | **將 landing page 部署到 GitHub Pages** — 為 repo 啟用 Pages，讓 `index.html` 可透過 `revfactory.github.io/harness` 存取。再把網址加到 repo 的 "About" 區塊。這也能兼作 docs site。 | **高** | **低** |

---

### 4. 可發現性 (7/10)

| 項目 | 狀態 |
|------|--------|
| GitHub Topics | ❌ 未設定 |
| SEO description (repo About) | ⚠️ 未知 — 需要在 GitHub UI 中設定 |
| Social preview image | ❌ 未設定（目前會使用 GitHub 自動產生） |
| 多語 README | ✅ EN、KO、JA |
| Landing page | ✅ 含 i18n 的 `index.html` |

#### 建議

| # | 建議 | 影響 | 成本 |
|---|---------------|--------|--------|
| R13 | **在 GitHub "About" 區塊設定 repo description**："Agent Team & Skill Architect — A Claude Code Plugin that designs domain-specific agent teams and generates skills" | **高** | **低** |
| R14 | **上傳 social preview image**（1280×640px），路徑為 Settings → Social preview。這會決定 repo 在 Twitter/X、Discord、Slack 等平台被分享時的顯示樣式。建議使用調整成 2:1 比例的 banner image。 | **高** | **低** |
| R15 | **在 repo About 中設定網站 URL**，指向 GitHub Pages 網址（見 R12）。 | **中** | **低** |

---

## 優先矩陣（前 10 項行動）

依照 Impact ÷ Effort 比率排序，以達成最佳 trending 就緒度：

| Priority | Rec | Action | Impact | Effort |
|:--------:|:---:|--------|--------|--------|
| 1 | R4 | 建立 GitHub Releases（v1.0.0、v1.0.1） | High | Low |
| 2 | R9 | 設定 GitHub Topics | High | Low |
| 3 | R13 | 設定 repo description | High | Low |
| 4 | R14 | 上傳 social preview image | High | Low |
| 5 | R12 | 將 landing page 部署到 GitHub Pages | High | Low |
| 6 | R5 | 新增 issue templates | High | Low |
| 7 | R7 | 新增 CONTRIBUTING.md | High | Low |
| 8 | R10 | 新增含 badge 的 CI workflow | High | Low |
| 9 | R1 | 新增 demo GIF/screencast | High | Medium |
| 10 | R11 | 新增驗證測試 | High | Medium |

---

## 摘要

Harness repo 有一個 **很強的基礎** — README 結構完整、支援多語、landing page 精緻，而且 A/B testing 證據是非常突出的差異化優勢。主要缺口在於 **社群基礎設施**（沒有 issue templates、PR template、CONTRIBUTING.md、CODE_OF_CONDUCT.md）與 **信任訊號**（沒有 CI/CD、沒有測試、沒有 releases/tags）。好消息是，多數高影響修正都屬於低成本 — 設定 topics、建立 releases、加入 templates，以及把 landing page 部署到 GitHub Pages，都能在單一工作階段內完成，並把總分從 **5.5 提升到約 8/10**。
