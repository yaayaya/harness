# GitHub Trending 整合發布計畫 — Harness

> **專案**: Harness — Agent Team & Skill Architect (Claude Code Plugin)
> **GitHub**: https://github.com/revfactory/harness
> **撰寫日期**: 2026-03-29
> **發布目標日**: 2026-04-07（星期二）
> **撰寫依據**: 綜合 repo-auditor、content-creator、community-scout 的產出

---

## 1. 策略摘要

### 目標
- **Primary**: 打進 GitHub Trending（All Languages）Top 25
- **Secondary**: 拿下 GitHub Trending（Markdown / Misc）#1
- **Stretch**: 在 Hacker News Front Page 停留 12 小時以上

### 目標類別
- GitHub Trending: `All Languages` + `Unknown languages`（由於是以 Markdown 為主的 repo，語言分類很可能會被判定為 Unknown/Misc）
- Hacker News: `Show HN`
- Product Hunt: `AI Coding Agents` / `Developer Tools`

### 核心 KPI

| 指標 | D-Day +6h | D-Day +24h | D+3 | D+7 | D+14 |
|------|-----------|------------|-----|-----|------|
| GitHub Stars | 100+ | 300+ | 500+ | 800+ | 1,200+ |
| Star Velocity (stars/h) | 15-20 | 10-15 | 5-8 | 3-5 | 2-3 |
| Forks | 10+ | 30+ | 50+ | 80+ | 120+ |
| HN Points | 50+ | 100+ | — | — | — |
| Twitter Impressions | 10k+ | 50k+ | 100k+ | — | — |

### 發布日期選擇依據
- **選定星期二（2026-04-07）**
  - 週二到週四是最適合打進 GitHub Trending 的日期區間（可在週末流量下滑前先建立動能）
  - 排除星期一：週初工作量較高，開發者注意力分散
  - 與 HN 最佳發文時段相比，星期二最吻合
  - D-7 = 3/31（星期二），準備期以平日為主，作業效率較高

---

## 2. D-7 ~ D-1：Pre-Launch Prep

### D-7（3/31 週二）— Repo 核心最佳化

| # | 動作 | 依據 | 完成標準 | 時間 |
|---|------|------|-----------|------|
| 1 | **建立 GitHub Releases**（v1.0.0, v1.0.1） | Audit R4 — 側邊欄信任訊號，ROI 最高 | Release 頁面可看到 2 個 release，包含 CHANGELOG 內容 | 30 分鐘 |
| 2 | **設定 GitHub Topics** | Audit R9 — 搜尋 / Explore 曝光關鍵 | 完成設定 `claude-code`, `claude-code-plugin`, `agent-team`, `ai-agent`, `llm`, `skill-generation`, `orchestration`, `claude` | 10 分鐘 |
| 3 | **設定 Repo Description** | Audit R13 — 搜尋結果曝光最佳化 | "Agent Team & Skill Architect — A Claude Code Plugin that designs domain-specific agent teams and generates skills" | 5 分鐘 |
| 4 | **上傳 Social Preview 圖片** | Audit R14 — 社群分享時的視覺衝擊 | 完成上傳 1280×640px OG 圖片 | 30 分鐘 |
| 5 | **部署 GitHub Pages** | Audit R12 — 上線 landing page + 信任訊號 | 可連上 `revfactory.github.io/harness` | 20 分鐘 |
| 6 | **在 Repo About 設定網站 URL** | Audit R15 | 連結到 Pages URL | 5 分鐘 |

**D-7 所需時間**: 約 2 小時
**D-7 效果**: Score 5.5 → 7.0（Discoverability 大幅提升）

### D-6（4/1 週三）— 社群基礎建設

| # | 動作 | 依據 | 完成標準 | 時間 |
|---|------|------|-----------|------|
| 7 | **新增 Issue Templates**（`bug_report.yml`, `feature_request.yml`） | Audit R5 | `.github/ISSUE_TEMPLATE/` 內有 2 個檔案 | 30 分鐘 |
| 8 | **新增 PR Template** | Audit R6 | 建立 `.github/PULL_REQUEST_TEMPLATE.md` | 15 分鐘 |
| 9 | **撰寫 CONTRIBUTING.md** | Audit R7 — 吸引新訪客參與的關鍵 | 包含 bug report、PR guide、開發環境區段 | 30 分鐘 |
| 10 | **新增 CODE_OF_CONDUCT.md** | Audit R8 | 套用 Contributor Covenant 範本 | 10 分鐘 |
| 11 | **將 README 的 "Quick Start" 區段重新命名** | Audit R2 | 安裝區段 → "Quick Start"（≤5 步，第一步為 one-liner） | 15 分鐘 |
| 12 | **在 README 新增 "Contributing" 區段** | Audit R3 | 包含 CONTRIBUTING.md 連結 | 10 分鐘 |

**D-6 所需時間**: 約 2 小時
**D-6 效果**: Score 7.0 → 7.5（Repo Structure 大幅改善）

### D-5（4/2 週四）— 信任訊號與 CI

| # | 動作 | 依據 | 完成標準 | 時間 |
|---|------|------|-----------|------|
| 13 | **新增 GitHub Actions CI workflow** | Audit R10 — 綠色 CI badge 是強力信任訊號 | Markdown lint + plugin.json 驗證 + 在 README 加上 badge | 1 小時 |
| 14 | **新增基本有效性驗證測試** | Audit R11 | plugin.json schema 驗證、確認 `SKILL.md` 存在、驗證 references 目錄 | 1 小時 |

**D-5 所需時間**: 約 2 小時
**D-5 效果**: Score 7.5 → 8.0（Trust Signals 顯著改善）

### D-4（4/3 週五）— 內容準備與前期關係建立

| # | 動作 | 分類 | 完成標準 | 時間 |
|---|------|------|-----------|------|
| 15 | **製作 Demo GIF/Screencast** | Audit R1 — 對 3 秒判斷至關重要 | 執行 "build a harness" → 顯示 Agent Team 生成過程的 30-60 秒 GIF | 2 小時 |
| 16 | **將 Demo GIF 放到 README 頂部** | | 放在 tagline 正下方 | 15 分鐘 |
| 17 | **準備 3-4 張 Twitter/X thread 圖片** | Content #3 | workflow diagram、A/B 結果圖表、architecture pattern cards | 1 小時 |
| 18 | **最終校對所有內容文字** | | 檢查 HN/Reddit/Twitter/Dev.to 草稿的文法與連結 | 30 分鐘 |
| 19 | **開始聯繫 Product Hunt hunter** | Scout — PH 發布必備 | 私訊 2-3 位 hunter，分享預計發布日期 | 30 分鐘 |
| 20 | **預先私訊 influencer** | Scout Tier 1 KOL | 向 Nick Saraev、Boris Cherny 傳送事前介紹訊息 | 30 分鐘 |

**D-4 所需時間**: 約 5 小時（工作量最大的一天）

### D-3 ~ D-2（4/4~4/5 週六~週日）— 最終檢查與支持者準備

| # | 動作 | 完成標準 | 時間 |
|---|------|-----------|------|
| 21 | **確認 harness-100 repo 已公開** | README 已整理，連結可正常運作 | 30 分鐘 |
| 22 | **確認 claude-code-harness（研究 repo）已公開** | 可存取 A/B 測試資料 / 論文 | 30 分鐘 |
| 23 | **建立初期支持者群組** | 邀請 5-10 位同事 / 熟人於發布日協助 star/upvote。考量時區，確保可在 KST 晚間~夜間時段參與的人數 | 1 小時 |
| 24 | **預先準備 HN 常見問題回答** | 關於方法論限制、與其他工具比較、可否泛化等，先擬 5-7 組 Q&A | 1 小時 |
| 25 | **確認 Anthropic Discord 帳號活躍狀態** | 確認可進入 #showcase 頻道 | 15 分鐘 |

### D-1（4/6 週一）— 最終彩排

| # | 動作 | 完成標準 | 時間 |
|---|------|-----------|------|
| 26 | **最終檢查整體 checklist**（參見 Section 8） | 所有 Pre-Launch 項目皆已勾選 | 30 分鐘 |
| 27 | **最終確認 GitHub Pages 已上線** | landing page 可開啟 + 多語切換正常 | 10 分鐘 |
| 28 | **把各平台發文內容複製到文字編輯器** | 完成複製貼上準備（避免格式跑掉） | 20 分鐘 |
| 29 | **更新 Twitter 個人簡介** | 加入 Harness 說明 | 5 分鐘 |
| 30 | **設定鬧鐘** | D-Day 起床鬧鐘（KST 16:00 = UTC 07:00） | 5 分鐘 |

---

## 3. D-Day：Launch Execution（4/7 週二）

### 時段策略

核心原則：**美國早晨（UTC 13:00-16:00 = PST 6-9am = EST 9am-12pm）是 HN/Reddit 流量高峰**。但 HN 需要**提早幾小時發文，才能讓登上 Front Page 的時間點剛好對上高峰**。換算成 KST，就是傍晚到深夜。

| 時間（UTC） | 時間（KST） | 平台 | 動作 | 預期效果 | Plan B |
|-----------|-----------|--------|------|-----------|--------|
| **07:00** | **16:00** | GitHub | 最終確認 README、demo GIF 是否正常 | 基本檢查 | — |
| **08:00** | **17:00** | **Hacker News** | 發布 Show HN 貼文（Content #1 文字） | HN New → Rising。透過初期 2-3 個 upvote 進入 Rising | 若發文時機不佳，改在 UTC 12:00 重新發（HN 允許重發） |
| **08:15** | **17:15** | **初期支持者** | 在支持者群組分享 HN 連結 + GitHub 連結 | 初期 5-10 stars + 2-3 HN upvotes（臨界動能） | 若支持者不足，動用個人網路補強 |
| **08:30** | **17:30** | **Twitter/X** | 發布發布 thread（Content #3, Tweet 1-9），並將 Tweet 1 置頂 | 追蹤者初期 engagement、retweet 擴散 | 若 thread 互動偏低，就把核心推文單獨重發 |
| **09:00** | **18:00** | **r/ClaudeAI** | 發布 Reddit 貼文（Content #2a） | 最 receptive 的目標社群，目標 50+ upvotes | 若貼文被刪，詢問 moderator 後調整語氣再重發 |
| **09:00** | **18:00** | **r/SideProject** | 發布 Reddit 貼文（Scout Reddit 範本 D） | 容許自我宣傳的社群，安全取得初期 traction | — |
| **09:30** | **18:30** | **r/opensource** | 發布 Reddit 貼文 | 曝光於開源社群 | — |
| **10:00** | **19:00** | **r/programming** | 發布 Reddit 貼文（Content #2c） | 接觸更廣泛的開發者受眾。為避免 spam flag，與前一篇間隔 1 小時 | 若被刪除，改寫成更強調技術價值的版本 |
| **10:00** | **19:00** | **Product Hunt** | 啟動 PH 發布（hunter 或親自上）— 分類為 "AI Coding Agents" | 目標 PH Daily Top 5 | 若尚未找到 hunter，就自行發布並立刻補上 Maker comment |
| **10:30** | **19:30** | **Anthropic Discord** | 在 #showcase 頻道分享專案 | 直接觸及 Claude 社群 | 改用 #community-projects 作為替代頻道 |
| **12:00** | **21:00** | **Dev.to** | 發布技術部落格文章（Content #4） | 長期 SEO、搜尋流量導入 | — |
| **12:00** | **21:00** | **HN 監控** | 確認是否進入 Front Page，開始回覆留言 | 留言互動是 HN 排名關鍵 | 若未進 Front Page → 集中火力在 Reddit/Twitter |
| **13:00-18:00** | **22:00-03:00** | **全平台** | 即時監控 + 回覆留言（詳見下方） | 美國尖峰時段，最關鍵的 6 小時 | 若體力不足，只專注核心平台（HN + r/ClaudeAI） |
| **14:00** | **23:00** | **Awesome Lists Tier 1** | 提交 awesome-claude-code（hesreallyhim）issue + jqueryscript PR + awesome-claude-skills PR 共 2 件 | 與 trending 同步送出 PR，可最大化核准機率 | — |

### 即時監控指標與臨界值

| 指標 | 檢查週期 | 綠色（正常） | 黃色（注意） | 紅色（緊急） |
|------|----------|------------|------------|------------|
| Star velocity | 30 分鐘 | >10 stars/h | 5-10 stars/h | <5 stars/h |
| HN rank | 30 分鐘 | Front Page（1-30） | Page 2（31-60） | Page 3+ |
| HN comments | 1 小時 | 5+ comments/h | 2-4 comments/h | <2 comments/h |
| Reddit upvotes（r/ClaudeAI） | 1 小時 | 50+ | 20-50 | <20 |
| Twitter thread impressions | 2 小時 | 5k+ | 1-5k | <1k |

### 緊急應對情境（Plan B）

| 情境 | 觸發條件 | 立即應對 |
|---------|--------|----------|
| HN 發文後 3 小時內仍未進入 Front Page | UTC 11:00 時 Points < 10 | 集中火力在 Reddit/Twitter。HN 可考慮隔天重發 |
| Reddit 貼文被刪除 | 收到 moderator 移除通知 | 重新確認該 subreddit 規則 → 調整語氣後以 modmail 請求重新審核 |
| Star velocity < 5/h（全通路） | D-Day +6h 時點 | 緊急私訊 influencer（Nick Saraev、Boris Cherny）+ 第二波動員支持者 |
| 出現大量負面留言 | 批評留言達 3 則以上 | 立即禮貌回應。承認技術限制 + 分享 roadmap。絕對不要採取防衛姿態 |

---

## 4. D+1 ~ D+3：Amplification

### D+1（4/8 週三）

| 時間（UTC） | 動作 | 平台 | 觸發條件 |
|-----------|------|--------|------------|
| 08:00 | **r/MachineLearning 貼文**（Content #2b — 研究導向） | Reddit | 無條件執行 |
| 10:00 | **Twitter Quote-tweet**: "研究結果最讓人驚訝的部分是..." — 強調 scaling insight | Twitter/X | 無條件執行 |
| 10:00 | **提交 Ben's Bites 社群投票** | Newsletter | 無條件執行 |
| 12:00 | **Anthropic Discord 後續貼文** — 分享社群反應 | Discord | 達成 100+ Stars 時 |
| 14:00 | **深入回覆 HN 留言** — 詳細回答技術問題 | HN | HN 仍停留 Front Page 時 |
| Ongoing | **所有 GitHub Issues 在 24 小時內回覆** | GitHub | 收到 issue 時 |

### D+2（4/9 週四）

| 時間（UTC） | 動作 | 平台 | 觸發條件 |
|-----------|------|--------|------------|
| 08:00 | **接觸 TLDR AI / TLDR Open Source 編輯團隊** | Email | 若 Stars 200+，可加強 pitch |
| 10:00 | **接觸 The Rundown AI 編輯團隊** | Email | 無條件執行 |
| 10:00 | **提交 Console.dev** | Web | 無條件執行 |
| 12:00 | **轉貼到 r/LocalLLaMA**（技術深度版） | Reddit | 若 r/ClaudeAI 反應正向 |
| 14:00 | **發文到 r/artificial** | Reddit | 無條件執行 |

### D+3（4/10 週五）

| 時間（UTC） | 動作 | 平台 | 觸發條件 |
|-----------|------|--------|------------|
| 08:00 | **Twitter: "100 harnesses" 獨立貼文** — 介紹 companion repo | Twitter/X | 無條件執行 |
| 10:00 | **提交 Changelog Weekly** | Newsletter | 無條件執行 |
| 12:00 | **提交 AI Tool Report** | Newsletter | 無條件執行 |
| 14:00 | **在 Star History 註冊專案** + 把 star graph 嵌入 README | GitHub/Web | 若 Stars 300+，圖表會更有說服力 |
| Ongoing | **里程碑推文**: "Launched 3 days ago → X stars" | Twitter/X | 達成 500+ Stars 時 |

---

## 5. D+4 ~ D+14：Sustain

### D+4 ~ D+7（4/11~4/14）

| 日期 | 動作 | 平台 |
|------|------|--------|
| D+4（週六） | **提交 Awesome Lists Tier 2 PR**: awesome-llm-agents, awesome-agents, awesome-ai-agents, awesome-ai-agents-2026, Awesome-Prompt-Engineering | GitHub |
| D+5（週日） | **Dev.to 後續文章**: "5 Architecture Patterns for AI Agent Teams"（常青內容） | Dev.to |
| D+5 | **接觸 YouTube 創作者**: Nick Saraev（最高優先）、Sabrina Ramonov、freeCodeCamp | Email/DM |
| D+6（週一） | **確認 Trendshift badge 並嵌入 README** | GitHub |
| D+7（週二） | **每週里程碑推文**: "Week 1: X stars, Y forks, Z countries" + Star History 圖表 | Twitter/X |
| D+7 | **登錄 awesomeclaude.ai** | Web |

### D+8 ~ D+14（4/15~4/21）

| 日期 | 動作 | 平台 |
|------|------|--------|
| D+8~10 | **提交 Awesome Lists Tier 3 PR**: jim-schwoebel, webfuse-com, BehiSecc, alvinunreal | GitHub |
| D+10 | **接觸 Superhuman AI、The Neuron 電子報** | Email |
| D+10 | **r/MachineLearning 專案 showcase 後續貼文**（加入實際使用案例 + 吸收社群回饋） | Reddit |
| D+12 | **Twitter：使用者回饋精選 thread** — "Here's what people are building with Harness" | Twitter/X |
| D+14 | **兩週里程碑推文** + 分享 roadmap（下一版本規劃） | Twitter/X |
| Ongoing | **持續在 48 小時內回覆所有 GitHub Issues/PR** | GitHub |
| Ongoing | **回覆所有 Twitter 提及 / 引用** | Twitter/X |

### 長期社群維繫原則

1. **Issue 24-48 小時回覆規則**：在 Trending 之後，新訪客第一次開 issue 時，快速回應是建立社群的關鍵
2. **標記 "Good First Issue"**：有意識地創造簡單的貢獻機會，吸引 contributor 加入
3. **持續更新 CHANGELOG**：每次 release 都寫詳細 notes，建立專案活躍印象
4. **每月更新貼文**：把進度分享至 r/ClaudeAI + Twitter

---

## 6. 成功指標

### Star Velocity 目標（依時段）

| 時點 | 累積 Stars | Velocity (stars/h) | Trending 臨界標準 |
|------|-----------|-------------------|-------------------|
| D-Day +2h | 20-30 | 10-15 | 開始進入 |
| D-Day +6h | 80-120 | 15-20 | Daily Trending 候選 |
| D-Day +12h | 150-200 | 10-15 | 進入 Daily Trending |
| D-Day +24h | 250-350 | 8-12 | 在 Daily Trending 站穩 |
| D+2 | 400-500 | 5-8 | Weekly Trending 候選 |
| D+3 | 500-600 | 4-6 | 進入 Weekly Trending |
| D+7 | 700-900 | 2-4 | 維持 Weekly Trending |
| D+14 | 1,000-1,500 | 1-3 | Monthly Trending |

### 綜合成功指標

| 指標 | D-Day | D+3 | D+7 | D+14 | 備註 |
|------|-------|-----|-----|------|------|
| **GitHub Stars** | 300+ | 500+ | 800+ | 1,200+ | 核心指標 |
| **GitHub Forks** | 30+ | 50+ | 80+ | 120+ | 實際使用 proxy |
| **GitHub Trending 排名** | Top 50 | Top 25 | 維持 Top 25 或再次進榜 | — | Primary 目標 |
| **HN Points** | 100+ | — | — | — | Front Page 約等於 ~50+ points |
| **HN Comments** | 30+ | — | — | — | Engagement 深度 |
| **Product Hunt Rank** | Top 10 | — | — | — | Daily rank |
| **Reddit Total Upvotes** | 200+ | 400+ | — | — | 全部 subreddit 合計 |
| **Twitter Impressions** | 50k+ | 100k+ | 150k+ | — | thread + mentions |
| **Awesome List PRs Merged** | 2+ | 4+ | 6+ | 8+ | 長期可發現性 |
| **GitHub Issues Opened** | 5+ | 10+ | 20+ | 30+ | 社群健康指標 |
| **Contributors** | 1 | 2+ | 3+ | 5+ | 社群形成 |

---

## 7. 風險與緩解

| # | 風險 | 機率 | 影響 | 緩解策略 |
|---|--------|------|------|-----------|
| 1 | **HN 無反應** — Show HN 無法打進 Front Page | 中 | 高 | HN 本身帶有賭博性。若失敗就把火力集中在 Reddit/Twitter。也可考慮在 D+2~3 重發。另可參與 "Ask HN: What are you working on?" 月度討論串 |
| 2 | **Reddit 自我宣傳貼文被刪** — moderator 移除貼文 | 中 | 中 | 依各 subreddit 調整語氣（r/ClaudeAI 著重使用案例、r/programming 著重技術價值、r/MachineLearning 著重研究）。若發布前一週已有正常參與紀錄會更有利 |
| 3 | **Star velocity 不足** — 未達 Trending 門檻（D-Day +12h 時 < 100 stars） | 中 | 高 | Plan B：緊急私訊 influencer + 第二波支持者動員 + 活用亞洲時區（韓國 / 日本）社群。已有日文 README，可在日本開發者社群（Zenn、Qiita）發布日文貼文 |
| 4 | **負面技術回饋** — "這不就是 prompt 嗎？"、"A/B 測試方法論可疑" | 中 | 中 | 以預先準備的 Q&A 禮貌且技術性地回應。誠實承認限制，但以實際結果數據支撐。"You're right that X is a limitation — here's what we're working on for v2" |
| 5 | **Product Hunt 成績不佳** — 無法進 Daily Top 10 | 中 | 低 | PH 是輔助通路。即使表現不佳，也不會直接影響 GitHub Trending。與其糾結 PH，不如專注 HN/Reddit |
| 6 | **競品同日發布** — 同一天有相似 AI agent 工具打進 Trending | 低 | 中 | 強調 Harness 的差異化（meta-skill、A/B 研究結果、100 個預建範例）。預先準備好能清楚說明差異的留言 |
| 7 | **作者時區不利** — KST 與美國尖峰時段有 12-14 小時落差，導致即時回應延遲 | 高 | 中 | 規劃 D-Day 晚上到凌晨集中監控（KST 17:00 ~ 03:00 = UTC 08:00 ~ 18:00）。D+1 上午開始補回留言。睡前先留一則 "I'll respond to all questions in the morning" |
| 8 | **GitHub 服務故障** — 發布當天 GitHub 當機 / 過慢 | 低 | 高 | 事前監控 githubstatus.com。若故障就延到隔天發布。內容都已備妥，可直接再利用 |

---

## 8. 最終檢查清單

### Pre-Launch（D-1 前完成）

**Repo 最佳化**
- [ ] 建立 GitHub Releases v1.0.0、v1.0.1
- [ ] 設定 8 個 GitHub Topics
- [ ] 設定 Repo Description
- [ ] 上傳 Social Preview 圖片（1280×640）
- [ ] 部署 GitHub Pages + 在 About 設定 URL
- [ ] 新增 Issue Templates（bug_report.yml, feature_request.yml）
- [ ] 新增 PR Template
- [ ] 撰寫 CONTRIBUTING.md
- [ ] 新增 CODE_OF_CONDUCT.md
- [ ] 新增 CI workflow + 綠色 badge
- [ ] 新增有效性驗證測試
- [ ] 將 README 的 "Quick Start" 區段重新命名
- [ ] 在 README 新增 "Contributing" 區段
- [ ] 製作 demo GIF + 放到 README 頂部

**內容**
- [ ] 準備 HN Show HN 最終版本文字
- [ ] 完成 4 種 Reddit 貼文最終稿（r/ClaudeAI, r/programming, r/SideProject, r/opensource）
- [ ] 準備 Twitter/X 9 則推文 + 3-4 張圖片
- [ ] 完成 Dev.to 文章最終稿
- [ ] 完成 Product Hunt 發布頁草稿（tagline, description, images）
- [ ] 確認所有內容連結都能正常運作

**外聯**
- [ ] 找到 Product Hunt hunter（或決定自行發布）
- [ ] 已向 Nick Saraev、Boris Cherny 發出預先 DM
- [ ] 確保有 5 到 10 位初期支持者，並確認 D-Day 當天可參與
- [ ] 完成 5-7 組 HN 預期問題 Q&A 草稿
- [ ] 確認可存取 Anthropic Discord

**Repo 聯動**
- [ ] 公開 harness-100 repo + 整理 README
- [ ] 公開 claude-code-harness（研究 repo）
- [ ] 確認 3 個 repo 之間的 cross link 正常
- [ ] 更新 Twitter 個人簡介

### D-Day（4/7 週二）

**發文順序**
- [ ] UTC 08:00 — 發 HN Show HN
- [ ] UTC 08:15 — 向支持者群組分享連結
- [ ] UTC 08:30 — 發 Twitter/X thread + 置頂
- [ ] UTC 09:00 — 發 r/ClaudeAI + r/SideProject
- [ ] UTC 09:30 — 發 r/opensource
- [ ] UTC 10:00 — 發 r/programming + Product Hunt
- [ ] UTC 10:30 — 發 Anthropic Discord #showcase
- [ ] UTC 12:00 — 發 Dev.to 文章
- [ ] UTC 14:00 — 提交 Awesome Lists Tier 1 PR/issue（4 件）

**監控**
- [ ] 每 30 分鐘檢查一次 Star velocity
- [ ] 每 30 分鐘檢查一次 HN rank
- [ ] 每 1 小時檢查一次 Reddit upvotes
- [ ] 所有留言在 1 小時內回覆
- [ ] 立即回覆 GitHub Issues

### Post-Launch（D+1 ~ D+14）

- [ ] D+1：發 r/MachineLearning 貼文 + Twitter QT + 提交 Ben's Bites
- [ ] D+2：聯繫 TLDR/Rundown/Console.dev
- [ ] D+3：發 "100 harnesses" 獨立貼文 + 提交 Changelog + 登錄 Star History
- [ ] D+4：提交 Awesome Lists Tier 2 的 5 件 PR
- [ ] D+5：發布 Dev.to 後續文章 + 聯繫 YouTube 創作者
- [ ] D+7：發每週里程碑推文
- [ ] D+8~10：提交 Awesome Lists Tier 3 的 4 件 PR + 接觸 Tier 3 電子報
- [ ] D+14：分享兩週里程碑 + roadmap

---

## 連鎖效果（Cascade）設計

```
D-Day 08:00  HN Show HN ──────────────┐
D-Day 08:30  Twitter Thread ────────────┤
D-Day 09:00  Reddit (r/ClaudeAI) ───────┤
D-Day 10:00  Product Hunt ──────────────┤
                                        ▼
                              初期 Star Velocity
                              (3 小時內 30-50 stars)
                                        │
                                        ▼
                              GitHub Trending 演算法偵測
                              （Daily Trending 候選）
                                        │
                          ┌─────────────┼─────────────┐
                          ▼             ▼             ▼
                    Trendshift       Alpha Signal   GitNews
                    自動收錄         自動追蹤       自動收錄
                          │             │             │
                          ▼             ▼             ▼
                    第二波流量導入 → Star Velocity 加速
                                        │
                                        ▼
                              穩定打進 GitHub Trending
                              (Top 25)
                                        │
                          ┌─────────────┼─────────────┐
                          ▼             ▼             ▼
                    TLDR AI 收錄    電子報精選     Awesome List
                    (D+2~3)        (D+3~7)       加速 PR 核准
                          │             │             │
                          ▼             ▼             ▼
                    第三波流量 → 建立長期可發現性 → 1,000+ Stars
```

**核心**：每一階段都扮演下一階段的觸發條件。前 24 小時的 Star velocity，是整體連鎖反應能否被點燃的關鍵。

---

## 執行摘要

| 階段 | 期間 | 核心目標 | 成功標準 |
|------|------|----------|----------|
| **Pre-Launch** | D-7 ~ D-1 | Repo Score 5.5 → 8.0 | Checklist 100% 完成 |
| **Launch** | D-Day | 達成 Star velocity > 10/h | 24 小時內 300+ stars |
| **Amplification** | D+1 ~ D+3 | 打進 Trending + 第二波擴散 | 進入 Top 25 + 500+ stars |
| **Sustain** | D+4 ~ D+14 | 建立長期可發現性 | 1,200+ stars + Awesome List 8+ merged |

> **最終目標**：把 Harness 定位成「Claude Code Plugin 的代表案例」，並透過 GitHub Trending 在全球 AI 開發者社群建立知名度。
