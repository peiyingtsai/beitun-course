# 北屯冰場 課程/裝備 系統 — 部署與交接說明

> 這是原本 Claude Artifact 版本（<https://claude.ai/code/artifact/37d0931d-5a68-4f28-a990-f27281240d5c>）
> 的獨立版。改用 **Supabase** 當共享雲端資料庫、部署到 **Netlify**，
> 這樣不需要 Claude Team，**只要把網址給同事，大家就能同時編輯、即時同步**。
> 建置方式參考 `C:\Users\PY\inventory-app`。

---

## 檔案

| 檔案 | 用途 |
|---|---|
| `index.html` | 整個系統（單一檔，含所有畫面與邏輯） |
| `config.js` | Supabase 連線設定（URL + anon key） |
| `supabase-schema.sql` | 在 Supabase 建表 + 匯入現有資料的腳本（貼到 SQL Editor 跑一次） |
| `本機測試.bat` | 在這台電腦本機開啟測試（`http://localhost:8090`，需要 Python） |

---

## 一次性設定（約 10 分鐘）

### 第一步：建立雲端資料庫

**選項 A（最省事）：用現有的 Supabase 專案**
`config.js` 已經預先填好「元量子倉庫系統」那個 Supabase 專案。你只要：

1. 登入 <https://supabase.com>，打開那個專案
2. 左側 **SQL Editor → New query**
3. 打開 `supabase-schema.sql`，整份複製貼上，按 **Run**
   - 會建立 `bt_kv` 這張表（跟倉庫系統的表互不影響），並把目前 Artifact 裡的
     學員、價目表、9 月點名、收款、裝備資料一起匯入
   - 重複執行不會出錯、也不會覆蓋既有資料
4. 完成，`config.js` 不用改

**選項 B：用全新的獨立 Supabase 專案**
1. <https://supabase.com> → New Project（免費）
2. SQL Editor 跑 `supabase-schema.sql`
3. **Project Settings → API**，複製 **Project URL** 和 **anon public** key
4. 貼到 `config.js` 的 `url` / `anonKey`，存檔

### 第二步：部署成公開網址（Netlify Drop）

手機要用、要給同事，就需要一個 `https://` 網址（不能只用 localhost）。
這台電腦沒裝 git，所以下面兩種都用**瀏覽器操作**就好。

#### 方式 A：GitHub Pages（推薦，跟你想的一樣用 GitHub）

1. 到 <https://github.com> → 右上角 **＋ → New repository**
   - 名稱例如 `beitun-course`
   - 選 **Public**（GitHub Pages 免費版需要 Public repo；`config.js` 裡只有 Supabase
     anon key，本來就是設計成可公開的，安全性靠資料庫端，跟 Netlify 上一樣）
   - 按 **Create repository**
2. 在新 repo 頁面點 **uploading an existing file**，把 `C:\Users\PY\beitun-course-app`
   資料夾裡**所有檔案**拖進去（`index.html`、`config.js`、`supabase-schema.sql`、
   `.nojekyll`、`README.md`），下方按 **Commit changes**
3. 進 repo 的 **Settings → Pages**
   - Source 選 **Deploy from a branch**
   - Branch 選 **main** / **/(root)** → **Save**
4. 等 1～2 分鐘，頁面上方會出現網址：`https://<你的帳號>.github.io/beitun-course/`
   — 這就是給同事的網址
5. **之後要更新**：在 GitHub 網頁上點該檔案 → 鉛筆圖示編輯，或重新上傳覆蓋，
   Commit 後約 1 分鐘自動重新部署，網址不變

> 想用 Private repo：改用 **Cloudflare Pages** 或 **Netlify**，在它們網站上
> 「Import from Git / 連接 GitHub」選這個 repo，就能免費部署 private repo 並自動更新。

#### 方式 B：Netlify Drop（最快，30 秒，不用 GitHub）

1. 開啟 <https://app.netlify.com/drop>
2. 把整個 `C:\Users\PY\beitun-course-app` 資料夾**直接拖進網頁**
3. 幾秒後產生 `https://xxxx.netlify.app` 網址
4. 建議申請免費帳號「認領」，之後把資料夾再拖一次就覆蓋更新，網址不變

### 第三步：分享

把網址（GitHub Pages 或 Netlify）傳給同事就好。
**不需要 Claude 帳號、不需要 Claude Team。**
每個人打開都是同一份資料，一邊改另一邊即時看到。

---

## 使用說明

功能與操作跟原本的 Artifact 版一樣，完整說明見：
`C:\Users\PY\Desktop\玉山银行\元量子Quantum Element\台中北屯\北屯冰場課程系統_使用與分享說明.md`

重點：
- 左下角先設「你的姓名」、切換「業務 / 管理者」（管理者密碼預設 `681113`，可在設定改）
- 「課程對帳 / 裝備銷售對帳」只有管理者看得到
- 資料即時雲端同步；離線時仍可看（localStorage 鏡射），連線後自動同步

---

## 安全性提醒

`bt_kv` 對前端 anon 開放完整讀寫，**只要知道 Netlify 網址理論上都能存取／修改資料**。
這對「內部同事共用」是可接受的做法（跟倉庫系統一樣）。管理者密碼只是前端畫面層級的
區隔，不是真正的權限控管。若之後有更高安全需求，需導入 Supabase Auth + RLS。

---

## 後續修改

要改功能，把需求連同這個路徑給 AI 或工程師：
> 「請修改 `C:\Users\PY\beitun-course-app` 的北屯冰場系統，我想要…」

- 畫面與邏輯：`index.html`（單一檔，搜尋 `viewOverview` / `viewAttend` / `reconcile` 等）
- 資料層（Supabase）：`index.html` 開頭的 `DBShim` / `initDB` / `startRealtime`
- 資料表結構：目前只有 `bt_kv`（key-value），不需要改結構就能加新功能

*文件日期：2026-09-08*
