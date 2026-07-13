# Experimental Flag 相依性

> **狀態：** 啟用中 · **負責人：** revfactory · **最後更新：** 2026-04-18 · **SLA：** 請參閱[監控承諾](#監控承諾)

本文件說明為何 `harness` 需要 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`、此旗標可能出現的三種合理未來情境，以及本儲存庫在各情境下將採取的對應措施，並搭配有時限的承諾，方便企業採用者據以規劃。

---

## 目前狀態

### 為什麼需要這個旗標

`harness` 是建立在 Claude Code **Agent Teams API** 之上的 meta-skill 工廠。每當使用者執行 `claude "build a harness for <domain>"` 時，Claude Code 內部都會呼叫三個原語：

| 原語 | 用途 | 受旗標控管？ |
|-----------|---------|-------------|
| `TeamCreate` | 建立具有共享上下文的多代理團隊 | **是** |
| `SendMessage` | 在團隊成員之間路由訊息（supervisor ↔ worker） | **是** |
| `TaskCreate` | 在團隊內建立長時間執行的子任務 | **是** |
| `Agent` tool (invoke) | 單代理派送 | 否（GA） |

上述三個受旗標控管的原語都需要：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

如果在啟動 `claude` 的 shell 中沒有設定這個變數，harness 產生的團隊就會退回單代理執行，並且悄悄破壞 Pipeline / Fan-out-in / Supervisor / Hierarchical Delegation 這些模式。

### Anthropic 參考資料（提交 issue 前請先閱讀）

這個旗標的設計理由與發展路線圖，記錄在三篇 Anthropic Engineering 文章中。評估是否導入 harness 的使用者，至少應先閱讀第一篇：

1. [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — 定義 Anthropic 所背書的「harness」類別，以及長時間執行代理的契約。
2. [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) — 說明 `harness` 所具體化的模式（Pipeline、Producer-Reviewer、Supervisor 等）。
3. [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents) — 可能取代 Experimental 旗標的後續方向（見情境 B）。

---

## 相依關係圖

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

**請由上往下閱讀這張圖：** harness 依賴 Agent Teams API，Agent Teams API 依賴單一 Experimental 旗標，而這個旗標又受 Anthropic 自身路線圖影響。只要任一上游節點改變，本儲存庫就有責任在下述 SLA 期限內完成調整。

---

## 三種情境

每個情境都列出 **偵測觸發條件**（我們如何知道事情發生了）、本儲存庫承諾的 **T+24h / T+48h / T+72h 行動**，以及每個檢查點可見的 **使用者可見產出**。

### 情境 A — 旗標移除（Agent Teams 升級為 GA）

**觸發偵測：** Anthropic Claude Code Changelog 發布「Agent Teams is now GA」，**或是** `claude-code` binary 已不再需要 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`（由 [P-13](#) 的 nightly CI 偵測）。

**機率（主觀）：** 高 — 上面三篇文章所透露的方向就是這條路。

| 檢查點 | 行動 | 產出 |
|------------|--------|----------|
| **T+24h** | 開啟 `feat/drop-experimental-flag` 分支。從所有 README / docs / Quickstart 移除 `export` 行。在 `plugin.json` 補上 `claude-code >= X.Y.Z` 的最低版本限制。 | 分支 + PR（draft） |
| **T+48h** | 發布 `docs/migrating-from-experimental.md`。將 `docs/experimental-dependency.md`（本檔）標題更新為「自 vX.Y 起不再需要旗標」。釘選 GitHub issue：「Action required: drop the export line」。 | 遷移指南 + 釘選 issue |
| **T+72h** | 發布 **v1.3.0** 版本，內容包含：(a) CHANGELOG 條目，(b) `gh release create` 與遷移說明，(c) HN 後續貼文：「We dropped the experimental flag」。 | `v1.3.0` git tag + GH Release |

**對採用者的影響：** 正面。企業審核阻力下降，因為「不得使用 experimental flags」這個條件將可被滿足。對 harness 使用者的程式碼不會造成破壞性變更。

---

### 情境 B — Managed Agents 達到 GA（平行路線）

**觸發偵測：** Anthropic 發布「[Managed Agents](https://www.anthropic.com/engineering/managed-agents) 已正式可用」，並提供穩定的 `claude-agents` CLI 或 SDK 介面。

**機率（主觀）：** 90 天內中高。Managed Agents 是伺服器端執行模型；harness 的用戶端團隊編排方式**不會**自動轉換過去。

| 檢查點 | 行動 | 產出 |
|------------|--------|----------|
| **T+24h** | 開啟 `feat/managed-agents-compat` PR。新增 `adapters/managed-agents/` 骨架，把 harness 的 6 種 team pattern 對應到 Managed Agents 的呼叫方式。標記不相容的模式（很可能是 Hierarchical Delegation）。 | 相容性 PR（draft） |
| **T+48h** | 在 Dev.to 與 repo 發布文章：**"Harness + Managed Agents: one layer up, not replaced"**。把 harness 重新定位為輸出 Managed Agents 設定的**設計期**層，而不是執行期競爭者。 | 共存定位文章 |
| **T+72h** | 發布 `docs/managed-agents-migration.md`，提供逐 pattern 對照矩陣（6 種模式哪些可 1:1 對應、哪些需要改寫）。更新 README 中的 sibling-repo 區塊。 | 遷移指南 |

**策略說明：** harness 將重新定位為 **Managed Agents 之上的上層**，也就是「Managed Agents 負責執行團隊，harness 負責設計團隊」。這就是 GTM 計畫 §4.2 的共存框架。

**對採用者的影響：** 中性偏正面。現有 harness 使用者可繼續沿用 Experimental 旗標路線；新使用者則可選擇輸出 Managed Agents。

---

### 情境 C — 破壞性變更（API 簽章變動）

**觸發偵測：** nightly CI（`.github/workflows/nightly-compat.yml`，路線圖編號 P-13）在 Claude Code 最新 nightly build 上失敗，**或是** Changelog 宣告環境變數改名 / `TeamCreate` 簽章變更。

**機率（主觀）：** 中等。Experimental API 可能在沒有棄用期的情況下被重新命名。

| 檢查點 | 行動 | 產出 |
|------------|--------|----------|
| **T+0 到 T+24h** | Nightly CI 警報會送到 Slack/Discord。作者開啟 `hotfix/compat-<date>` 分支，修補受影響的呼叫位置。盡最大努力讓舊版與新版簽章的單元測試都能通過。 | Hotfix 分支 |
| **T+24h** | 合併 hotfix。推送 `v1.2.x` patch tag。更新 `docs/compatibility-matrix.md` 中受影響 Claude Code 版本的對應列。 | `v1.2.x` patch 版本 |
| **T+72h** | 若變更較不單純（會影響 harness 對外契約），就在 repo 的 Discussions 分頁與 X 發布短公告；否則 CHANGELOG 條目即可。 | Discussions 公告（條件式） |

**對採用者的影響：** 鎖定舊版 Claude Code 的既有使用者不受影響；使用最新版的使用者會在同一週收到修補版本。

---

## 監控承諾

我們承諾以下**可觀察的 SLA**。若未達成，使用者可以 `sla-breach` label 提交 issue。

| 事件 | SLA | 測量方式 |
|-------|-----|-------------|
| Anthropic 在官方 Changelog 發布 Agent Teams / Managed Agents 變更 | 本文件於 **72 小時內**更新 | 比對 Changelog 貼文時間戳與本檔 `Last updated` 行 |
| Nightly CI 偵測到相容性中斷 | **24 小時內**開出 hotfix 分支 | GitHub Actions 執行時間戳 vs. 分支建立時間戳 |
| 新的 Claude Code 穩定版（minor 或 major）發布 | **7 天內**在 `docs/compatibility-matrix.md` 新增對應列 | Compatibility matrix diff |

**我們主動監控的來源：**

- Claude Code release notes — 透過 [Anthropic Engineering blog](https://www.anthropic.com/engineering) RSS 追蹤
- `anthropics/claude-code` GitHub Releases（nightly tag）
- Anthropic Discord `#claude-code` 頻道（社群訊號）

---

## 給企業採用者的 FAQ

### Q1. 我們屬於受監管產業（金融、醫療、公部門），不能在正式環境啟用 `EXPERIMENTAL` 旗標。要如何採用 harness？

**原因：** 許多合規框架（SOC 2 Type II、ISO 27001、K-ISMS）不允許在正式環境使用不穩定 / 預覽功能。  
**做法：** 把 harness 只用在**設計期**：在 sandbox 工作站中執行它，來產生 `.claude/agents/` 與 `.claude/skills/` 檔案，然後把產出的成品提交到正式 repo。正式環境中的 Claude Code 不需要這個旗標，只有受旗標控管的 `TeamCreate` 執行期才需要。產生出的單代理 skill 與 GA 路徑相容。

### Q2. 如果 Agent Teams 之後 GA（情境 A），我現有由 harness 產生的程式碼會壞掉嗎？

**原因：** 依 Anthropic Claude Code 過往經驗，GA 升級通常不會破壞產生出的成品；只是旗標不再需要。  
**做法：** 終端使用者無需採取動作。你的 `.claude/agents/*.md` 與 `.claude/skills/*` 都是純 Markdown，仍然有效。GA 當天你就能 `unset CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`。我們會在 48 小時內發布遷移說明（見情境 A）。

### Q3. 你們是否提供書面的 SLA 保證？若沒做到怎麼辦？

**原因：** 企業在批准前，通常需要契約化或至少可觀察的承諾。  
**做法：** 上述 SLA 表格就是**公開承諾**，並透過以下機制執行：(a) 若在偵測到 Changelog 事件後超過 72 小時仍未更新本檔，GitHub Action 會在此文件留言提醒，(b) 採用者可套用 `sla-breach` issue label，(c) 任何違反情況都必須在 `CONTRIBUTING.md` 中進行事後檢討。這不是付費 SLA，而是社群承諾。若需要付費 SLA，請聯絡維護者（見 repository README）。

---

**相關文件：**
- [`docs/quickstart.md`](./quickstart.md) — 5 分鐘安裝導覽
- [`docs/show-hn-launch-kit.md`](./show-hn-launch-kit.md) — 公開發布套件
- `docs/compatibility-matrix.md` *(pending P-13)* — Claude Code × harness 版本對照表
