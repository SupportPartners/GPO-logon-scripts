@echo off
REM VS Code Setup with GitHub Download
REM No authentication required - uses public GitHub repository

set "githubRepo=https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main"
set "scriptName=InitialiseVSCodeFolders_Enhanced_v3.0.ps1"
set "localScript=%TEMP%\%scriptName%"
set "logFile=%TEMP%\VSCodeSetup_Download.log"

echo Starting VS Code setup download from GitHub... > "%logFile%"
echo [%date% %time%] Repository: %githubRepo% >> "%logFile%"

REM Download script from GitHub
powershell.exe -ExecutionPolicy Bypass -Command ^
"try { ^
    Write-Host 'Downloading VS Code setup script from GitHub...'; ^
    $scriptUrl = '%githubRepo%/%scriptName%'; ^
    $localPath = '%localScript%'; ^
    Write-Host 'URL: ' + $scriptUrl; ^
    $ProgressPreference = 'SilentlyContinue'; ^
    Invoke-WebRequest -Uri $scriptUrl -OutFile $localPath -UseBasicParsing; ^
    if (Test-Path $localPath) { ^
        $fileSize = (Get-Item $localPath).Length; ^
        Write-Host 'Script downloaded successfully (' + $fileSize + ' bytes)'; ^
        Add-Content -Path '%logFile%' -Value '[SUCCESS] Downloaded script (' + $fileSize + ' bytes)'; ^
    } else { ^
        throw 'File was not created'; ^
    } ^
} catch { ^
    Write-Host 'GitHub download failed: ' + $_.Exception.Message; ^
    Add-Content -Path '%logFile%' -Value '[ERROR] GitHub download failed: ' + $_.Exception.Message; ^
    Write-Host 'Trying fallback method with different parameters...'; ^
    try { ^
        $webclient = New-Object System.Net.WebClient; ^
        $webclient.DownloadFile('%githubRepo%/%scriptName%', '%localScript%'); ^
        Write-Host 'Fallback download successful'; ^
        Add-Content -Path '%logFile%' -Value '[SUCCESS] Fallback download successful'; ^
    } catch { ^
        Write-Host 'All download methods failed: ' + $_.Exception.Message; ^
        Add-Content -Path '%logFile%' -Value '[FATAL] All download methods failed: ' + $_.Exception.Message; ^
        exit 1; ^
    } ^
}"

REM Execute the downloaded script
if exist "%localScript%" (
    echo Executing VS Code initialization script...
    echo [%date% %time%] Executing script: %localScript% >> "%logFile%"
    powershell.exe -ExecutionPolicy Bypass -File "%localScript%"
    set scriptExitCode=%ERRORLEVEL%
    
    REM Log execution result
    if %scriptExitCode% EQU 0 (
        echo [%date% %time%] Script executed successfully >> "%logFile%"
        echo VS Code setup completed successfully
    ) else (
        echo [%date% %time%] Script failed with exit code: %scriptExitCode% >> "%logFile%"
        echo VS Code setup failed - check log: %logFile%
    )
    
    REM Clean up downloaded script
    del "%localScript%" 2>nul
    echo [%date% %time%] Cleanup completed >> "%logFile%"
    
    exit /b %scriptExitCode%
) else (
    echo Failed to download script from GitHub
    echo [%date% %time%] FATAL: Failed to download script from GitHub >> "%logFile%"
    echo Check log file: %logFile%
    exit /b 1
)
