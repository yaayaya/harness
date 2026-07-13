# 貢獻 Harness

感謝你考慮為 **Harness** 貢獻內容。Harness 是一個為 Claude Code 設計、能建立 agent team 並生成 skill 的 meta-skill factory。

本文涵蓋：回應 SLA、如何參與、開發環境設定、PR 慣例、commit 訊息規則、行為準則與維護者名單。

---

## 回應 SLA（服務承諾）

以下是此 repository 維護者的回應目標。這些數字採保守估計，讓小型維護團隊在專案成長時也能維持。

| 項目 | 目標 | 說明 |
|------|------|------|
| PR 首次回應 | **< 72h** | 以工作日計算。所謂「首次回應」至少包含加上 label 與一則確認已收到 PR 的留言。 |
| Issue triage 與標記 | **< 48h** | 每個新 issue 會在 48 小時內移除 `needs-triage`，並補上類型標籤（`bug` / `enhancement` / `question` / `discussion`）。 |
| Bug 修復（P0 / P1） | **< 14d** | P0 = 資料遺失 / 安全問題 / 安裝失敗；P1 = 常見使用路徑故障。P2 / P3 會納入 roadmap，但不承諾硬性 SLA。 |
| 安全通報 | **< 7d** | 7 天內給出初步確認。修補目標為 30 天內。私下通報方式請見下方 **Security** 章節。 |
| 發版頻率 | **每兩週一次** | 原則上每兩週打一個 tag；若沒有可發布內容則略過。P0 問題可能會插入非排程的 patch release。 |

若我們未達成 SLA，歡迎你在 issue / PR 裡提醒，這不是失禮，而是約定好的回饋機制。

---

## 如何貢獻

不同類型的貢獻適合走不同入口，請選擇最符合你情況的方式。

### Bug 回報

- 請使用 **Bug report** 表單建立 issue（`.github/ISSUE_TEMPLATE/bug_report.yml`）。
- 必填資訊：Claude Code 版本、`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` flag 狀態、重現步驟、預期結果與實際結果、作業系統。
- 若能提供小型重現案例（少於 30 行）最好。若需要完整專案，請附上公開 fork 連結。

### 功能請求

- 請使用 **Feature request** 表單建立 issue。
- 至少需要一段簡短說明：「這要解決什麼問題？」如果你已有提案，建議整理成接近可 PR 的形式，例如：它是延伸還是取代 6 種 team-architecture pattern 的哪一種？

### 問題

- 請使用 **Question** 表單建立 issue，**或** 若議題較開放，可改在 [GitHub Discussions](https://github.com/revfactory/harness/discussions) 開討論串。

### 討論（接近 RFC 規模的想法）

- 優先使用 GitHub Discussions。等方向大致有共識後，再轉成 issue。

### Pull Request

- 請參考下方 **Pull Request Guidelines**。
- 小型 PR 會更快合併。差異行數超過 400 行的 PR，通常應該先有一篇 Discussion。

### Security

- 對於可能被濫用的問題，**不要** 開公開 issue。
- 請寄信到：`robin.hwang@kakaocorp.com`，主旨加上 `[harness-security]`。
- 我們目標是在 7 天內回覆（詳見上方 SLA 表）。

---

## 開發環境設定

### 先決條件

- Claude Code `v2.x`（需要 Agent Teams API）
- Node.js `>= 18`（供 CI 使用的本地工具）
- Git

### 環境旗標

Harness 目前需要 Claude Code 的實驗性 Agent Teams 功能。請在 shell profile 或個別 session 中設定：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

此相依性記錄於 `docs/experimental-dependency.md`。若 Anthropic 將該 flag 升級為正式功能，我們會依上述 SLA 在 72 小時內更新 README。

### 本地外掛連結

若你想在不發布到 marketplace 的情況下，於本地 Claude Code session 測試變更，可使用：

```bash
# 在你的 checkout 目錄執行
claude plugin link ./harness

# 驗證
claude plugin list | grep harness
```

完成後可用 `claude plugin unlink harness` 解除連結。

### 執行 meta-skill

```bash
claude "build a harness for a fintech risk-assessment team"
```

生成出的 agent 與 skill 會位於目標專案的 `.claude/agents/` 與 `.claude/skills/`。

### 測試與 lint

- Markdown lint：`npx markdownlint '**/*.md'`
- YAML lint（issue template 與 workflow）：`npx yaml-lint .github/`
- Skill metadata 驗證：`python scripts/validate_skills.py`（若存在）

CI 會在每個 PR 上執行這些檢查。鼓勵本地先跑，但不是硬性要求；若 CI 抓到的是可在 merge 前輕鬆修正的小問題，我們不會因此卡住合併流程。

---

## Pull Request 指南

### 分支命名

請使用 `type/short-description` 的格式：

| 前綴 | 用途 | 範例 |
|------|------|------|
| `feat/` | 新增使用者可見功能 | `feat/expert-pool-variance-mode` |
| `fix/` | 修 bug | `fix/agent-teams-flag-detection` |
| `docs/` | 僅文件修改 | `docs/quickstart-gemini-section` |
| `refactor/` | 內部結構調整，無行為變更 | `refactor/skill-loader-split` |
| `chore/` | 建置、依賴、雜務 | `chore/upgrade-markdownlint` |
| `test/` | 僅測試 | `test/fan-out-fan-in-e2e` |

### Commit 訊息語言

- **韓文與英文都可以接受。** 使用你能表達得最精準的語言。
- 若這次變更會出現在 CHANGELOG 或 release note 中，請在 PR 說明中另外提供英文標題，方便下游讀者理解。

### PR 範本

每個 PR 會自動套用 `.github/PULL_REQUEST_TEMPLATE.md`。請完整填寫：

- **Summary**（做了什麼、為什麼做，2–4 句）
- **Motivation**（連結 issue、引用研究，或給一段簡短理由）
- **Scope of change**（本次涉及哪些範圍的勾選清單）
- **Tests**（你執行或新增了哪些測試）
- **CHANGELOG**（是否更新 `CHANGELOG.md`？Y / N / NA）
- **SemVer impact**（patch / minor / major，請見下節）

### Review 期望

- 至少需要一位 maintainer 核准。
- 我們會盡量在 72 小時內對 PR 做出回應（詳見 SLA）。若你被卡住了，可以提醒。

---

## Commit 訊息慣例

我們採用一個較輕量的 **Conventional Commits** 變體，並直接對應到 SemVer。

```text
<type>(<scope>)!: <short summary>

<body — optional>

<footer — optional>
```

### 類型與 SemVer 對應

| Commit 類型 | SemVer 影響 | 範例 |
|-------------|-------------|------|
| `feat!:` 或 footer 出現 `BREAKING CHANGE:` | **major**（例如 1.x → 2.0） | `feat!: rename primary pattern "Supervisor" → "Orchestrator"` |
| `feat:` | **minor**（例如 1.2 → 1.3） | `feat: add Producer-Reviewer variance metric` |
| `fix:` | **patch**（例如 1.2.3 → 1.2.4） | `fix: correct flag detection on zsh` |
| `docs:` / `chore:` / `refactor:` / `test:` | 不提升版本 | `docs: clarify Gemini roadmap` |

- 其他語言摘要也可以，例如：`feat: 為 Expert Pool 模式加入變異度指標`
- `!` 後綴（或 `BREAKING CHANGE:` footer）是 **唯一** 的 major version 觸發條件，請勿輕率使用。

### Release 標記

- 依照 SLA，每兩週發一次 release。
- 在 CI 通過且 `CHANGELOG.md` 已更新後，從 `main` 打 tag。
- Tag 格式為 `vMAJOR.MINOR.PATCH`（例如 `v1.3.0`）。

---

## 行為準則

本專案遵循 **Contributor Covenant v1.4**。簡單來說：

- 歡迎且包容，並預設他人是善意的。
- 不得騷擾、做人身攻擊、使用歧視性語言。
- 批評的是想法，不是人；盡可能用參考資料支持你的主張。
- 維護者有權調整、編輯或移除違反這些原則的留言 / commit / issue / PR，必要時也可以封鎖違規者。

完整內容：<https://www.contributor-covenant.org/version/1/4/code-of-conduct/>

若要私下回報違反行為準則的情況，請寄信到 `robin.hwang@kakaocorp.com`，主旨加上 `[harness-coc]`。

---

## 維護者

| 角色 | 帳號 | 負責領域 |
|------|------|----------|
| Lead maintainer | [@revfactory](https://github.com/revfactory) | 專案方向、發版、最終審查 |
| Contributor | [@hnts03](https://github.com/hnts03) | Skill 範本、韓文文件 |
| Contributor | [@JunghwanNA](https://github.com/JunghwanNA) | Agent 模式、整合測試 |
| Contributor | [@shaun0927](https://github.com/shaun0927) | Tooling、CI、基礎設施 |

若你是持續貢獻者，之後會列在這裡，而不只是一次 PR 就加入。若你想討論 maintainer 路線，也歡迎在 Discussion 裡提出。

---

## 授權

只要你提交貢獻，就表示你同意以與本 repository 相同的授權方式授權你的內容（請見 [`LICENSE`](./LICENSE)）。
