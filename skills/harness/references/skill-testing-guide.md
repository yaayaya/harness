# Skill 測試與迭代改進指南

用於驗證在 Harness 中建立之 skill 品質，並持續迭代改善的方法論。這是對 `SKILL.md` Phase 6 的補充參考。

---

## 目錄

1. [測試框架概覽](#1-測試框架概覽)
2. [測試 prompt 撰寫方式](#2-測試-prompt-撰寫方式)
3. [執行測試：With-skill vs Baseline](#3-執行測試with-skill-vs-baseline)
4. [量化評估：基於 assertion 的評分](#4-量化評估基於-assertion-的評分)
5. [善用專業 Agent](#5-善用專業-agent)
6. [迭代改進循環](#6-迭代改進循環)
7. [Description 觸發驗證](#7-description-觸發驗證)
8. [Workspace 結構](#8-workspace-結構)

---

## 1. 測試框架概覽

skill 品質驗證是**定性評估**與**定量評估**的組合。

| 評估類型 | 方法 | 適合的 skill |
|----------|------|-----------|
| **定性** | 由使用者直接審查產出物 | 文風、設計、創作物等主觀品質 |
| **定量** | 以 assertion 為基礎的自動評分 | 檔案建立、資料擷取、程式碼生成等可客觀驗證的項目 |

核心循環：**撰寫 → 執行測試 → 評估 → 改進 → 再測試**

---

## 2. 測試 prompt 撰寫方式

### 原則

測試 prompt 應該是**真實使用者可能輸入的、具體且自然的句子**。抽象或過度人工化的 prompt，測試價值很低。

### 不好的例子

```
"處理這份 PDF"
"擷取資料"
"產生圖表"
```

### 好的例子

```
"請從下載資料夾中的 'Q4_營收_最終_v2.xlsx' 使用 C 欄（營收）和 D 欄（成本）
新增一個利潤率（%）欄位，並依利潤率做遞減排序。"
```

```
"請把這份 PDF 第 3 頁的表格擷取出來並轉成 CSV。表頭共有兩列，
第一列是類別，第二列才是真正的欄位名稱。"
```

### prompt 多樣性

- 混合**正式 / 輕鬆**語氣
- 混合**明示 / 暗示**意圖（例如直接說檔案格式 vs 必須從上下文推論）
- 混合**簡單 / 複雜**任務
- 部分範例可包含縮寫、錯字、口語表達

### 涵蓋範圍

先從 2 到 3 個 prompt 開始，但要設計成至少涵蓋：
- 1 個核心使用情境
- 1 個 edge case
- （可選）1 個複合任務

---

## 3. 執行測試：With-skill vs Baseline

### 3-1. 比較執行結構

針對每個測試 prompt，**同時**啟動兩個 subagent：

**With-skill 執行：**
```
提示詞："{測試提示詞}"
skill 路徑：{skill 路徑}
輸出路徑：_workspace/iteration-N/eval-{id}/with_skill/outputs/
```

**Baseline 執行：**
```
提示詞："{測試提示詞}"（相同）
skill：無
輸出路徑：_workspace/iteration-N/eval-{id}/without_skill/outputs/
```

### 3-2. Baseline 選擇

| 情境 | Baseline |
|------|----------|
| 建立新 skill | 不使用 skill，直接執行相同 prompt |
| 改進既有 skill | 修改前的 skill 版本（保留 snapshot） |

### 3-3. 擷取時序資料

在 subagent 完成通知中，必須**立即**保存 `total_tokens` 與 `duration_ms`。這些資料只在通知當下可取得，之後無法恢復。

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

---

## 4. 量化評估：基於 assertion 的評分

### 4-1. 撰寫 assertion

如果產出物可以客觀驗證，就應定義 assertion 來做自動評分。

**好的 assertion：**
- 可以客觀判斷真／假
- 名稱具描述性，只看結果就知道在檢查什麼
- 能驗證該 skill 的核心價值

**不好的 assertion：**
- 不論有沒有 skill 都會通過（例如「有輸出存在」）
- 需要主觀判斷（例如「寫得很好」）

### 4-2. 可程式化驗證

若 assertion 能以程式碼驗證，就請寫成 script。這會比人工目視更快、更可靠，而且能在每次 iteration 中重複使用。

### 4-3. 注意 Non-discriminating assertion

若某個 assertion 在「兩種配置都 100% 通過」，就無法測出 skill 的差異價值。發現這類 assertion 時，應移除或改成更具挑戰性的 assertion。

### 4-4. 評分結果 schema

```json
{
  "expectations": [
    {
      "text": "已新增利潤率欄位",
      "passed": true,
      "evidence": "確認 E 欄存在 `profit_margin_pct` 欄位"
    },
    {
      "text": "已依利潤率做遞減排序",
      "passed": false,
      "evidence": "未排序，仍保留原始順序"
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

## 5. 善用專業 Agent

在測試／評估過程中運用專門角色的 agent，可以提升品質。

### 5-1. Grader（評分者）

負責執行以 assertion 為基礎的評分，並從產出物中擷取可驗證的 claim，再進行交叉驗證。

**角色：**
- 針對每個 assertion 判定通過／失敗，並提供依據
- 從產出物中擷取事實性主張並驗證
- 對 eval 本身的品質提供回饋（例如 assertion 太簡單或過於模糊時提出建議）

### 5-2. Comparator（盲測比較者）

將兩份產出匿名成 A/B，在不知道哪一份使用了 skill 的情況下，判定其品質優劣。

**適用時機：** 當你想更嚴謹地確認「新版本是否真的更好」時。一般的迭代改進流程中可省略。

**判定標準：**
- 內容：正確性、完整度
- 結構：組織性、格式、可用性
- 綜合分數

### 5-3. Analyzer（分析者）

分析 benchmark 資料中的統計模式：
- Non-discriminating assertion（兩種配置都通過 → 無差異性）
- 高變異 eval（每次執行結果差很多 → 不穩定）
- 時間／token 取捨（skill 提升品質，但成本也變高）

---

## 6. 迭代改進循環

### 6-1. 蒐集回饋

把產出物展示給使用者並收集回饋。若回饋為空，代表「沒有發現問題」。

### 6-2. 改進原則

1. **將回饋泛化** — 不要只為單一測試案例做狹義修補，否則會 overfit。請從原則層級修正。
2. **拿掉不值得其成本的內容** — 閱讀 transcript，若 skill 要 agent 做的是沒有生產力的工作，就刪除那一段。
3. **說明 Why** — 即使使用者回饋很簡短，也要理解它為何重要，並把這個理解反映到 skill 中。
4. **把重複工作打包** — 如果每次測試都會建立同樣的 helper script，就應該預先放進 `scripts/`。

### 6-3. 迭代流程

```
1. 修改 skill
2. 在新的 iteration-N+1/ 目錄中重新執行所有測試案例
3. 向使用者展示結果（與前一輪 iteration 比較）
4. 蒐集回饋
5. 再次修改 → 重複
```

**結束條件：**
- 使用者滿意
- 所有回饋皆為空（所有產出物都沒有問題）
- 已無明顯可再提升之處

### 6-4. 草稿 → 複審 pattern

修改 skill 時，先寫出草稿，再**以新的角度重新閱讀**後進一步改進。不要期待一次就寫到完美，而是透過草稿與審閱循環逐步打磨。

---

## 7. Description 觸發驗證

### 7-1. 撰寫觸發 Eval query

準備 20 個 eval query：10 個 should-trigger + 10 個 should-NOT-trigger。

**query 品質標準：**
- 真實使用者可能輸入的、具體且自然的句子
- 包含檔案路徑、個人情境、欄位名稱、公司名稱等具體細節
- 混合不同長度、語氣與格式
- 與其追求明確標準答案，更應聚焦在**邊界案例（edge case）**

**Should-trigger query（8 到 10 個）：**
- 同一意圖的不同表達方式（正式／口語）
- 沒有明說 skill / 檔案類型，但明顯需要此 skill 的情況
- 非主流使用情境
- 會和其他 skill 競爭，但理應由這個 skill 勝出的情況

**Should-NOT-trigger query（8 到 10 個）：**
- **Near-miss 是重點** — 關鍵字相近，但更適合其他工具／skill 的 query
- 明顯無關的 query（例如「寫 Fibonacci 函式」）幾乎沒有測試價值
- 鄰近領域、模糊表述、關鍵字重疊但上下文不同的情況

### 7-2. 驗證是否與既有 skill 衝突

確認新 skill 的 description 不會與既有 skill 的觸發範圍重疊：

1. 蒐集既有 skill 清單中的 description
2. 確認新 skill 的 should-trigger query 不會誤觸發既有 skill
3. 若發現衝突，就把 description 的邊界條件寫得更清楚

### 7-3. 自動最佳化（選用進階功能）

若需要最佳化 description：

1. 將 20 個 eval query 切分為 Train（60%）/ Test（40%）
2. 用目前的 description 測量觸發準確率
3. 分析失敗案例並產生改良後的 description
4. 以 Test set 表現選出最佳 description（不是以 Train set 為準，避免過擬合）
5. 最多重複 5 次

> 這個流程會用到 `claude -p` 的自動化 script。由於 token 成本較高，建議等 skill 足夠穩定後，再在最後階段執行。

---

## 8. Workspace 結構

用來系統化管理測試／評估結果的目錄結構：

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

**規則：**
- eval 目錄請使用**描述性名稱**而不是數字（例如 `eval-multi-page-table-extraction`）
- 每個 iteration 都要保留在獨立目錄中（不要覆寫前一輪 iteration）
- 不要刪除 `_workspace/` — 這是為了事後驗證與稽核追蹤
