<!--
感謝你送出 PR。分支、Commit 與驗證規則請參閱 CONTRIBUTING.md。
-->

## 變更摘要

<!-- 用 2 至 4 句說明變更內容與原因。 -->

## 相關問題

- 修正 #
- 相關 #

## 變更範圍

- [ ] Harness Skill 或 meta-skill 邏輯
- [ ] Codex 自訂代理人範本（`.codex/agents/*.toml`）
- [ ] Plugin manifest（`.codex-plugin/plugin.json`）
- [ ] Marketplace（`.agents/plugins/marketplace.json`）
- [ ] 繁體中文文件（`README.md`、`docs/`）
- [ ] 驗證器或測試
- [ ] `CHANGELOG.md`
- [ ] 其他：

## 驗證

<!-- 附上實際執行的命令與結果。 -->

- [ ] `python scripts/validate_codex_harness.py` 通過
- [ ] 修改 Skill 時已執行應觸發、非觸發與 Dry-run
- [ ] 修改 manifest 時已執行 Codex Plugin validator
- [ ] 已手動重現並確認預期行為
- [ ] 不適用，原因：

## 破壞性變更與版本影響

- [ ] Patch：修正錯誤，不改變介面
- [ ] Minor：向下相容的新功能
- [ ] Major：破壞性變更，已附遷移說明
- [ ] 無：純文件、測試或內部整理

## 外部憑證需求

<!-- 列出服務、環境變數名稱、最小權限與測試方式；若無請寫「無」。不得貼出密鑰。 -->

## 補充說明

<!-- 截圖、遷移方式、已知限制或希望審查者特別注意的內容。 -->
