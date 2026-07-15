# Harness 可攜套件格式

## 目錄

1. [結構](#結構)
2. [Manifest](#manifest)
3. [允許路徑](#允許路徑)
4. [安裝模式](#安裝模式)
5. [更新與復原](#更新與復原)
6. [安全限制](#安全限制)

## 結構

套件是名稱以 `.harness` 結尾的普通資料夾，不壓縮：

```text
web-team.harness/
├── harness.json
└── payload/
    ├── AGENTS.md
    ├── .codex/
    │   ├── config.toml
    │   └── agents/
    ├── .agents/
    │   └── skills/
    ├── scripts/
    └── tests/
```

使用者可以複製整個資料夾到另一個 repo，也可以讓 Install 直接讀取其他位置。

## Manifest

`harness.json` 使用 UTF-8 JSON：

```json
{
  "formatVersion": 1,
  "name": "web-team",
  "displayName": "通用 Web 開發團隊",
  "createdAt": "2026-07-15T06:00:00.0000000Z",
  "contentHash": "sha256...",
  "source": {
    "repository": "AdventureGuild",
    "branch": "main",
    "commit": "abc123",
    "dirty": true
  },
  "files": [
    {
      "path": ".codex/agents/frontend_engineer.toml",
      "mode": "replace",
      "sha256": "sha256..."
    }
  ]
}
```

`contentHash` 是依排序後的 `path + sha256` 計算，用來辨認套件內容，不作日期或 semver 比較。每次 Pack 都以目前內容重建同一個輸出目錄。

## 允許路徑

第一版只允許 Harness 自身產物：

- `AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/**`
- `.agents/skills/**`
- `scripts/validate-harness*`、`scripts/validate_harness*`
- `tests/**/harness-*`、`tests/**/harness_*`

路徑必須相對於 `payload/`，不可為絕對路徑，不可包含 `.`、`..`、磁碟代號、UNC、symlink 或 junction。

## 安裝模式

| mode | 路徑 | 行為 |
|---|---|---|
| `managed-markdown` | `AGENTS.md` | 以套件名稱標記 managed block；首次追加，更新時取代該 block。 |
| `merge-toml` | `.codex/config.toml` | 合併簡單 table／key；第一版 Pack 只匯出 `[agents]`。 |
| `replace` | agents、skills、驗證器、測試 | 複製到相同相對路徑；同套件舊版由新版取代。 |

AGENTS markers：

```markdown
<!-- harness-package:web-team:start -->
...套件指示...
<!-- harness-package:web-team:end -->
```

## 更新與復原

目標 repo 保存：

```text
.harness/
├── installed/<name>.json
└── backups/<name>/<timestamp>/
```

Receipt 記錄上次安裝的 `contentHash`、來源套件、時間與受管路徑。更新前備份所有即將修改或刪除的檔案；安裝途中失敗時，以備份還原，並刪除本次新建檔案。

新版 manifest 不再宣告的 `replace` 檔案，若上次 receipt 顯示由同套件管理，更新時移除。不得掃描或刪除 receipt 以外的同目錄檔案。

## 安全限制

- 驗證每個 payload 的 SHA-256，拒絕未宣告的額外檔案。
- 拒絕 `.env`、`.npmrc`、`.pypirc`、私鑰、憑證容器與常見 credentials JSON。
- 拒絕 reparse point、symlink、junction 與任何逃出來源或目標根目錄的路徑。
- Pack 至少需要 `AGENTS.md`、一個自訂 agent 與一個 skill。
- Verify 失敗時不得進入 Install。
- 安裝只寫入 manifest 允許的 Harness 路徑與 `.harness/` 內部紀錄。
