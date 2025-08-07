@echo off
REM VS Code Setup with SharePoint Authentication
REM Configure these variables for your environment

set "siteUrl=https://yourtenant.sharepoint.com/sites/yoursite"
set "scriptPath=Shared Documents/Scripts/InitialiseVSCodeFolders.ps1"
set "localScript=%TEMP%\InitialiseVSCodeFolders.ps1"

REM Download and execute script using PowerShell with SharePoint authentication
powershell.exe -ExecutionPolicy Bypass -Command ^
"try { ^
    Import-Module SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue; ^
    if (Get-Module -Name SharePointPnPPowerShellOnline) { ^
        Connect-PnPOnline -Url '%siteUrl%' -UseWebLogin; ^
        Get-PnPFile -Url '%scriptPath%' -Path '%TEMP%' -Filename 'InitialiseVSCodeFolders.ps1' -AsFile; ^
    } else { ^
        $url = '%siteUrl%/_layouts/15/download.aspx?SourceUrl=/%scriptPath%'; ^
        Invoke-WebRequest -Uri $url -OutFile '%localScript%' -UseDefaultCredentials; ^
    } ^
} catch { ^
    Write-Host 'Authentication method failed, trying direct download...'; ^
    $directUrl = '%siteUrl%/%scriptPath%'; ^
    Invoke-WebRequest -Uri $directUrl -OutFile '%localScript%' -UseDefaultCredentials; ^
}"

REM Execute the downloaded script
if exist "%localScript%" (
    powershell.exe -ExecutionPolicy Bypass -File "%localScript%"
    del "%localScript%"
    echo VS Code setup completed successfully
) else (
    echo Failed to download script from SharePoint
    exit /b 1
)
