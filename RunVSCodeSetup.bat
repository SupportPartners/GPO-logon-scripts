@echo off
REM Download and execute PowerShell script from SharePoint
REM Replace YOUR_SHAREPOINT_URL with your actual SharePoint direct download URL

set "scriptUrl=https://yourtenant.sharepoint.com/sites/yoursite/Shared Documents/Scripts/InitialiseVSCodeFolders.ps1"
set "localScript=%TEMP%\InitialiseVSCodeFolders.ps1"

REM Download script from SharePoint
powershell.exe -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%scriptUrl%' -OutFile '%localScript%'"

REM Execute the downloaded script
if exist "%localScript%" (
    powershell.exe -ExecutionPolicy Bypass -File "%localScript%"
    del "%localScript%"
) else (
    echo Failed to download script from SharePoint
    exit /b 1
)
