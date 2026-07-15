---
name: harness-packager
description: "封裝、搬移、備份、安裝與更新 Codex Harness 團隊。當使用者要把目前 repo 的 `.codex/agents`、`.agents/skills`、`AGENTS.md` 與多代理設定打包成可攜 `.harness` 資料夾，指定輸出位置，或把既有團隊套件安裝到另一個 repo 時使用；不適用於一般 ZIP、Git 備份或建立新團隊。"
---

# Harness Packager

把 Codex Harness 團隊封裝成可直接搬到其他 repo 的資料夾，或在目前 repo 安裝／更新該套件。使用 Plugin 內附的 PowerShell 腳本；不要要求使用者安裝 Node、Python、套件管理器或 global CLI。

## 選擇操作

- 「打包、封裝、備份、匯出團隊」：執行 Pack。
- 「安裝、套用、匯入、更新團隊」：執行 Install。
- 「檢查套件」：執行 Verify。
- 「建立或重構團隊」：改用 `$harness`，不要由本技能設計代理人。

腳本位置固定為本技能目錄下的 `scripts/harness_packager.ps1`。解析為絕對路徑後，以 `powershell -NoProfile -ExecutionPolicy Bypass -File` 執行。若系統沒有 PowerShell，依 `references/package-format.md` 使用目前可用的檔案工具完成同等操作，不要求使用者先安裝 runtime。

## Pack

1. 以目前工作目錄作為來源 repo，除非使用者明確指定其他 repo。
2. 名稱未指定時，優先使用唯一的 `*-orchestrator` skill 名稱；否則使用 repo 目錄名稱。
3. 目的地未指定時輸出到 `dist/<name>.harness/`；指定的是 `.harness` 路徑時直接使用，指定的是一般目錄時在其中建立 `<name>.harness/`。
4. 執行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\harness_packager.ps1" `
  -Action Pack `
  -Repo "<source-repo>" `
  -Output "<optional-output>" `
  -Name "<optional-name>"
```

5. 回報套件絕對路徑、名稱、檔案數與內容雜湊。不要回報大量逐檔日誌。

Pack 每次都讀取目前工作樹；同一路徑已有舊套件時，以目前內容完整取代。套件包含：

- `AGENTS.md`
- `.codex/agents/**`
- `.agents/skills/**`
- `.codex/config.toml` 的 `[agents]` 區段
- `scripts/validate-harness*` 或 `scripts/validate_harness*`
- `tests/**/harness-*` 或 `tests/**/harness_*`

不得包含 `.env`、私鑰、憑證檔、symlink／junction 或來源 repo 外的檔案。發現疑似秘密時停止，不要自行略過後繼續打包。

## Install

1. 以目前工作目錄作為目標 repo，除非使用者明確指定其他 repo。
2. 套件可以放在目標 repo 內，也可以使用其他位置的絕對路徑。
3. 執行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\harness_packager.ps1" `
  -Action Install `
  -Repo "<target-repo>" `
  -Package "<package-directory>"
```

4. 回報 `INSTALLED` 或 `UPDATED`、目標 repo、備份位置與檔案數。

Install 的套件內容是該團隊的最新來源：

- 同套件管理的 agents、skills、驗證器與測試由新版取代。
- 新版已刪除的舊受管檔案一併移除。
- `AGENTS.md` 只更新該套件的 managed block。
- `.codex/config.toml` 只合併套件提供的 `[agents]` keys。
- 其他 repo 檔案、其他 agents／skills 與其他 config 區段不變。
- 修改前自動備份到 `.harness/backups/<name>/<timestamp>/`；失敗時還原。

## Verify

安裝前腳本會自動驗證。使用者只要求檢查時執行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\harness_packager.ps1" `
  -Action Verify `
  -Package "<package-directory>"
```

驗證 `harness.json`、允許路徑、檔案清單、SHA-256、額外 payload、秘密檔案與 reparse point。任何一項失敗時，不修改目標 repo。

## 完成條件

- Pack：`<name>.harness/harness.json` 與所有宣告 payload 存在且 Verify 通過。
- Install：receipt 已寫入 `.harness/installed/<name>.json`，所有受管檔案與 manifest 一致。
- Update：新版內容已套用，舊受管內容已備份，非受管內容仍存在。

處理自訂套件、驗證失敗、路徑規則或人工 fallback 時，讀取 `references/package-format.md`。
