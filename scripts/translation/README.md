# 翻譯自動化執行器介面

這個目錄預留給未來由其他電腦執行的翻譯維護工具。預設由 Codex 直接執行翻譯，不需要 API Key；本目錄的 Python 工具是沒有 Codex 時才使用的可選外部 API 執行器。

## 輸入

- repository 根目錄：由目前工作目錄或命令列參數取得，不得寫死本機路徑。
- `origin` 與 `upstream` Git remote。
- `main`、`zh-tw` 分支。
- `docs/translation-status.md` 的目前狀態。
- 未來翻譯服務設定：`TRANSLATION_PROVIDER`、`TRANSLATION_MODEL` 與 API 金鑰環境變數。

## 輸出

- 更新後的繁體中文與簡體中文文件。
- 更新後的 `docs/translation-status.md`。
- 位於 `codex/translate-YYYY-MM-DD` 的可檢查 commit。
- 合併回 `zh-tw` 後可推送到 `origin/zh-tw` 的結果。

## 退出條件

- 成功：所有變更已驗證，且只產生翻譯分支或 `zh-tw` 的 commit。
- 失敗：回傳非零退出碼，不推送不完整翻譯，並保留錯誤訊息與工作分支。
- 沒有上游文件變更：回傳成功但不建立空 commit。

## 執行器限制

執行器必須保留上游原文、維持 Markdown/HTML 結構、不得修改 `main` 的翻譯內容，且只能推送 `zh-tw`。所有 Git commit 必須使用 `yaayaya` 身分與繁體中文 commit subject。

## Codex 直接模式

Codex 直接讀取 `upstream/main` 的原文，依序翻譯繁中與簡中、更新 `docs/translation-status.md`，再依維護規則建立分支與 commit。這是目前建議的方式，不需要設定 `OPENAI_API_KEY`。

## 外部 API 執行方式

先更新上游並檢查預計處理檔案：

```powershell
git fetch upstream --prune
python scripts/translation/translate.py --dry-run
```

設定 `OPENAI_API_KEY` 後，才使用 Python 執行器處理單一文件或全量翻譯：

```powershell
$env:OPENAI_API_KEY = "在執行環境設定，不要寫入檔案"
python scripts/translation/translate.py --path docs/quickstart.md --language both
python scripts/translation/translate.py --language both
```

腳本只寫入翻譯檔案，不會自動 commit 或 push；完成後仍依 `docs/translation-maintenance.md` 建立分支、提交與推送。
