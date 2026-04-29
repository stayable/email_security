@echo off
REM ===========================================================
REM  sync.bat - one-click stage, commit, and push to main
REM  Double-click this file (or run from cmd) inside the repo.
REM ===========================================================

setlocal enabledelayedexpansion

REM Move to the folder this script lives in (the repo root)
cd /d "%~dp0"

echo.
echo === Email Security repo sync ===
echo Folder: %CD%
echo.

REM Verify we are inside a git repo
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERROR] This folder is not a git repository.
    echo         Make sure sync.bat lives inside the cloned repo.
    pause
    exit /b 1
)

REM Make sure we are on main
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set CURBRANCH=%%b
if /i not "!CURBRANCH!"=="main" (
    echo Switching from branch "!CURBRANCH!" to main...
    git checkout main
    if errorlevel 1 (
        echo [ERROR] Could not switch to main. Resolve manually.
        pause
        exit /b 1
    )
)

REM Pull latest first so we don't push on top of stale history
echo.
echo --- Pulling latest from origin/main ---
git pull origin main
if errorlevel 1 (
    echo [ERROR] Pull failed. Resolve conflicts and run sync.bat again.
    pause
    exit /b 1
)

REM Stage everything (new, modified, deleted)
echo.
echo --- Staging changes ---
git add -A

REM Bail out cleanly if nothing changed
git diff --cached --quiet
if not errorlevel 1 (
    echo Nothing to commit. Working tree clean.
    echo.
    pause
    exit /b 0
)

REM Show what will be committed
echo.
echo --- Files to commit ---
git status --short

REM Build a timestamped commit message; allow optional override as arg
set MSG=%*
if "%MSG%"=="" (
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set DT=%%I
    set TS=!DT:~0,4!-!DT:~4,2!-!DT:~6,2! !DT:~8,2!:!DT:~10,2!
    set MSG=Sync from local machine !TS!
)

echo.
echo --- Committing ---
echo Message: !MSG!
git commit -m "!MSG!"
if errorlevel 1 (
    echo [ERROR] Commit failed.
    pause
    exit /b 1
)

REM Push with simple retry on transient network errors
echo.
echo --- Pushing to origin/main ---
set ATTEMPT=1
:pushtry
git push -u origin main
if not errorlevel 1 goto pushdone
if !ATTEMPT! GEQ 4 (
    echo [ERROR] Push failed after !ATTEMPT! attempts.
    pause
    exit /b 1
)
set /a WAIT=2**!ATTEMPT!
echo Push failed. Retrying in !WAIT!s...
timeout /t !WAIT! /nobreak >nul
set /a ATTEMPT=!ATTEMPT!+1
goto pushtry

:pushdone
echo.
echo === Sync complete ===
echo.
pause
endlocal
