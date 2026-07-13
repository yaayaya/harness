# 翻譯維護規則

## 分支責任

- `main`：只同步 `upstream` 的原作者內容，不放翻譯 commit。
- `zh-tw`：繁體中文版本，並作為本 fork 的預設語言分支。
- `origin`：`yaayaya/harness-zh`。
- `upstream`：`revfactory/harness`。
- `codex/translate-YYYY-MM-DD`：單次自動翻譯工作的暫存分支。

繁體中文與簡體中文都沿用上游多語系結構。`README.md` 維持繁體中文預設入口；簡體中文使用 `README_ZH_CN.md`，其他文件依同樣的語言後綴規則建立。

## 執行模式

### Codex 直接模式（預設）

由 Codex 讀取 repository、執行翻譯、更新狀態、建立 commit，並依使用者授權推送到 `origin/zh-tw`。這個模式不需要外部 API Key，適合目前的翻譯工作與未來由 Codex automation 定時喚醒的工作。

### 外部 API 模式（可選）

只有在另一台電腦不執行 Codex、而是單獨執行 `scripts/translation/translate.py` 時，才需要翻譯服務 API Key。這不是本專案目前翻譯工作的前置條件。

## 自動化執行順序

1. 確認工作區乾淨，且目前沒有未完成的翻譯工作分支。
2. 執行 `git fetch upstream --prune`。
3. 切換 `main`，以 fast-forward 更新至 `upstream/main`。
4. 切換 `zh-tw`，建立 `codex/translate-YYYY-MM-DD`。
5. 比對上游自上次同步後變更的文件。
6. 同步繁體中文與簡體中文對應文件。
7. 更新 `docs/translation-status.md`，記錄來源 commit、處理日期與狀態。
8. 建立繁體中文 commit：`docs(翻譯): 更新多語系文件`。
9. 將工作分支以 `--no-ff` 合併回 `zh-tw`。
10. 只推送 `origin/zh-tw`；不得把翻譯合併回 `main`。

## 檔案規則

- 保留上游原文檔案與既有語言檔案。
- 繁中預設入口使用 `README.md`；其他繁中翻譯使用 `_ZH_TW` 後綴。
- 簡中使用 `_ZH_CN` 後綴。
- 程式碼、圖片、LICENSE、設定檔不翻譯，狀態標記為 `不適用`。
- 連結、命令、檔案路徑、環境變數名稱與程式碼區塊必須保持可執行。

## 停止條件

- `upstream` 抓取或 `main` 更新失敗：停止，不建立 commit。
- 找不到對應語言檔：建立待處理狀態，不刪除原文、不推送不完整結果。
- 翻譯輸出遺漏段落、破壞 Markdown/HTML 結構或驗證失敗：停止推送，保留分支供下次重試。
- 自動化執行器不得對 `main` 使用 force push。

## 外部服務

第一版不需要 GitHub Actions，也不需要翻譯 API。Codex 直接模式使用目前 Codex 工作階段的模型能力；只有外部 API 模式才需要由執行環境提供 `TRANSLATION_PROVIDER`、`TRANSLATION_MODEL` 與對應 API 金鑰環境變數。金鑰不得寫入 repository、狀態表或 commit。
