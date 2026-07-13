# Skill 撰寫指南

用於提升 Harness 產生之 skill 品質的詳細撰寫指南。這是 `SKILL.md` Phase 4 的補充參考資料。

---

## 目錄

1. [Description 撰寫模式](#1-description-撰寫模式)
2. [本文撰寫風格](#2-本文撰寫風格)
3. [輸出格式定義模式](#3-輸出格式定義模式)
4. [範例撰寫模式](#4-範例撰寫模式)
5. [Progressive Disclosure 模式](#5-progressive-disclosure-模式)
6. [script bundling 判斷標準](#6-script-bundling-判斷標準)
7. [資料 schema 標準](#7-資料-schema-標準)
8. [不要放進 skill 的內容](#8-不要放進-skill-的內容)

---

## 1. Description 撰寫模式

`Description` 是 skill 唯一的 trigger 機制。Claude 會只根據 `available_skills` 清單中的 name + description，決定是否使用該 skill。

### 理解 trigger 機制

Claude 傾向不會為了可以用自身基本工具輕鬆處理的簡單工作呼叫 skill。像「幫我讀這份 PDF」這種簡單請求，即使 description 寫得再完整，也可能不會被 trigger。工作越複雜、步驟越多、越具專業性，skill 被 trigger 的機率就越高。

### 撰寫原則

1. 同時描述 **skill 會做什麼** + **具體的 trigger 情境**
2. 明確寫出邊界條件，區分相似但不應 trigger 的情況
3. 稍微寫得更「pushy」一些，以補償 Claude 傾向保守判斷 trigger 的特性

### 好的範例

```yaml
description: "執行所有 PDF 相關工作，包括讀取檔案、擷取文字與表格、合併、
  分割、旋轉、加浮水印、加密或解密，以及 OCR。只要提到 .pdf 檔案
  或要求產出 PDF 成果物，就應該使用此 skill。當需求不只是單純
  '幫我讀這份 PDF'，而是包含轉換、編輯或分析時尤其適用。"
```

```yaml
description: "處理所有 spreadsheet 工作，包括為 Excel/CSV/TSV 新增欄位、
  計算公式、調整格式、建立圖表與資料清理。只要使用者提到 spreadsheet
  檔案，即使只是隨口說『下載資料夾裡那個 xlsx』，也應該使用此 skill。"
```

### 不好的範例

- `"處理資料的 skill"` — 太模糊，無法判斷是什麼檔案或工作
- `"與 PDF 相關的工作"` — 沒有列出具體動作，也沒描述 trigger 情境

---

## 2. 本文撰寫風格

### Why-First 原則

LLM 理解原因後，就能在 edge case 中做出更正確的判斷。與其使用強硬規則，不如傳達脈絡，效果更好。

**不好的範例：**
```markdown
ALWAYS use pdfplumber for table extraction. NEVER use PyPDF2 for tables.
```

**好的範例：**
```markdown
表格擷取使用 pdfplumber。PyPDF2 擅長純文字擷取，但無法穩定保留表格的
列與欄結構；pdfplumber 則能辨識儲存格邊界，回傳更結構化的資料。
```

### 一般化原則

當從回饋或測試結果中發現問題時，不要只做剛好符合特定範例的狹義修正，而要在 **原理層級進行一般化**。

**overfit 的修正：**
```markdown
如果存在「Q4 營收」欄位，就將該欄轉成數值型別。
```

**一般化後的修正：**
```markdown
若欄位名稱包含「營收」、「金額」、「數量」等暗示數值的關鍵字，
就將該欄轉成數值型別；若轉換失敗，保留原始值。
```

### 命令式語氣

不要使用「會...」、「可以...」這類語氣，改用「執行...」、「請將...」這種明確的命令形式。skill 是一份指示書。

### 節省 context

context window 是公共資源。要不斷自問每一句話是否足以合理化它的 token 成本：
- 「這是 Claude 已經知道的內容嗎？」→ 刪除
- 「沒有這段說明，Claude 會犯錯嗎？」→ 保留
- 「一個具體範例是否比一大段說明更有效？」→ 改用範例

---

## 3. 輸出格式定義模式

適用於輸出格式很重要的 skill：

```markdown
## 報告結構
請嚴格遵循以下模板：

# [標題]
## 摘要
## 關鍵發現
## 建議事項
```

格式定義要簡潔，如果附上實際範例會更有效。

---

## 4. 範例撰寫模式

範例通常比長篇說明更有效：

```markdown
## Commit Message 格式

**範例 1：**
輸入：新增以 JWT token 為基礎的使用者驗證
輸出：feat(auth): implement JWT-based authentication

**範例 2：**
輸入：修正登入頁面密碼顯示按鈕無法運作的 bug
輸出：fix(login): fix password visibility toggle
```

---

## 5. Progressive Disclosure 模式

### 模式 1：依領域拆分

```
bigquery-skill/
├── SKILL.md (總覽 + 領域選擇指南)
└── references/
    ├── finance.md (營收、計費指標)
    ├── sales.md (商機、Pipeline)
    └── product.md (API 使用量、功能)
```

當使用者詢問營收時，只載入 `finance.md`。

### 模式 2：條件式細節

```markdown
# DOCX 處理

## 文件建立
使用 docx-js 建立新文件。→ 參考 [DOCX-JS.md](references/docx-js.md)

## 文件編輯
簡單編輯可直接修改 XML。
**若需要追蹤修訂**：參考 [REDLINING.md](references/redlining.md)
```

### 模式 3：大型 reference 檔案結構

超過 300 行的 reference 檔案，應在頂部包含目錄：

```markdown
# API 參考

## 目錄
1. [驗證](#驗證)
2. [端點列表](#端點列表)
3. [錯誤代碼](#錯誤代碼)
4. [速率限制](#速率限制)

---

## 驗證
...
```

---

## 6. script bundling 判斷標準

在執行測試時，觀察 agent 們的 transcript。若出現下列模式，就代表應該 bundling：

| 訊號 | 措施 |
|------|------|
| 3 個測試中有 3 個都產生相同的 helper script | bundling 到 `scripts/` |
| 每次都執行相同的 pip install/npm install | 在 skill 中明確寫出依賴安裝步驟 |
| 重複相同的多步驟做法 | 在 skill 本文中寫成標準程序 |
| 每次都遇到類似錯誤後套用相同 workaround | 在 skill 中記錄已知問題與解法 |

已 bundling 的 script 必須經過實際執行測試。

---

## 7. 資料 schema 標準

為了讓 skill 之間的資料交換保持一致，請使用標準 schema。這也可用於 Harness 產生之 skill 的測試與評估。

### `eval_metadata.json`

各測試案例的 metadata：

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "使用者的工作提示詞",
  "assertions": [
    "成果物中包含 X",
    "已產生 Y 格式的檔案"
  ]
}
```

### `grading.json`

以 assertion 為基礎的評分結果：

```json
{
  "expectations": [
    {
      "text": "成果物中包含「台北」",
      "passed": true,
      "evidence": "在第 3 個步驟確認有「擷取台北地區資料」"
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

**欄位名稱注意：** 必須精確使用 `text`、`passed`、`evidence`（禁止改成 `name`、`met`、`details` 等變形）。

### `timing.json`

執行時間 / token 測量：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

在 subagent 完成通知中，要立刻保存 `total_tokens` 與 `duration_ms`。這些資料只能在通知當下取得，之後無法復原。

---

## 8. 不要放進 skill 的內容

- `README.md`、`CHANGELOG.md`、`INSTALLATION_GUIDE.md` 等附加文件
- skill 產生過程的 metadata（測試結果、迭代歷程）
- 面向使用者的說明文件（skill 是給 AI agent 的指示書）
- Claude 已經知道的一般性知識
