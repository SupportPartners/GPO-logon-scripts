@echo off
REM VS Code Setup with SharePoint Authentication
REM Configure these variables for your environment

set "siteUrl=https://supportpartners.sharepoint.com/sites/Support"
set "scriptPath=Shared Documents/General/Scripts/InitialiseVSCodeFolders_Enhanced.ps1"
set "localScript=%TEMP%\InitialiseVSCodeFolders_Enhanced.ps1"
set "directDownloadUrl=https://supportpartners.sharepoint.com/sites/Support/_layouts/15/download.aspx?SourceUrl=/sites/Support/Shared%20Documents/General/Scripts/InitialiseVSCodeFolders_Enhanced.ps1"

REM Download and execute script using PowerShell with SharePoint authentication
powershell.exe -ExecutionPolicy Bypass -Command ^
"try { ^
    Write-Host 'Downloading VS Code setup script from SharePoint...'; ^
    $directUrl = '%directDownloadUrl%'; ^
    $localPath = '%localScript%'; ^
    Invoke-WebRequest -Uri $directUrl -OutFile $localPath -UseDefaultCredentials; ^
    Write-Host 'Script downloaded successfully'; ^
} catch { ^
    Write-Host 'Direct download failed, trying alternative method...'; ^
    try { ^
        Import-Module SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue; ^
        if (Get-Module -Name SharePointPnPPowerShellOnline) { ^
            Connect-PnPOnline -Url '%siteUrl%' -UseWebLogin; ^
            Get-PnPFile -Url '%scriptPath%' -Path '%TEMP%' -Filename 'InitialiseVSCodeFolders_Enhanced.ps1' -AsFile; ^
        } else { ^
            Write-Host 'PnP PowerShell not available, trying basic web request...'; ^
            $fallbackUrl = '%siteUrl%/%scriptPath%'; ^
            Invoke-WebRequest -Uri $fallbackUrl -OutFile '%localScript%' -UseDefaultCredentials; ^
        } ^
    } catch { ^
        Write-Host 'All download methods failed: ' + $_.Exception.Message; ^
        exit 1; ^
    } ^
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
