// =====================================================================
// Supabase 連線設定（北屯冰場 課程/裝備 系統）
//
// 這裡預設填的是「元量子倉庫系統」同一個 Supabase 專案，資料表 bt_kv
// 與倉庫系統的資料表互不影響。你只要：
//   1. 到那個 Supabase 專案的 SQL Editor 執行 supabase-schema.sql（一次）
//   2. 部署這個資料夾（見 README.md）
// 就可以了，不需要改這個檔案。
//
// 若想用「全新的、獨立的」Supabase 專案：
//   1. 到 https://supabase.com 建新專案
//   2. SQL Editor 執行 supabase-schema.sql
//   3. Project Settings → API，把下面 url / anonKey 換成新專案的值
// =====================================================================
window.SUPABASE_CONFIG = {
  url: 'https://axqfnwoejvrrmvitengt.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4cWZud29lanZycm12aXRlbmd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMDk3MTUsImV4cCI6MjEwMjc4NTcxNX0.HxVWkYTVWQdTKv_4IJ-eIjiej_h1cADd-xmYwdnACgs'
};
