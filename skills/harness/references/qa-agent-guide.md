# QA Agent 設計指南

在 Build Harness 中納入 QA Agent 時可參考的指南。這份指南以實際專案（SatangSlide）中發現的 bug 模式與其根本原因分析為基礎，提供一套系統化的驗證方法，幫助捕捉 QA 容易漏掉的缺陷。

---

## 目錄

1. QA Agent 容易遺漏的缺陷模式
2. 整合一致性驗證（Integration Coherence Verification）
3. QA Agent 設計原則
4. 驗證檢查清單範本
5. QA Agent 定義範本

---

## 1. QA Agent 容易遺漏的缺陷模式

### 1-1. 邊界面不一致（Boundary Mismatch）

這是最常見的缺陷。兩個元件各自都「正確」實作了，但在連接點上的契約卻對不上。

| 邊界面 | 不一致範例 | 容易漏掉的原因 |
|--------|-----------|-----------|
| API 回應 → 前端 hook | API 回傳 `{ projects: [...] }`，hook 卻預期 `SlideProject[]` | 各自單獨驗證時都正常，但沒有做交叉比對 |
| API 回應欄位名稱 → 型別定義 | API 使用 `thumbnailUrl`（camelCase），型別使用 `thumbnail_url`（snake_case） | 若用 TypeScript generic 進行 casting，compiler 抓不到 |
| 檔案路徑 → 連結 href | 頁面在 `/dashboard/create`，但連結寫成 `/create` | 沒有交叉比對檔案結構與 href |
| 狀態轉移圖 → 實際 status 更新 | 圖上定義 `generating_template → template_approved`，但程式碼漏了這段轉移 | 只確認圖存在，沒有追蹤所有更新程式碼 |
| API endpoint → 前端 hook | API 存在，但沒有對應的 hook（未被呼叫） | 沒有把 API 清單與 hook 清單做 1:1 對應 |
| 即時回應 → 非同步結果 | API 立即回傳 `{ status }`，前端卻去讀 `data.failedIndices` | 沒有區分同步／非同步回應，只檢查型別 |

### 1-2. 為什麼靜態程式碼審查抓不到

- **TypeScript generic 的限制**：`fetchJson<SlideProject[]>()`，即使執行期回應其實是 `{ projects: [...] }`，仍然能通過編譯
- **`npm run build` 通過 ≠ 正常運作**：只要用了 type casting、`any` 或 generic，build 雖然成功，執行期仍可能失敗
- **存在驗證 vs 連接驗證的差異**：「API 是否存在？」與「API 回應是否符合呼叫端預期？」是完全不同的驗證問題

---

## 2. 整合一致性驗證（Integration Coherence Verification）

這是 QA Agent 必須納入的 **交叉比對驗證** 區域。

### 2-1. API 回應 ↔ 前端 hook 型別交叉驗證

**方法**：比較各 API route 中的 `NextResponse.json()` 呼叫處，與對應 hook 的 `fetchJson<T>` 型別參數。

```
驗證步驟：
1. 從 API route 中擷取傳給 NextResponse.json() 的物件 shape
2. 確認對應 hook 中 fetchJson<T> 的 T 型別
3. 比較 shape 與 T 是否一致
4. 檢查是否有 wrapping（若 API 回傳 { data: [...] }，hook 是否有取出 .data）
```

**特別要注意的模式：**
- 分頁 API：`{ items: [], total, page }` vs 前端預期陣列
- snake_case DB 欄位 → camelCase API 回應 → 前端型別定義之間的不一致
- 即時回應（202 Accepted）與最終結果 shape 不同

### 2-2. 檔案路徑 ↔ 連結／路由路徑對應

**方法**：擷取 `src/app/` 底下 page 檔案的 URL 路徑，並與程式碼中的所有 `href`、`router.push()`、`redirect()` 值比對。

```
驗證步驟：
1. 從 src/app/ 底下 page.tsx 檔案路徑擷取 URL pattern
   - (group) → 從 URL 中移除
   - [param] → 動態 segment
2. 蒐集程式碼中所有 href=、router.push(、redirect( 值
3. 確認每個連結是否都能對應到實際存在的 page 路徑
4. 注意 route group 內頁面的 URL 前綴（例如：dashboard/ 底下）
```

### 2-3. 狀態轉移完整性追蹤

**方法**：擷取程式碼中所有 `status:` 更新，並與狀態轉移圖比對。

```
驗證步驟：
1. 從狀態轉移圖（STATE_TRANSITIONS）中擷取允許的轉移清單
2. 在所有 API route 中搜尋 .update({ status: "..." }) pattern
3. 確認每個轉移都已在圖中定義
4. 找出圖中有定義、但程式碼未執行的轉移（dead transition）
5. 特別確認：從中間狀態（例如 generating_template）到最終狀態（template_approved）的轉移是否遺漏
```

### 2-4. API endpoint ↔ 前端 hook 1:1 對應

**方法**：列出所有 API route 與前端 hook，確認是否一一成對。

```
驗證步驟：
1. 從 src/app/api/ 底下 route.ts 擷取各 HTTP method 的 endpoint 清單
2. 從 src/hooks/ 底下 use*.ts 擷取 fetch 呼叫 URL 清單
3. 找出 API endpoint 中未被 hook 呼叫的項目 → 標記為「未使用」
4. 判斷「未使用」是否為預期（例如管理 API），或其實是漏掉呼叫
```

---

## 3. QA Agent 設計原則

### 3-1. 使用 general-purpose 類型，而不是 Explore 類型

如果 QA Agent 是 `Explore` 類型，它只能讀取內容。但有效的 QA 需要：
- 用 Grep 搜尋 pattern（例如擷取所有 `NextResponse.json()`）
- 執行 script 自動比對（API shape vs hook 型別）
- 必要時也能直接修改

**建議**：將類型設定為 `general-purpose`，但在 agent 定義中明確寫出「驗證 → 回報 → 提出修正請求」的流程。

### 3-2. 檢查清單應優先重視「交叉比對」，而非「存在確認」

| 較弱的檢查清單 | 較強的檢查清單 |
|---------------|---------------|
| API endpoint 是否存在？ | API endpoint 的回應 shape 是否與對應 hook 型別一致？ |
| 狀態轉移圖是否有定義？ | 所有 status 更新程式碼是否與圖中的轉移一致？ |
| 頁面檔案是否存在？ | 程式碼中所有連結是否都指向實際存在的頁面？ |
| 是否開啟 TypeScript strict mode？ | 是否存在用 generic casting 繞過的型別安全問題？ |

### 3-3. 「兩邊同時讀」原則

若 QA 想抓出邊界面 bug，就不能只讀一邊。一定要：
- 將 API route **和** 對應 hook **一起** 看
- 將狀態轉移圖 **和** 實際更新程式碼 **一起** 看
- 將檔案結構 **和** 連結路徑 **一起** 看

請在 agent 定義中明確寫下這個原則。

### 3-4. QA 不該只在 build 後執行，而應在各模組完成後立刻執行

若 orchestrator 只把 QA 放在「Phase 4：全部完成後」：
- bug 會累積，修正成本變高
- 早期的邊界面不一致會傳播到後續模組

**建議 pattern**：每當某個後端 API 完成時，就立刻對該 API 與對應 hook 做交叉驗證（incremental QA）。

---

## 4. 驗證檢查清單範本

可放入 QA Agent 定義中的 Web 應用整合一致性檢查清單。

```markdown
### 整合一致性驗證（Web app）

#### API ↔ Frontend 連接
- [ ] 所有 API route 的回應 shape 與對應 hook 的 generic 型別一致
- [ ] 被包裹的回應（{ items: [...] }）有在 hook 中正確 unwrap
- [ ] snake_case ↔ camelCase 轉換套用一致
- [ ] 前端有區分即時回應（202）與最終結果的 shape
- [ ] 每個 API endpoint 都有對應的前端 hook，且實際有被呼叫

#### 路由一致性
- [ ] 程式碼中所有 href/router.push 值都與實際的 page 檔案路徑相符
- [ ] 路徑驗證時有考慮 route group（(group)）會從 URL 中移除
- [ ] 動態 segment（[id]）會以正確參數填入

#### 狀態機一致性
- [ ] 所有已定義的狀態轉移都會在程式碼中執行（沒有 dead transition）
- [ ] 程式碼中的所有 status 更新都已定義在轉移圖中（沒有未授權轉移）
- [ ] 從中間狀態到最終狀態的轉移沒有遺漏
- [ ] 前端中基於狀態的分支（if status === "X"）之 X 實際可達

#### 資料流一致性
- [ ] DB schema 欄位名稱與 API 回應欄位名稱的對應一致
- [ ] 前端型別定義與 API 回應欄位名稱一致
- [ ] optional 欄位的 null/undefined 處理在兩邊都一致
```

---

## 5. QA Agent 定義範本

可放入 Build Harness QA Agent 的核心區段。

```markdown
---
name: qa-inspector
description: "QA 驗證專家。驗證規格遵循、整合一致性與設計品質。"
---

# QA Inspector

## 核心角色
驗證實作是否符合規格，並確認**模組之間的整合一致性**。

## 驗證優先順序

1. **整合一致性**（最高）— 邊界面不一致是執行期錯誤的主要來源
2. **功能規格遵循** — API / state machine / data model
3. **設計品質** — 色彩 / typography / 響應式
4. **程式碼品質** — 未使用程式碼、命名規則

## 驗證方法：「同時閱讀兩側」

邊界面驗證時，必須**同時打開兩邊的程式碼**進行比對：

| 驗證對象 | 左側（生產者） | 右側（消費者） |
|----------|-------------|---------------|
| API 回應 shape | route.ts 的 NextResponse.json() | hooks/ 中的 fetchJson<T> |
| 路由 | src/app/ page 檔案路徑 | href、router.push 值 |
| 狀態轉移 | STATE_TRANSITIONS 圖 | .update({ status }) 程式碼 |
| DB → API → UI | 資料表欄位名稱 | API 回應欄位 → 型別定義 |

## 團隊溝通協定

- 一旦發現問題，立刻向對應 agent 發出具體修正請求（檔案:行號 + 修正方式）
- 邊界面問題要**同時**通知兩側的 agent
- 向 leader 回報：驗證報告（區分通過／失敗／未驗證項目）
```

---

## 實際案例：SatangSlide 中發現的 bug

本指南的所有內容，都來自下列真實 bug 所萃取出的教訓：

| bug | 邊界面 | 原因 |
|------|--------|------|
| `projects?.filter is not a function` | API→hook | API 回傳 `{projects:[]}`，hook 預期陣列 |
| Dashboard 所有連結都 404 | 檔案路徑→href | 漏掉 `/dashboard/` 前綴 |
| Theme 圖片看不到 | API→component | `thumbnailUrl` vs `thumbnail_url` |
| Theme 選擇無法儲存 | API→hook | select-theme API 存在，但沒有 hook |
| 生成頁面永遠等待中 | 狀態轉移→程式碼 | 漏掉 `template_approved` 轉移程式碼 |
| `data.failedIndices` crash | 即時回應→前端 | 在即時回應中存取背景結果 |
| 完成後查看 slide 404 | 檔案路徑→href | `/projects/` → `/dashboard/projects/` |
