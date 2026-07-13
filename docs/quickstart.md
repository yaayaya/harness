# Harness Codex 快速開始

本指南會在約五分鐘內完成 Harness 安裝、叫用與產物驗證。

## 完成後你會擁有什麼

- 一個可由 Codex 安裝的 Harness 外掛或個人 Skill。
- 一組針對目標專案的 `.codex/agents/*.toml` 自訂代理人。
- 一組 `.agents/skills/*/SKILL.md` 專案技能。
- 一個寫入 `AGENTS.md` 的最小 Harness 入口。
- 一套包含正常、失敗與 Dry-run 的驗證流程。

## 前置條件

- 已安裝並可登入 Codex CLI 或 ChatGPT 桌面版中的 Codex。
- 已安裝 Git。
- 安裝遠端 marketplace 時可連線到 `github.com`。
- 目標專案已交由 Codex 信任；專案層 `.codex/config.toml` 只有在受信任專案中載入。

Harness 本身不需要 OpenAI API Key。只有你要求產生的代理人要連接外部 MCP 或私有 API 時，才需要另外提供憑證資訊。

## Step 1：加入 Marketplace

```powershell
powershell -NoProfile -Command "codex plugin marketplace add yaayaya/harness-zh --ref codex"
```

這會把 `codex` 分支中的 `.agents/plugins/marketplace.json` 加入 Codex marketplace 清單。

確認來源：

```powershell
powershell -NoProfile -Command "codex plugin marketplace list"
```

預期會看到 `harness-codex` 與對應的本機快照路徑。

## Step 2：安裝 Harness

1. 重新啟動 ChatGPT 桌面版或 Codex。
2. 開啟 Plugins。
3. 選擇 `Harness Codex` marketplace。
4. 安裝 `Harness`。

在 Codex CLI 中，可輸入 `/plugins` 檢查外掛是否可見。

### 只安裝 Skill

若不需要外掛安裝介面，在本專案根目錄執行：

```powershell
powershell -NoProfile -Command "New-Item -ItemType Directory -Force \"$HOME\.agents\skills\" | Out-Null; Copy-Item -Recurse -Force .\skills\harness \"$HOME\.agents\skills\harness\""
```

重新開啟 Codex，使技能清單重新載入。

## Step 3：在目標專案叫用 Harness

從目標專案根目錄啟動 Codex，輸入：

```text
$harness 幫我為這個專案配置 Codex Harness。
請先稽核現況，再建立需要的自訂代理人、專案技能、Orchestrator 與驗證流程。
所有研究與審查角色保持唯讀，同一份最終產物只能有一位寫入者。
```

如果只需要特定領域：

```text
$harness 為金融科技授信風險評估建立 Harness。
輸出要涵蓋資料蒐集、法規審查、信用風險判斷、獨立 reviewer 與最終 memo 驗收。
```

Codex 應先說明它選擇的角色與模式，再建立檔案並執行驗證。

## Step 4：檢查產物

```powershell
powershell -NoProfile -Command "Get-ChildItem -Recurse .codex\agents, .agents\skills; Get-Content -Raw AGENTS.md"
```

至少確認：

- `.codex/agents/*.toml` 存在。
- 每個代理人有 `name`、`description`、`developer_instructions`。
- 審查代理人設定 `sandbox_mode = "read-only"`。
- `.agents/skills/` 中有 Orchestrator Skill。
- `AGENTS.md` 只放觸發規則與變更歷程，沒有複製完整技能內容。
- 沒有 `.claude/`、`CLAUDE.md` 或其他平台的工具名稱。

## Step 5：執行一個真實任務

```text
請使用剛建立的 Harness 處理這個任務：
分析目前專案最重要的三個整合風險，提出修正優先順序，並以獨立 reviewer 驗證結論。
等待所有必要代理人結果後再給最終答案。
```

預期行為：

1. 主代理人讀取 `AGENTS.md` 與 Orchestrator Skill。
2. 依技能指示選擇自訂代理人。
3. 可獨立的讀取或審查工作平行執行。
4. 主代理人等待必要結果、解決衝突並彙整。
5. 只有指定角色能修改最終產物。
6. 最終答案包含驗證證據與未覆蓋範圍。

## 常見問題

### Marketplace 看不到 Harness

執行：

```powershell
powershell -NoProfile -Command "codex plugin marketplace list"
```

若來源不存在，重新執行 Step 1；若來源存在但仍看不到，重新啟動 ChatGPT 桌面版，使 marketplace 與外掛快取重新載入。

### `$harness` 沒有出現在技能清單

確認其中一個位置存在：

- 外掛安裝快取中的 `skills/harness/SKILL.md`
- 個人技能 `$HOME/.agents/skills/harness/SKILL.md`

重新啟動 Codex，或在 CLI 以 `/skills` 檢查技能。

### `.codex/config.toml` 沒有生效

Codex 只在受信任專案中載入專案層設定。確認專案信任狀態，並開啟新的工作階段。

### 只看到主代理人，沒有子代理人

確認你的 prompt 或適用的 `AGENTS.md`／Skill 明確要求委派。Codex 會在直接要求或專案、技能指示適用時啟動子代理人。

若工作很小或無法獨立切分，Harness 可以正確選擇單一代理人；這不是錯誤。

### Token 使用量過高

- 降低 `.codex/config.toml` 的 `agents.max_threads`。
- 保持 `agents.max_depth = 1`。
- 只把獨立且有價值的工作交給子代理人。
- 要求子代理人回傳摘要與證據，不回傳完整原始日誌。

### 需要外部 API Key

先整理並提供：

- 服務名稱與環境
- Base URL 或 MCP 端點
- 驗證方式與環境變數名稱
- 所需最小權限
- 測試帳號或測試資料

密鑰只放在安全的環境變數或 Codex 支援的憑證流程，不要寫進 TOML、Markdown、Git 或 `_workspace/`。

## 專案本身的驗證

在 Harness 儲存庫根目錄執行：

```powershell
powershell -NoProfile -Command "python .\scripts\validate_codex_harness.py"
```

成功時應顯示外掛 manifest、marketplace、技能與平台殘留檢查都通過。

更多相容性資訊請參閱 [Codex 相容性](codex-compatibility.md)。
