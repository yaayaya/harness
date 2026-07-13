# Agent Team 範例

---

## 範例 1：Research 團隊（Agent Team 模式）

### 團隊架構：Fan-out/Fan-in
### 執行模式：Agent Team

```
[領導者／Orchestrator]
    ├── TeamCreate(research-team)
    ├── TaskCreate(4 個研究任務)
    ├── 團隊成員自行協調 (SendMessage)
    ├── 收集結果 (Read)
    └── 產生綜合報告
```

### Agent 組成

| 團隊成員 | Agent 類型 | 角色 | 輸出 |
|------|-------------|------|------|
| official-researcher | general-purpose | 官方文件／部落格 | research_official.md |
| media-researcher | general-purpose | 媒體／投資 | research_media.md |
| community-researcher | general-purpose | 社群／SNS | research_community.md |
| background-researcher | general-purpose | 背景／競品／學術 | research_background.md |
| (Leader = Orchestrator) | — | 整合報告 | 綜合報告.md |

> Research agent 使用 `general-purpose` 內建類型，但必須以 `.claude/agents/{name}.md` 檔案定義。檔案中應明確寫出角色、調查範圍與團隊通訊協定，以確保可重用性與協作品質。

### Orchestrator Workflow（Agent Team）

```
Phase 1: 準備
  - 分析使用者輸入（掌握主題與研究模式）
  - 建立 _workspace/

Phase 2: 組建團隊
  - TeamCreate(team_name: "research-team", members: [
      { name: "official", prompt: "研究官方管道..." },
      { name: "media", prompt: "研究媒體／投資動向..." },
      { name: "community", prompt: "研究社群反應..." },
      { name: "background", prompt: "研究背景／競爭環境..." }
    ])
  - TaskCreate(tasks: [
      { title: "官方管道研究", assignee: "official" },
      { title: "媒體動向研究", assignee: "media" },
      { title: "社群反應研究", assignee: "community" },
      { title: "背景環境研究", assignee: "background" }
    ])

Phase 3: 執行研究
  - 4 位成員各自獨立研究
  - 若有有趣發現，透過 SendMessage 在成員間分享
    (例：media 將發現的投資新聞傳給 background)
  - 若發現資訊互相衝突，成員之間直接討論
  - 每位成員完成後都儲存檔案並通知領導者

Phase 4: 整合
  - 領導者 Read 4 份產出
  - 產生綜合報告
  - 對於互相衝突的資訊，並列標註來源

Phase 5: 收尾
  - 請求團隊成員結束
  - 解散團隊
  - 保留 _workspace/（供事後驗證與稽核追蹤）
```

### 團隊通訊模式

```
official ──SendMessage──→ background  (分享相關官方公告)
media ────SendMessage──→ background  (分享投資／併購資訊)
community ─SendMessage──→ media      (分享社群反應中與媒體相關的資訊)
所有成員 ──TaskUpdate──→ 共享任務清單  (更新進度)
領導者 ←───── 閒置通知 ──── 已完成的成員   (自動)
```

---

## 範例 2：SF 小說寫作團隊（Agent Team 模式）

### 團隊架構：Pipeline + Fan-out
### 執行模式：Agent Team

```
Phase 1 (並行 — Agent Team): worldbuilder + character-designer + plot-architect
  → 彼此透過 SendMessage 協調一致性
Phase 2 (順序): prose-stylist（執筆）
Phase 3 (並行 — Agent Team): science-consultant + continuity-manager（審查）
  → 彼此透過 SendMessage 分享發現
Phase 4 (順序): prose-stylist（依審查結果修改）
```

### Agent 組成

| 團隊成員 | Agent 類型 | 角色 | Skill |
|------|-------------|------|------|
| worldbuilder | 自訂 | 世界觀建構 | world-setting |
| character-designer | 自訂 | 角色設計 | character-profile |
| plot-architect | 自訂 | 劇情結構 | outline |
| prose-stylist | 自訂 | 文風編修 + 寫作 | write-scene, review-chapter |
| science-consultant | 自訂 | 科學驗證 | science-check |
| continuity-manager | 自訂 | 一致性驗證 | consistency-check |

### Agent 檔案完整範例：`worldbuilder.md`

```markdown
---
name: worldbuilder
description: "建構 SF 小說世界觀的專家。負責設計物理法則、社會結構、技術水準與歷史。"
---

# Worldbuilder — SF 世界觀設計專家

你是 SF 小說的世界觀設計專家。你會以科學事實為基礎，同時延展想像力，建構故事展開世界的物理、社會與技術基礎。

## 核心角色
1. 定義世界的物理法則與技術水準
2. 設計社會結構、政治體系與經濟系統
3. 建立歷史脈絡與當前衝突結構
4. 描寫各地點的環境與氛圍

## 工作原則
- 內在一致性優先，設定之間不可互相矛盾
- 以「如果有這項技術會如何？」的連鎖提問推論世界的擴散影響
- 世界觀應服務故事，避免過度設定而妨礙情節

## 輸入／輸出協定
- 輸入：使用者的世界觀概念與類型需求
- 輸出：`_workspace/01_worldbuilder_setting.md`
- 格式：Markdown，依章節區分（物理／社會／技術／歷史／地點）

## 團隊通訊協定
- 傳送給 character-designer：社會結構、階級系統、職業群資訊的 SendMessage
- 傳送給 plot-architect：世界主要衝突結構與危機因素的 SendMessage
- 接收來自 science-consultant 的科學錯誤回饋，並修正設定
- 世界觀變更時，向所有相關成員廣播

## Error handling
- 若概念模糊，提出 3 個方向並請求選擇
- 發現科學錯誤時，一併提供替代方案

## 協作
- 向 character-designer 提供社會結構資訊
- 向 plot-architect 提供衝突結構資訊
- 反映 science-consultant 的回饋來修正設定
```

### 團隊 Workflow 詳細說明

```
Phase 1: TeamCreate(team_name: "novel-team", members: [worldbuilder, character-designer, plot-architect])
         TaskCreate([世界觀建構, 角色設計, 劇情結構])
         → 成員自行協調並平行作業
         → worldbuilder 完成社會結構時，對 character-designer 發送 SendMessage
         → character-designer 設定主角時，對 plot-architect 發送 SendMessage

Phase 2: 收尾 Phase 1 團隊 → 以 subagent 呼叫 prose-stylist（因為是單獨執筆，不需要團隊）
         prose-stylist Read _workspace/ 中的 3 份產出後開始執筆
         → 將結果儲存到 _workspace/02_prose_draft.md

Phase 3: 建立新團隊 — TeamCreate(team_name: "review-team", members: [science-consultant, continuity-manager])
         （每個 session 只能有一個啟用中的團隊，但因為已整理完 Phase 1 團隊，所以可建立新團隊）
         → 兩位 reviewer 檢查 draft，並彼此分享發現
         → 若 science-consultant 發現物理錯誤，也通知 continuity-manager
         → 審查完成後整理團隊

Phase 4: 以 subagent 呼叫 prose-stylist，反映審查結果進行最終修改
```

---

## 範例 3：Webtoon 製作團隊（Subagent 模式）

### 團隊架構：Producer-Reviewer
### 執行模式：Subagent

> 在 Producer-Reviewer pattern 中只有 2 個 agent，而且重點是結果傳遞而不是通訊，因此更適合使用 subagent。

```
Phase 1: Agent(webtoon-artist) → 產生面板
Phase 2: Agent(webtoon-reviewer) → 檢查
Phase 3: Agent(webtoon-artist) → 重新產生有問題的面板（最多 2 次）
```

### Agent 組成

| Agent | subagent_type | 角色 | Skill |
|---------|--------------|------|------|
| webtoon-artist | 自訂 | 面板圖片生成 | generate-webtoon |
| webtoon-reviewer | 自訂 | 品質審查 | review-webtoon, fix-webtoon-panel |

### Agent 檔案完整範例：`webtoon-reviewer.md`

```markdown
---
name: webtoon-reviewer
description: "負責審查 Webtoon 面板品質的專家。評估構圖、角色一致性、文字可讀性與演出效果。"
---

# Webtoon Reviewer — Webtoon 品質審查專家

你是審查 Webtoon 面板品質的專家。你會以視覺完成度、故事傳達力與角色一致性為標準來評估面板。

## 核心角色
1. 評估各面板的構圖與視覺完成度
2. 驗證角色外觀在不同面板間的一致性
3. 評估對話框文字的可讀性與配置
4. 檢視整個篇章的演出流程與節奏

## 工作原則
- 以 PASS/FIX/REDO 三階段做出明確判定
- FIX 表示可透過部分修改解決，REDO 表示需要全面重製
- 依客觀標準（如一致性、可讀性、構圖）判斷，而非主觀喜好

## 輸入／輸出協定
- 輸入：`_workspace/panels/` 目錄中的面板圖片
- 輸出：`_workspace/review_report.md`
- 格式:
  ```
  ## Panel {N}
  - 判定: PASS | FIX | REDO
  - 原因: [具體原因]
  - 修改指示: [若為 FIX/REDO，請提供具體修改方向]
  ```

## Error handling
- 若圖片載入失敗，將該面板判定為 REDO
- 若重製 2 次後仍為 REDO，則附上警告並視為 PASS

## 協作
- 將修改指示傳給 webtoon-artist（以結果檔案為基礎）
- 再次檢查重製後的面板（最多循環 2 次）
```

### Error handling

```
重試政策:
- REDO 判定面板 → 要求 artist 重新生成（包含具體修改指示）
- 最多循環 2 次後強制 PASS
- 若超過 50% 的面板為 REDO，建議使用者修改 prompt
```

---

## 範例 4：Code Review 團隊（Agent Team 模式）

### 團隊架構：Fan-out/Fan-in + 討論
### 執行模式：Agent Team

> Code review 是最能發揮 Agent Team 優勢的代表性案例之一。不同觀點的 reviewer 可以共享發現並互相挑戰，從而做出更深入的 review。

```
[領導者] → TeamCreate(review-team)
    ├── security-reviewer: 檢查安全性弱點
    ├── performance-reviewer: 分析效能影響
    └── test-reviewer: 驗證測試覆蓋率
    → reviewer 彼此分享發現 (SendMessage)
    → 領導者整合結果
```

### 團隊通訊模式

```
security ──SendMessage──→ performance  ("這個 SQL 查詢可能被注入，也需要從效能面確認")
performance ──SendMessage──→ test      ("發現 N+1 查詢，請確認是否有相關測試")
test ────SendMessage──→ security      ("驗證模組沒有測試，從安全角度看優先順序如何？")
```

核心：reviewer 們**不經過 leader** 直接溝通，以更快捕捉跨領域問題。

---

## 範例 5：Supervisor pattern - Code migration 團隊（Agent Team 模式）

### 團隊架構：Supervisor
### 執行模式：Agent Team

```
[supervisor/領導者] → 分析檔案清單 → 分配批次
    ├→ [migrator-1] (batch A)
    ├→ [migrator-2] (batch B)
    └→ [migrator-3] (batch C)
    ← 接收 TaskUpdate → 追加分配批次或重新分配
```

### Agent 組成

| 團隊成員 | 角色 |
|------|------|
| (Leader = migration-supervisor) | 檔案分析、批次分配、進度管理 |
| migrator-1~3 | 遷移被指派的檔案批次 |

### Supervisor 的動態分配邏輯（活用 Agent Team）

```
1. 收集所有目標檔案清單
2. 估算複雜度（檔案大小、import 數量、相依性）
3. 以 TaskCreate 將檔案批次登記為任務（包含相依性）
4. 團隊成員自行請求工作（claim）
5. 當成員用 TaskUpdate 回報完成時：
   - 成功 → 自動請求下一項工作
   - 失敗 → 領導者用 SendMessage 確認原因 → 重新分配或改派其他成員
6. 所有工作完成 → 領導者執行整合測試
```

與 Fan-out 的差異在於：工作不是事先固定，而是**在 runtime 動態分配**。共享工作清單的自主 claim 功能，與 Supervisor pattern 自然契合。

---

## 產出模式摘要

### Agent 定義檔
位置：`專案/.claude/agents/{agent-name}.md`
必要章節：核心角色、工作原則、輸入／輸出協定、Error handling、協作
團隊模式額外章節：**團隊通訊協定**（訊息接收／發送、可 claim 的工作範圍）

### Skill 檔案結構
位置：`專案/.claude/skills/{skill-name}/SKILL.md`（專案層級）
或：`~/.claude/skills/{skill-name}/SKILL.md`（全域層級）

### 整合 Skill（Orchestrator）
協調整個團隊的上層 skill。定義各情境的 agent 組成與 workflow。
範本請參考：`references/orchestrator-template.md`。
**必須明確標示執行模式** - Agent Team（預設）或 Subagent。
