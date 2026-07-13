# Quickstart — 5 分鐘完成你的第一個 Harness

> **時間預算：5 分鐘（嚴格）。** 如果 5 分鐘內你還沒做到 Step 5，請停下來並提交 issue，這是本文檔的 bug，不是你的 bug。

<!-- TODO: Loom embed — 60s screen recording showing Steps 1→5 end-to-end. Replace this comment with the `<iframe>` once recorded. -->

**完成後你會擁有：** 一個可運作的 `.claude/agents/` 目錄，內含 3–5 個針對領域特化的 agents，透過一句話 prompt 產生，並可直接拿來執行範例任務。

**開始前請先確認先決條件：**
- Claude Code **v2.x 或更新版本**（`claude --version` 應回傳 `2.x` 或更高）
- 能在指令之間保留 `export` 的 shell（bash、zsh 或 fish）
- 可連線到 `github.com` 與 `api.anthropic.com`

---

## Step 1 — 加入 marketplace（60 秒）

```bash
claude plugin marketplace add revfactory/harness
```

**這會做什麼：** 註冊 `harness` marketplace，讓 Claude Code 能發現由 `revfactory` 發布的 plugins。

**預期輸出：** `Added marketplace: revfactory/harness`

---

## Step 2 — 安裝 plugin 並啟用 Experimental 旗標（40 秒）

```bash
claude plugin install harness@harness
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

*(若想讓這個旗標在多次 shell session 間持續存在，請把 `export` 那一行加入 `~/.zshrc` 或 `~/.bashrc`。)*

**這會做什麼：** 從 `harness` marketplace 安裝 `harness` plugin，然後啟用 Agent Teams，也就是 harness 用來編排多代理工作流程的 Claude Code API。關於為何需要這個旗標，請參閱 [`docs/experimental-dependency.md`](./experimental-dependency.md)。

**Failure FAQ #1 — `AGENT_TEAMS not found` / teams 無法建立**
**原因：** Claude Code 版本低於 v2.x（Agent Teams 是在 v2.0 才加入）。  
**修正方式：** 執行 `claude --version`。若低於 2.0，請用 `npm i -g @anthropic-ai/claude-code`（或你的發行版安裝方式）升級，然後重新執行 Step 2。

---

## Step 3 — 用一句話產生一個 harness（2 分鐘）

```bash
claude "build a harness for a fintech risk-assessment team"
```

**這會做什麼：** 呼叫 `/harness:harness` meta-skill，分析你的領域描述句，並在目前目錄的 `.claude/agents/` 與 `.claude/skills/` 中建立一組專業 agents 與其對應 skills。

**也可以試試這些替代 prompt** — 都可以運作：
- `claude "請幫我為金融科技風險評估團隊建立 harness"`
- `claude "build a harness for an e-commerce fraud-detection workflow"`
- `claude "design an agent team for technical due diligence on open-source repos"`

**預期輸出：** 畫面會先串流顯示規劃，再確認已寫入 3–5 個 agent `.md` 檔案及其 skills。

**Failure FAQ #2 — 韓文 prompt 沒有回應 / 英文可用但韓文不行**
**原因：** locale 或 tokenizer 路由錯誤；部分語言版本的觸發短語在特定環境下可能比英文更容易失配。  
**修正方式：** 如果非英文 prompt 失敗，請改用上面的英文 prompt 重新執行，底層 skill 是相同的。若仍失敗，直接跳到 Failure FAQ #3。

---

## Step 4 — 驗證產生出的檔案（30 秒）

```bash
ls -la .claude/agents/
ls -la .claude/skills/
```

**這會做什麼：** 確認 meta-skill 已將檔案寫入預期位置。

**預期輸出：** 每個目錄有 3–5 個檔案，名稱會反映你的領域（例如在 fintech 範例中可能是 `risk-analyst.md`、`compliance-reviewer.md`、`portfolio-monitor.md`）。

**Failure FAQ #3 —「沒有產生任何內容」/ 目錄是空的**
**原因：** plugin 實際上未安裝，或在目前專案中未啟用。  
**修正方式：** 執行 `claude plugin list`。若看不到 `harness@harness`，請重做 Step 2。若存在但未啟用，請執行 `claude plugin enable harness@harness`，再重做 Step 3。

---

## Step 5 — 讓新團隊執行一個範例任務（90 秒）

複製一段接近 Jira ticket 風格的真實 prompt，交給你剛建立好的團隊：

```bash
claude "Ticket FIN-427: A new corporate customer (mid-cap manufacturer, \$80M revenue, South Korea) has applied for a \$5M working-capital line. Produce a risk assessment covering (1) credit-history red flags, (2) sector concentration vs. our existing book, (3) regulatory exposure (KFTC, FSC). Output: a 1-page memo with a go/no-go recommendation."
```

**這會做什麼：** Claude Code 會偵測 `.claude/agents/` 中的新 agents，把任務路由到 harness 產生的 team pattern（做風險工作時通常是 Producer-Reviewer 或 Expert Pool），並回傳結構化 memo。

**Failure FAQ #4 —「團隊沒有執行 / 只有一個 agent 回應」**
**原因：** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 只在執行 Step 3 的 shell 中設定，但執行 Step 5 的 shell 沒有設定（常見於新開 terminal）。  
**修正方式：** 在目前 shell 重新執行 `export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`，然後重跑 Step 5。若要永久生效，請把這一行加入你的 shell rc 檔。

**Failure FAQ #5 —「API 呼叫太多 / 很擔心成本」**
**原因：** 多代理團隊可能會對單一任務平行展開 5 次以上 Claude 呼叫。一張複雜 ticket 可能消耗 50K–200K tokens。  
**修正方式：** 每次執行只跑單一任務（不要用 `&&` 連鎖多次 harness 呼叫）；若你的 Claude Code 版本支援，可使用 `--max-turns` 旗標。正式環境中，建議在 harness 呼叫外再包一層具成本意識的 wrapper，請參見 `docs/cost-controls.md` *(forthcoming)*。

---

## 你完成了

此時你應該已經擁有：

- [x] 一個包含領域特化 agents 的 `.claude/agents/` 目錄
- [x] 一個包含其支援 skills 的 `.claude/skills/` 目錄
- [x] 至少一次成功的範例任務執行
- [x] 一個可運作的 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 環境

**接下來可閱讀：**
- [`docs/experimental-dependency.md`](./experimental-dependency.md) — 為何需要此旗標，以及它變動時我們會怎麼做
- [`revfactory/harness-100`](https://github.com/revfactory/harness-100) — 100+ 個預先建立好的領域 harness 目錄，如果你想直接 clone 而不是自行產生
- [`revfactory/claude-code-harness`](https://github.com/revfactory/claude-code-harness) — 我們用來在 15 個任務上測得 +60% 品質的 A/B test harness

**如果你遇到本指南未涵蓋的情況：** 請用 `quickstart-gap` label 開 issue，並附上：(a) 失敗的是哪一步，(b) `claude --version`，(c) 完整錯誤訊息。`quickstart-gap` issue 的 SLA 是 **48 小時內**首次回覆（見 `CONTRIBUTING.md`）。
