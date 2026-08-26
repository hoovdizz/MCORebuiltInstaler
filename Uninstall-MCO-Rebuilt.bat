@echo off
setlocal
title Motor City Online Rebuilt Uninstaller v0.9

set "SCRIPT=%~dp0Uninstall-MCO-Rebuilt.ps1"

if not exist "%SCRIPT%" (
    echo ERROR: Uninstall-MCO-Rebuilt.ps1 was not found.
    pause
    exit /b 1
)

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
if not "%errorlevel%"=="0" pause

endlocal
