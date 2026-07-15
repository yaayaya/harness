# Harness Codex 專案指示

## 語言與命令

- 對使用者的回覆與本專案新增、更新的文件一律使用繁體中文。
- 執行 PowerShell 指令時一律使用 `powershell -NoProfile`。
- 若功能需要外部 API、服務帳號或密鑰，先整理用途、參數名稱、取得位置與最小權限，再請使用者提供；不得把憑證寫入 Git。

## 專案定位

本儲存庫是 Harness 的 Codex 原生版本。實作與文件必須以以下結構為準：

- 外掛描述：`.codex-plugin/plugin.json`
- Marketplace：`.agents/plugins/marketplace.json`
- Harness Skill：`skills/harness/SKILL.md`
- Harness Packager Skill：`skills/harness-packager/SKILL.md`
- 專案自訂代理人：`.codex/agents/*.toml`
- 專案技能：`.agents/skills/<skill-name>/SKILL.md`
- Codex 專案設定：`.codex/config.toml`
- 專案持久指示：`AGENTS.md`

不得重新加入 Claude 專用的外掛目錄、代理人 Markdown 格式、團隊 API 或啟動指令。歷史變更紀錄與遷移說明可以保留必要名詞，但不可成為現行操作方式。

## 修改原則

- 以 Codex 官方文件與目前的外掛／Agent Skills 規格為準。
- 自訂代理人的模型與推理強度預設繼承目前工作階段，除非使用者明確指定。
- 多代理工作由根代理人協調；只有使用者或適用的 `AGENTS.md`／Skill 明確要求委派時才使用子代理人。
- 平行工作採單一寫入者原則，避免不同代理人同時修改相同檔案。
- 新增技能時保持漸進式揭露：`SKILL.md` 放核心流程，詳細範例放入 `references/`。

## 驗證

完成修改後至少執行：

```powershell
powershell -NoProfile -Command '$env:PYTHONUTF8 = "1"; python scripts/validate_codex_harness.py'
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_harness_packager.ps1
```

若本機有 Codex 官方驗證腳本，也要驗證 `skills/harness` 與外掛根目錄。網站內容有變更時，應以瀏覽器檢查桌面版、可讀性、連結、溢位與主控台錯誤。
