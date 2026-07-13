# Codex 相容性與執行模型

本文件說明 Harness 2.x 所依賴的 Codex 功能、權限模型與未來相容策略。

## 依賴的 Codex 能力

| 能力 | 用途 | 是否必要 |
|---|---|---|
| Skills | 載入 Harness 與產生出的 Orchestrator | 是 |
| `.codex-plugin/plugin.json` | 外掛識別與技能封裝 | 以外掛安裝時必要 |
| `AGENTS.md` | 保存專案長期指示與 Harness 入口 | 是 |
| `.codex/agents/*.toml` | 定義自訂代理人、權限與工具 | 多代理 Harness 必要 |
| Subagents | 平行或階段式委派 | 多代理 Harness 必要 |
| `.codex/config.toml` | 控制併發、深度與專案設定 | 需要自訂執行限制時必要 |

Codex 現行版本預設啟用子代理工作流程，不需要額外的實驗性環境變數。主代理人會在使用者直接要求，或適用的 `AGENTS.md`／Skill 指示要求時委派子代理人。

## 支援的使用介面

| 介面 | Harness Skill | 自訂代理人與 Subagents | Plugins |
|---|---|---|---|
| ChatGPT 桌面版中的 Codex | 支援 | 支援 | 支援 |
| Codex CLI | 支援 | 支援 | 支援瀏覽與安裝 |
| Codex IDE Extension | 支援 Skill | 可顯示子代理活動 | 外掛安裝能力依介面版本而定 |
| Codex Cloud | 可讀專案指示與 Skill | 依執行環境能力 | 依工作區設定 |

若目標介面不提供子代理能力，Orchestrator 必須降級為主代理人依序執行各角色，仍保留階段、產物與驗證邊界。

## 自訂代理人格式

專案代理人放在 `.codex/agents/*.toml`。每個檔案至少包含：

```toml
name = "reviewer"
description = "唯讀審查者，檢查正確性、風險與缺少的測試。"
developer_instructions = """
根據可驗證證據進行審查，回傳檔案位置、影響與驗收建議。
不要修改檔案。
"""
```

可選欄位包括 `nickname_candidates`、`model`、`model_reasoning_effort`、`sandbox_mode`、`mcp_servers` 與 `skills.config`。

Harness 未收到明確需求時不固定模型，使設定能繼承父工作階段並降低版本漂移。

## 併發與深度

```toml
[agents]
max_threads = 4
max_depth = 1
```

- `max_threads` 限制同時開啟的代理工作數。
- `max_depth = 1` 允許主代理人委派直接子代理人，但不讓子代理人繼續遞迴委派。
- 只有 Hierarchical Delegation 等明確需要時才提高深度。

## 權限與安全

子代理人繼承父工作階段的 permission mode，也能在自訂代理人中以 `sandbox_mode` 進一步限制。

Harness 的預設策略：

- 探索、研究、審查與 QA：`read-only`
- 實作與修正：繼承父工作階段允許的寫入權
- 同一份最終產物：單一寫入者
- 外部 MCP 或 API：只授予完成任務所需的最小工具與權限

## 外部憑證

Harness 核心不需要 OpenAI API Key。若自訂代理人要使用私有 MCP 或外部 API，必須在設定前向使用者取得：

1. 服務與環境名稱。
2. Base URL 或 MCP 端點。
3. 驗證方式與環境變數名稱。
4. 所需最小 scopes／permissions。
5. 測試方式與可使用資料。

不得在 `.codex/config.toml`、代理人 TOML、Skill、`AGENTS.md` 或 Git 中保存密鑰。

## 版本變更策略

Codex 的自訂代理人格式與外掛功能仍可能演進。當官方文件或實際執行行為改變時：

| 時限 | 動作 |
|---|---|
| 24 小時內 | 建立相容性問題，記錄受影響功能與可重現證據 |
| 48 小時內 | 更新 skill、範本、驗證器與快速開始 |
| 72 小時內 | 發布修正版與遷移說明 |

更新時以目前 Codex 官方文件與可執行環境為準，不依賴舊的工具名稱或記憶。

## 官方參考

- [Codex Skills 與 Plugins](https://learn.chatgpt.com/docs/skills-and-plugins)
- [建立 Codex Plugins](https://learn.chatgpt.com/docs/build-plugins)
- [Codex Subagents 與自訂代理人](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [AGENTS.md 自訂指示](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Codex 客製化概覽](https://learn.chatgpt.com/docs/customization/overview)

最後更新：2026-07-14
