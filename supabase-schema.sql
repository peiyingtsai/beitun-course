-- =====================================================================
-- 北屯冰場 課程/裝備 系統 — Supabase 資料庫初始化腳本
--
-- 使用方式：
-- 1. 到 https://supabase.com 建立免費帳號 + 新專案（或用你現有的專案）
-- 2. 左側選單 → SQL Editor → New query
-- 3. 把這整份檔案貼進去 → 按 Run（只需執行一次；重複執行也不會出錯）
-- 4. 到 Project Settings → API，複製 Project URL 和 anon public key，
--    貼到同資料夾的 config.js
--
-- 資料模型：整個系統的狀態存成「一個 key 對一份 JSON」在 bt_kv 這張表，key 有：
--   config/settings、roster/students、attend/<YYYY-MM>、
--   pay/<year>、bank/<year>、inv/items、inv/moves-<year>
-- 前端用 Supabase Realtime 訂閱 bt_kv，任何一台裝置改動，其他裝置即時同步。
--
-- 安全性：這是內部工具，bt_kv 對 anon（前端）開放完整讀寫，只要知道網址
-- 理論上都能存取。若之後需要更嚴格的權限，再導入 Supabase Auth + RLS。
-- =====================================================================

create table if not exists public.bt_kv (
  k text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.bt_kv enable row level security;

grant select, insert, update, delete on public.bt_kv to anon, authenticated;

drop policy if exists "bt_kv anon full access" on public.bt_kv;
create policy "bt_kv anon full access" on public.bt_kv for all using (true) with check (true);

-- 即時同步：把 bt_kv 加進 Supabase Realtime 的 publication
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'bt_kv'
  ) then
    alter publication supabase_realtime add table public.bt_kv;
  end if;
end $$;

-- =====================================================================
-- 種子資料（從 Claude Artifact 版本匯出的現有資料，2026-09-08）
-- ON CONFLICT DO NOTHING：如果 bt_kv 已經有同一個 key 就不覆蓋
-- =====================================================================

insert into public.bt_kv (k, value) values
  ('config/settings', $j$
{
  "classes": [
    {
      "id": "mtsj1ztvgrdzj",
      "name": "訓練營",
      "note": ""
    },
    {
      "id": "mtsj1ztvmhi2v",
      "name": "基礎-1",
      "note": ""
    },
    {
      "id": "mtsj1ztvyrk1e",
      "name": "基礎-2",
      "note": ""
    },
    {
      "id": "mtsj1ztvg3j68",
      "name": "進階-1",
      "note": ""
    },
    {
      "id": "mtsj1ztv71b6q",
      "name": "進階-2",
      "note": ""
    },
    {
      "id": "mtsj1ztvbe36y",
      "name": "成人班",
      "note": ""
    }
  ],
  "managerPin": "681113",
  "price": {
    "1": [
      {
        "id": "mon1",
        "label": "基礎滑冰",
        "price": 600,
        "time": "18:00–19:00"
      },
      {
        "id": "mon2",
        "label": "基礎曲棍",
        "price": 800,
        "time": "19:00–20:00"
      },
      {
        "id": "mon3",
        "label": "成人體驗",
        "price": 600,
        "time": "20:00–21:00"
      }
    ],
    "2": [
      {
        "id": "mtsj1ztvolt65",
        "label": "進階1",
        "price": 1200,
        "time": "18:00–19:20"
      },
      {
        "id": "mtsj1ztvfmqw7",
        "label": "進階2",
        "price": 1200,
        "time": "19:30–21:00"
      }
    ],
    "3": [
      {
        "id": "mtsj1ztvulfzq",
        "label": "訓練營",
        "price": 1200,
        "time": "18:00–19:20"
      },
      {
        "id": "mtsj1ztv1avs0",
        "label": "成人之夜",
        "price": 600,
        "time": "19:30–21:00"
      }
    ]
  }
}
$j$::jsonb)
on conflict (k) do nothing;

insert into public.bt_kv (k, value) values
  ('roster/students', $j$
{
  "students": [
    {
      "active": true,
      "birthday": "2017-11-30",
      "email": "cathy0719huang",
      "id": "s01",
      "last5": "59388",
      "mobile": "0975158719",
      "name": "徐婉庭",
      "note": "",
      "parent": "黃可欣",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2015-08-05",
      "email": "cathy0719huang",
      "id": "s02",
      "last5": "59388",
      "mobile": "0975158719",
      "name": "徐匯蓉",
      "note": "與徐婉庭同一家長",
      "parent": "黃可欣",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2016-11-23",
      "email": "",
      "id": "s03",
      "last5": "85473",
      "mobile": "0963143899",
      "name": "陳盈榛",
      "note": "",
      "parent": "陳正華",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2018-01-22",
      "email": "",
      "id": "s04",
      "last5": "85473",
      "mobile": "0963143899",
      "name": "陳盈孜",
      "note": "",
      "parent": "陳正華",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2001-02-11",
      "email": "",
      "id": "s05",
      "last5": "83654",
      "mobile": "0909916725",
      "name": "張哲甄",
      "note": "",
      "parent": "張志銘",
      "parentPhone": "0935378725"
    },
    {
      "active": true,
      "birthday": "2015-12-11",
      "email": "qqtang0314",
      "id": "s06",
      "last5": "33505",
      "mobile": "0956661921",
      "name": "唐楷程",
      "note": "家長電話欄原記：陳巧",
      "parent": "陳巧芸",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2013-01-22",
      "email": "",
      "id": "s07",
      "last5": "26068",
      "mobile": "0923246346",
      "name": "林暘騰",
      "note": "與林暘娜同家長（雙胞胎）",
      "parent": "彭晁汝",
      "parentPhone": "0923246346"
    },
    {
      "active": true,
      "birthday": "2013-01-22",
      "email": "",
      "id": "s08",
      "last5": "26068",
      "mobile": "0923246346",
      "name": "林暘娜",
      "note": "",
      "parent": "彭晁汝",
      "parentPhone": "0923246346"
    },
    {
      "active": true,
      "birthday": "1990-11-09",
      "email": "hung_wen",
      "id": "s09",
      "last5": "20924",
      "mobile": "0921397140",
      "name": "林弘文",
      "note": "成人",
      "parent": "林郁芬",
      "parentPhone": "0921339944"
    },
    {
      "active": true,
      "birthday": "2015-03-21",
      "email": "kaylapeng520",
      "id": "s10",
      "last5": "10826",
      "mobile": "0978228667",
      "name": "徐張宇弘",
      "note": "曾與徐張宥綸 9/14 費用一起匯共 2000",
      "parent": "徐彭思婷",
      "parentPhone": "0978228668"
    },
    {
      "active": true,
      "birthday": "2018-08-25",
      "email": "kaylapeng520",
      "id": "s11",
      "last5": "10826",
      "mobile": "0978228667",
      "name": "徐張宥綸",
      "note": "",
      "parent": "彭思婷",
      "parentPhone": "0978228668"
    },
    {
      "active": true,
      "birthday": "2016-01-30",
      "email": "Chiu-haiko",
      "id": "s12",
      "last5": "35018",
      "mobile": "0983227354",
      "name": "陳苡恩",
      "note": "",
      "parent": "陳典旻",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "2017-04-21",
      "email": "Chiu-haiko",
      "id": "s13",
      "last5": "35018",
      "mobile": "0983227354",
      "name": "陳苡琇",
      "note": "",
      "parent": "陳典旻",
      "parentPhone": ""
    },
    {
      "active": true,
      "birthday": "1973-08-31",
      "email": "bikerdhc",
      "id": "s14",
      "last5": "44174",
      "mobile": "0988003020",
      "name": "Ryan Carroll",
      "note": "成人",
      "parent": "Angela",
      "parentPhone": "0929366641"
    },
    {
      "active": true,
      "birthday": "2017-09-07",
      "email": "weng-yeng liang",
      "id": "s15",
      "last5": "29389",
      "mobile": "0921540597",
      "name": "梁以昕",
      "note": "",
      "parent": "梁文彥",
      "parentPhone": "0921540597"
    },
    {
      "active": true,
      "birthday": "2019-11-06",
      "email": "weng-yeng liang",
      "id": "s16",
      "last5": "29389",
      "mobile": "0921540597",
      "name": "梁里齊",
      "note": "",
      "parent": "梁文彥",
      "parentPhone": "0921540597"
    },
    {
      "active": true,
      "birthday": "1985-06-14",
      "email": "timchang5",
      "id": "s17",
      "last5": "34407",
      "mobile": "0983770896",
      "name": "張誌中",
      "note": "成人",
      "parent": "",
      "parentPhone": ""
    }
  ]
}
$j$::jsonb)
on conflict (k) do nothing;

insert into public.bt_kv (k, value) values
  ('attend/2026-09', $j$
{
  "cells": {
    "s01|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s02|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s03|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s03|2026-09-16": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s03|2026-09-21": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 1
      }
    ],
    "s03|2026-09-23": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s03|2026-09-30": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s04|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s04|2026-09-16": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s04|2026-09-21": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 1
      }
    ],
    "s04|2026-09-23": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s04|2026-09-30": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s05|2026-09-21": [
      {
        "classId": "mtsj1ztvbe36y",
        "slot": 0
      }
    ],
    "s05|2026-09-28": [
      {
        "classId": "mtsj1ztvbe36y",
        "slot": 0
      }
    ],
    "s06|2026-09-08": [
      {
        "classId": "mtsj1ztvg3j68",
        "slot": 0
      }
    ],
    "s06|2026-09-15": [
      {
        "classId": "mtsj1ztvg3j68",
        "slot": 0
      }
    ],
    "s06|2026-09-22": [
      {
        "classId": "mtsj1ztvg3j68",
        "slot": 0
      }
    ],
    "s06|2026-09-29": [
      {
        "classId": "mtsj1ztvg3j68",
        "slot": 0
      }
    ],
    "s07|2026-09-08": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s07|2026-09-15": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s07|2026-09-22": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s07|2026-09-29": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s08|2026-09-08": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s08|2026-09-15": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s08|2026-09-22": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s08|2026-09-29": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s09|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s09|2026-09-16": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s09|2026-09-23": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s09|2026-09-30": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s10|2026-09-08": [
      {
        "classId": "mtsj1ztvg3j68",
        "slot": 0
      }
    ],
    "s11|2026-09-14": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 0
      }
    ],
    "s12|2026-09-08": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s13|2026-09-08": [
      {
        "classId": "mtsj1ztv71b6q",
        "slot": 1
      }
    ],
    "s14|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s14|2026-09-23": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s14|2026-09-30": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s15|2026-09-14": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 0
      }
    ],
    "s15|2026-09-21": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 1
      }
    ],
    "s15|2026-09-28": [
      {
        "classId": "mtsj1ztvyrk1e",
        "slot": 1
      }
    ],
    "s16|2026-09-14": [
      {
        "classId": "mtsj1ztvmhi2v",
        "slot": 0
      }
    ],
    "s16|2026-09-21": [
      {
        "classId": "mtsj1ztvmhi2v",
        "slot": 0
      }
    ],
    "s16|2026-09-28": [
      {
        "classId": "mtsj1ztvmhi2v",
        "slot": 0
      }
    ],
    "s17|2026-09-09": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s17|2026-09-16": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s17|2026-09-23": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ],
    "s17|2026-09-30": [
      {
        "classId": "mtsj1ztvgrdzj",
        "slot": 0
      }
    ]
  },
  "dates": []
}
$j$::jsonb)
on conflict (k) do nothing;

insert into public.bt_kv (k, value) values
  ('pay/2026', $j$
{
  "rows": [
    {
      "allocs": [
        {
          "amount": 1200,
          "kind": "course",
          "sid": "s05",
          "ym": "2026-09"
        }
      ],
      "amount": 1200,
      "bankPaid": true,
      "cash": false,
      "date": "2026/8/11",
      "id": "mtsmcvv5bcebm",
      "last5": "83654",
      "matchDate": "2026/8/11",
      "matchTxnId": null,
      "note": "由銀行對帳建立",
      "payer": "張哲甄"
    },
    {
      "allocs": [
        {
          "amount": 1200,
          "kind": "course",
          "sid": "s01",
          "ym": "2026-09"
        },
        {
          "amount": 1200,
          "kind": "course",
          "sid": "s02",
          "ym": "2026-09"
        }
      ],
      "amount": 2400,
      "bankPaid": true,
      "cash": false,
      "date": "2026/8/19",
      "id": "mtsmdbuzr96y9",
      "last5": "59388",
      "matchDate": "2026/8/19",
      "matchTxnId": null,
      "note": "由銀行對帳建立",
      "payer": "徐婉庭、徐匯蓉"
    },
    {
      "allocs": [
        {
          "amount": 3600,
          "kind": "course",
          "sid": "s14",
          "ym": "2026-09"
        }
      ],
      "amount": 3600,
      "bankPaid": true,
      "cash": false,
      "date": "2026/9/1",
      "id": "mtsme570mo9dx",
      "last5": "44174",
      "matchDate": "2026/9/1",
      "matchTxnId": null,
      "note": "由銀行對帳建立",
      "payer": "Ryan Carroll"
    }
  ]
}
$j$::jsonb)
on conflict (k) do nothing;

insert into public.bt_kv (k, value) values
  ('inv/items', $j$
{
  "items": [
    {
      "id": "mtskx1inoeqh8",
      "name": "DK护具套装组（胸肘腿裤手套）YT-M",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1in1xiw6",
      "name": "DK护具套装组（胸肘腿裤手套）YT-L",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1in44um8",
      "name": "DK护具套装组（胸肘腿裤手套）JR-M",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1in4ek5k",
      "name": "DK护具套装组（胸肘腿裤手套）JR-L",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1in720fk",
      "name": "DK护具套装组（胸肘腿裤手套）SR-M",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1inukerp",
      "name": "CCM STARTER KIT 儿童款护具套装组（无包款）,YT,M",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1indkmmi",
      "name": "CCM STARTER KIT 儿童款护具套装组（无包款）,YT,L",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1in195p7",
      "name": "CCM TACKS 1092 冰球鞋,YT/D,28",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iobeaon",
      "name": "CCM TACKS 1092 冰球鞋,YT/D,30",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1io90ia0",
      "name": "CCM TACKS 1092 冰球鞋,YT/D,31",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iobp3tw",
      "name": "CCM TACKS 1092 冰球鞋,YT/D,32",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1io8jj95",
      "name": "CCM TACKS 1092 冰球鞋,JR/D,34",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1ioiumao",
      "name": "HUNGTA 梅花帽 XS / 藍",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1ioa02zy",
      "name": "HUNGTA 梅花帽 XS / 白",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1io75s77",
      "name": "HUNGTA 梅花帽 S / 藍",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iob8d1d",
      "name": "HUNGTA 梅花帽 S /粉",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1ioigup8",
      "name": "HUNGTA 梅花帽 S /白",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1ioku851",
      "name": "HUNGTA 梅花帽 M /白",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iojk80k",
      "name": "HUNGTA 梅花帽 L/黑",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1ioe2tpl",
      "name": "HUNGTA 硬式護具套組 S / 粉",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iog5a3b",
      "name": "HUNGTA 硬式護具套組 S / 藍",
      "note": "",
      "unit": ""
    },
    {
      "id": "mtskx1iocjz6i",
      "name": "HUNGTA 硬式護具套組 L / 粉",
      "note": "",
      "unit": ""
    }
  ]
}
$j$::jsonb)
on conflict (k) do nothing;

insert into public.bt_kv (k, value) values
  ('inv/moves-2026', $j$
{
  "moves": [
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv97cby9",
      "itemId": "mtskx1inoeqh8",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 3,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9jjir4",
      "itemId": "mtskx1in1xiw6",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9x6jsx",
      "itemId": "mtskx1in44um8",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 3,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv93em4x",
      "itemId": "mtskx1in4ek5k",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv96g65l",
      "itemId": "mtskx1in720fk",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 5,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9n7ans",
      "itemId": "mtskx1inukerp",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 3,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9jiuav",
      "itemId": "mtskx1indkmmi",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 3,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9rjlk0",
      "itemId": "mtskx1in195p7",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9o1c9n",
      "itemId": "mtskx1iobeaon",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9ol8tf",
      "itemId": "mtskx1io90ia0",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9sp33t",
      "itemId": "mtskx1iobp3tw",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9d5sdk",
      "itemId": "mtskx1io8jj95",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9dq7yu",
      "itemId": "mtskx1ioiumao",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9z7i2u",
      "itemId": "mtskx1ioa02zy",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9edesw",
      "itemId": "mtskx1io75s77",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 2,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv94obxv",
      "itemId": "mtskx1iob8d1d",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9j1cl6",
      "itemId": "mtskx1ioigup8",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9bieh6",
      "itemId": "mtskx1ioku851",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv96cla5",
      "itemId": "mtskx1iojk80k",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv90ykih",
      "itemId": "mtskx1ioe2tpl",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9fiz1z",
      "itemId": "mtskx1iog5a3b",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": false,
      "buyer": "",
      "cash": false,
      "date": "2026-09-08",
      "id": "mtslplv9goegx",
      "itemId": "mtskx1iocjz6i",
      "last5": "",
      "matchTxnId": null,
      "note": "",
      "price": 0,
      "qty": 1,
      "type": "transfer"
    },
    {
      "bankPaid": true,
      "buyer": "台中老外",
      "by": "小K",
      "cash": false,
      "createdAt": "2026-09-08T13:06:32.328Z",
      "date": "2026-09-08",
      "id": "mtsmv7gyirklj",
      "itemId": "mtskx1inoeqh8",
      "last5": "35204",
      "matchTxnId": null,
      "note": "",
      "price": 2800,
      "qty": 1,
      "type": "sale"
    }
  ]
}
$j$::jsonb)
on conflict (k) do nothing;
