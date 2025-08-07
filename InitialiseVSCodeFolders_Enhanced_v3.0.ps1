# Enhanced VS Code Folder Initialization Script for AADDS GPO
# Version: 3.0
# Description: Creates and configures VS Code folders with proper permissions
# Features: Cross-platform compatible, GitHub self-updating, comprehensive logging
# Repository: https://github.com/SupportPartners/GPO-logon-scripts

param(
    [string]$LogPath = "$env:TEMP\VSCodeSetup.log",
    [switch]$UpdateFromGitHub = $false,
    [string]$GitHubRepo = "https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main"
)

# Script metadata
$ScriptVersion = "3.0"
$ScriptName = "InitialiseVSCodeFolders_Enhanced_v3.0.ps1"
$LastUpdated = "2025-08-07"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Color coding for different log levels
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor White }
    }
    
    try {
        Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Warning: Could not write to log file: $_" -ForegroundColor Yellow
    }
}

function Test-IsWindows {
    return ($IsWindows -or $env:OS -eq "Windows_NT" -or [System.Environment]::OSVersion.Platform -eq "Win32NT")
}

function Test-GitHubConnectivity {
    try {
        $testUrl = "$GitHubRepo/README.md"
        Write-Log "Testing GitHub connectivity to: $testUrl"
        $response = Invoke-WebRequest -Uri $testUrl -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Log "GitHub connectivity test successful (Status: $($response.StatusCode))" "SUCCESS"
        return $true
    } catch {
        Write-Log "GitHub connectivity test failed: $($_.Exception.Message)" "WARNING"
        return $false
    }
}

function Update-ScriptFromGitHub {
    if (-not (Test-GitHubConnectivity)) {
        Write-Log "Skipping GitHub update due to connectivity issues" "WARNING"
        return $false
    }
    
    try {
        $latestScriptUrl = "$GitHubRepo/$ScriptName"
        $tempScript = Join-Path $env:TEMP "latest_$ScriptName"
        
        Write-Log "Downloading latest script from: $latestScriptUrl"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $latestScriptUrl -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
        
        # Verify downloaded file
        if (Test-Path $tempScript) {
            $fileSize = (Get-Item $tempScript).Length
            Write-Log "Downloaded script successfully ($fileSize bytes)" "SUCCESS"
            
            # Replace current script (if running from file system)
            if ($MyInvocation.MyCommand.Path) {
                Copy-Item $tempScript $MyInvocation.MyCommand.Path -Force
                Write-Log "Script updated successfully. Please restart for changes to take effect." "SUCCESS"
            }
            
            Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
            return $true
        }
    } catch {
        Write-Log "Failed to update script from GitHub: $($_.Exception.Message)" "ERROR"
        return $false
    }
    
    return $false
}

function Initialize-VSCodeEnvironment {
    Write-Log "=== VS Code Environment Initialization Started ===" "SUCCESS"
    Write-Log "Script Version: $ScriptVersion"
    Write-Log "Last Updated: $LastUpdated"
    Write-Log "Operating System: $([System.Environment]::OSVersion.VersionString)"
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Log "Current User: $env:USERNAME"
    Write-Log "Log File: $LogPath"
    
    # Define paths using cross-platform approach
    if (Test-IsWindows) {
        $basePath = $env:USERPROFILE
        $userDataPath = Join-Path $env:APPDATA "Code\User"
        Write-Log "Windows environment detected"
    } else {
        $basePath = $env:HOME
        $userDataPath = Join-Path $basePath ".config/Code/User"
        Write-Log "Non-Windows environment detected"
    }
    
    $extPath = Join-Path $basePath ".vscode" | Join-Path -ChildPath "extensions"
    
    Write-Log "Base path: $basePath"
    Write-Log "Extensions path: $extPath"
    Write-Log "User data path: $userDataPath"
    
    # Create directories
    $directories = @(
        @{ Path = $extPath; Name = "Extensions" },
        @{ Path = $userDataPath; Name = "User Data" }
    )
    
    foreach ($dir in $directories) {
        try {
            if (!(Test-Path $dir.Path)) {
                New-Item -ItemType Directory -Force -Path $dir.Path | Out-Null
                Write-Log "Created $($dir.Name) directory: $($dir.Path)" "SUCCESS"
            } else {
                Write-Log "$($dir.Name) directory already exists: $($dir.Path)"
            }
        } catch {
            Write-Log "Error creating $($dir.Name) directory: $_" "ERROR"
            throw
        }
    }
    
    # Set permissions
    Set-DirectoryPermissions -ExtensionsPath $extPath -UserDataPath $userDataPath
    
    # Create VS Code configuration
    New-VSCodeConfiguration -UserDataPath $userDataPath
    
    # Verify setup
    Test-VSCodeSetup -ExtensionsPath $extPath -UserDataPath $userDataPath
    
    Write-Log "=== VS Code Environment Initialization Completed ===" "SUCCESS"
}

function Set-DirectoryPermissions {
    param(
        [string]$ExtensionsPath,
        [string]$UserDataPath
    )
    
    if (Test-IsWindows) {
        Write-Log "Setting Windows permissions..."
        
        $paths = @($ExtensionsPath, $UserDataPath)
        foreach ($path in $paths) {
            try {
                $icaclsResult = icacls $path /grant "$env:USERNAME:F" /T /Q 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Permissions set successfully for: $path" "SUCCESS"
                } else {
                    Write-Log "Warning: Could not set permissions for $path - $icaclsResult" "WARNING"
                }
            } catch {
                Write-Log "Warning: Error setting permissions for $path - $_" "WARNING"
            }
        }
    } else {
        Write-Log "Setting Unix-style permissions..."
        try {
            chmod 755 $ExtensionsPath 2>/dev/null
            chmod 755 $UserDataPath 2>/dev/null
            Write-Log "Basic permissions set using chmod" "SUCCESS"
        } catch {
            Write-Log "Warning: Could not set permissions using chmod: $_" "WARNING"
        }
    }
}

function New-VSCodeConfiguration {
    param(
        [string]$UserDataPath
    )
    
    $settingsPath = Join-Path $UserDataPath "settings.json"
    
    if (!(Test-Path $settingsPath)) {
        try {
            # Corporate-friendly VS Code settings
            $defaultSettings = @{
                # Telemetry and privacy
                "telemetry.telemetryLevel" = "off"
                "telemetry.enableCrashReporter" = $false
                "telemetry.enableTelemetry" = $false
                
                # Updates and extensions
                "update.mode" = "manual"
                "update.enableWindowsBackgroundUpdates" = $false
                "extensions.autoUpdate" = $false
                "extensions.autoCheckUpdates" = $false
                
                # UI and behavior
                "workbench.startupEditor" = "none"
                "window.newWindowDimensions" = "inherit"
                "window.restoreWindows" = "preserve"
                "workbench.enableExperiments" = $false
                
                # Editor settings
                "editor.minimap.enabled" = $true
                "editor.wordWrap" = "on"
                "editor.formatOnSave" = $true
                "files.autoSave" = "onWindowChange"
                
                # Security
                "security.workspace.trust.enabled" = $true
                "security.workspace.trust.startupPrompt" = "once"
                "security.workspace.trust.banner" = "always"
                
                # Performance
                "search.exclude" = @{
                    "**/node_modules" = $true
                    "**/bower_components" = $true
                    "**/.git" = $true
                }
            } | ConvertTo-Json -Depth 4
            
            Set-Content -Path $settingsPath -Value $defaultSettings -Encoding UTF8
            Write-Log "Created corporate-friendly settings.json configuration" "SUCCESS"
            
            # Create keybindings.json for corporate shortcuts
            $keybindingsPath = Join-Path $UserDataPath "keybindings.json"
            $keybindings = @(
                @{
                    "key" = "ctrl+shift+p"
                    "command" = "workbench.action.showCommands"
                    "when" = "!terminalFocus"
                }
            ) | ConvertTo-Json -Depth 2
            
            Set-Content -Path $keybindingsPath -Value $keybindings -Encoding UTF8
            Write-Log "Created default keybindings.json" "SUCCESS"
            
        } catch {
            Write-Log "Warning: Could not create VS Code configuration files: $_" "WARNING"
        }
    } else {
        Write-Log "settings.json already exists - preserving existing configuration"
    }
}

function Test-VSCodeSetup {
    param(
        [string]$ExtensionsPath,
        [string]$UserDataPath
    )
    
    Write-Log "Verifying VS Code setup..."
    
    $verification = @()
    $settingsPath = Join-Path $UserDataPath "settings.json"
    
    # Check directories
    if (Test-Path $ExtensionsPath) { 
        $verification += "Extensions directory ✓" 
    } else { 
        $verification += "Extensions directory ✗"
        Write-Log "Extensions directory verification failed" "ERROR"
    }
    
    if (Test-Path $UserDataPath) { 
        $verification += "User data directory ✓" 
    } else { 
        $verification += "User data directory ✗"
        Write-Log "User data directory verification failed" "ERROR"
    }
    
    if (Test-Path $settingsPath) { 
        $verification += "Settings file ✓"
        # Validate JSON
        try {
            Get-Content $settingsPath | ConvertFrom-Json | Out-Null
            Write-Log "Settings file JSON validation passed ✓" "SUCCESS"
        } catch {
            Write-Log "Settings file JSON validation failed: $_" "WARNING"
        }
    } else { 
        $verification += "Settings file ✗"
        Write-Log "Settings file verification failed" "ERROR"
    }
    
    Write-Log "Verification results: $($verification -join ', ')"
    
    # Disk space check
    try {
        $drive = Split-Path $ExtensionsPath -Qualifier
        if ($drive) {
            $freeSpace = (Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $drive }).FreeSpace
            $freeSpaceGB = [math]::Round($freeSpace / 1GB, 2)
            Write-Log "Available disk space on $drive`: $freeSpaceGB GB"
            
            if ($freeSpaceGB -lt 1) {
                Write-Log "Warning: Low disk space detected. VS Code may not function properly." "WARNING"
            }
        }
    } catch {
        Write-Log "Could not check disk space: $_" "WARNING"
    }
}

# Main execution
try {
    # Handle GitHub update if requested
    if ($UpdateFromGitHub) {
        Write-Log "GitHub update requested..."
        if (Update-ScriptFromGitHub) {
            Write-Log "Script updated from GitHub. Exiting to allow restart." "SUCCESS"
            exit 0
        } else {
            Write-Log "GitHub update failed, continuing with current version..." "WARNING"
        }
    }
    
    # Initialize VS Code environment
    Initialize-VSCodeEnvironment
    
    Write-Log "VS Code folder initialization completed successfully" "SUCCESS"
    Write-Log "Log file saved to: $LogPath"
    
    # Output summary for GPO logging
    Write-Output "SUCCESS: VS Code initialization completed"
    Write-Output "LOG: $LogPath"
    Write-Output "VERSION: $ScriptVersion"
    Write-Output "TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    
    exit 0
    
} catch {
    Write-Log "FATAL ERROR during VS Code folder initialization: $_" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Error details: $($Error[0] | Out-String)" "ERROR"
    
    # Output error for GPO logging
    Write-Output "ERROR: VS Code initialization failed"
    Write-Output "DETAILS: $_"
    Write-Output "LOG: $LogPath"
    
    exit 1
}
