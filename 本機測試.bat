@echo off
chcp 65001 >nul
title 北屯冰場 課程/裝備 系統 - 本機測試
echo.
echo   北屯冰場 課程/裝備 系統
echo   本機測試伺服器啟動中...
echo.
echo   網址: http://localhost:8090
echo   按 Ctrl+C 可關閉
echo.
cd /d "C:\Users\PY\beitun-course-app"
start http://localhost:8090
python -m http.server 8090
