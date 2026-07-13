# 貢獻指南

感謝你協助改善 Harness。這個 `codex` 分支以 Codex 原生外掛、技能、自訂代理人與多代理工作流程為唯一支援目標，所有新增或修改文件必須使用繁體中文。

## 開始之前

請先確認：

- 變更以 `.codex-plugin/plugin.json`、`.codex/agents/*.toml`、`.agents/skills/` 與 `AGENTS.md` 為準。
- 不新增 `.claude/`、`CLAUDE.md`、Claude Team API、實驗旗標或固定 Opus 模型設定。
- 不在 issue、測試資料、設定檔或 commit 中加入 API Key、token、密碼或其他密鑰。
- 若功能需要外部服務，issue 或 PR 必須列出服務、驗證方式、環境變數名稱、最小權限與測試方式。

## 回報錯誤

請使用錯誤回報範本，至少提供：

- `codex --version` 輸出
- 使用介面：ChatGPT 桌面版、Codex CLI、IDE Extension 或 Cloud
- 安裝方式：遠端 marketplace、本機 marketplace 或直接安裝 Skill
- 作業系統
- 最小重現步驟
- 預期與實際行為
- 已遮蔽敏感資訊的錯誤訊息或日誌

若問題涉及代理人委派，請補充 `.codex/config.toml` 中的 `[agents]` 設定，以及實際是否建立子代理工作。

## 提出功能

功能提案應回答：

1. 要解決的使用者問題是什麼？
2. 應由 Skill、自訂代理人、`AGENTS.md`、Plugin、MCP 或 Hook 哪一層處理？
3. 它會擴充哪一種架構模式，或需要新的模式？
4. 對權限、token、併發與失敗處理有何影響？
5. 如何驗證完成？

## 開發環境

### 需求

- Git
- Python 3.11 以上
- 可登入的 Codex CLI 或 ChatGPT 桌面版
- PowerShell 指令一律使用 `powershell -NoProfile`

### 複製與切換分支

```powershell
powershell -NoProfile -Command "git clone git@github.com:yaayaya/harness-zh.git; Set-Location harness-zh; git switch codex"
```

### 加入本機 Marketplace

在儲存庫根目錄執行：

```powershell
powershell -NoProfile -Command "codex plugin marketplace add ."
```

重新啟動 ChatGPT 桌面版，在 `Harness Codex` marketplace 安裝 Harness。修改後重新整理 marketplace 並重啟，使安裝快取載入新內容。

### 直接測試 Skill

```powershell
powershell -NoProfile -Command "New-Item -ItemType Directory -Force \"$HOME\.agents\skills\" | Out-Null; Copy-Item -Recurse -Force .\skills\harness \"$HOME\.agents\skills\harness\""
```

開啟新的 Codex 工作階段並輸入：

```text
$harness 幫我為一個小型測試專案建立 Harness，包含一位唯讀 explorer、一位 worker 與一位唯讀 reviewer。
```

## 變更規則

### Plugin Manifest

- 必須保留 `.codex-plugin/plugin.json`。
- `name` 使用 kebab-case；版本使用完整 semver。
- 只有實際存在的 skills、apps、MCP 或 hooks 才能寫入 manifest。
- 宣告的圖示、logo 與其他路徑必須存在於外掛內。
- 使用者可見文案使用繁體中文。

### 自訂代理人

- 位置為 `.codex/agents/{name}.toml`。
- 必須包含 `name`、`description` 與 `developer_instructions`。
- 唯讀角色設定 `sandbox_mode = "read-only"`。
- 未收到明確需求時，不固定模型或推理等級。
- 不得在多個代理人之間配置重疊寫入責任。

### Skills

- 外掛技能放在 `skills/{name}/SKILL.md`。
- 專案技能範例使用 `.agents/skills/{name}/SKILL.md`。
- Frontmatter 必須有 `name` 與清楚的 `description`。
- `SKILL.md` 保留必要流程；大型細節移到 `references/`。
- 重複機械化工作放在 `scripts/`。
- 所有引用路徑必須可解析。

### 文件

- 所有新增或修改文件使用繁體中文。
- 指令範例在 PowerShell 中使用 `powershell -NoProfile`。
- 不宣稱未驗證的功能、效能或相容性。
- Codex 產品行為以目前官方文件與實際可執行環境為準。

## 驗證

每個 PR 至少執行：

```powershell
powershell -NoProfile -Command "python .\scripts\validate_codex_harness.py"
```

若修改 Skill，還要確認：

- 正常流程 prompt
- 失敗或部分結果 prompt
- 應觸發 prompt
- 不應觸發 prompt
- 實際 Dry-run

若修改外掛 manifest，必須另外使用目前 Codex 的 Plugin validator 驗證；PR 中附上命令與成功輸出。

## Commit 訊息

使用 Conventional Commits：

| 類型 | 用途 | 範例 |
|---|---|---|
| `feat:` | 新功能 | `feat: 新增 Codex 自訂代理人範本` |
| `fix:` | 修正錯誤 | `fix: 修正 marketplace 本機來源路徑` |
| `docs:` | 文件 | `docs: 更新 Codex 安裝指南` |
| `refactor:` | 不改變行為的重構 | `refactor: 簡化 orchestrator 資料流` |
| `test:` | 測試 | `test: 新增 plugin manifest 驗證` |
| `chore:` | 維護 | `chore: 清理過時翻譯副本` |

破壞性變更使用 `feat!:`，並在 commit footer 寫出 `BREAKING CHANGE:` 與遷移方式。

## 分支命名

| 前綴 | 用途 |
|---|---|
| `feat/` | 新功能 |
| `fix/` | 錯誤修正 |
| `docs/` | 文件更新 |
| `refactor/` | 重構 |
| `test/` | 測試與驗證 |

## Pull Request

PR 必須包含：

- 問題與變更摘要
- 影響的 Codex 產物
- 驗證命令與結果
- 外部憑證需求，若無則寫「無」
- 使用者可見變更的 `CHANGELOG.md` 項目
- 破壞性變更的遷移說明

請保持變更聚焦，避免在同一 PR 混入無關格式化或歷史重寫。

## 授權與原作者

提交貢獻即表示你同意以 Apache License 2.0 發布。請保留 `revfactory/harness` 的原作者與授權聲明；Codex 移植與繁體中文修改也應在變更歷程中清楚標示。
