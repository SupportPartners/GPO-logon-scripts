# Enhanced VS Code Folder Initialization Script for AADDS GPO
# Version: 2.1
# Description: Creates and configures VS Code folders with proper permissions
# Cross-platform compatible

param(
    [string]$LogPath = "$env:TEMP\VSCodeSetup.log"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    try {
        Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Warning: Could not write to log file: $_"
    }
}

function Test-IsWindows {
    return ($IsWindows -or $env:OS -eq "Windows_NT" -or [System.Environment]::OSVersion.Platform -eq "Win32NT")
}

try {
    Write-Log "Starting VS Code folder initialization..."
    Write-Log "Operating System: $([System.Environment]::OSVersion.VersionString)"
    
    # Define paths using cross-platform approach
    if (Test-IsWindows) {
        $basePath = $env:USERPROFILE
        $userDataPath = Join-Path $env:APPDATA "Code\User"
    } else {
        $basePath = $env:HOME
        $userDataPath = Join-Path $basePath ".config/Code/User"
    }
    
    $extPath = Join-Path $basePath ".vscode" | Join-Path -ChildPath "extensions"
    
    Write-Log "Base path: $basePath"
    Write-Log "Extensions path: $extPath"
    Write-Log "User data path: $userDataPath"
    
    # Create folders if they don't exist
    Write-Log "Creating VS Code directories..."
    
    try {
        if (!(Test-Path $extPath)) {
            New-Item -ItemType Directory -Force -Path $extPath | Out-Null
            Write-Log "Created extensions directory: $extPath"
        } else {
            Write-Log "Extensions directory already exists: $extPath"
        }
        
        if (!(Test-Path $userDataPath)) {
            New-Item -ItemType Directory -Force -Path $userDataPath | Out-Null
            Write-Log "Created user data directory: $userDataPath"
        } else {
            Write-Log "User data directory already exists: $userDataPath"
        }
    } catch {
        Write-Log "Error creating directories: $_"
        throw
    }
    
    # Set permissions (Windows only)
    if (Test-IsWindows) {
        Write-Log "Setting Windows permissions..."
        
        try {
            $icaclsResult = icacls $extPath /grant "$env:USERNAME:F" /T /Q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Permissions set for extensions directory"
            } else {
                Write-Log "Warning: Could not set permissions for extensions directory: $icaclsResult"
            }
        } catch {
            Write-Log "Warning: Error setting permissions for extensions directory: $_"
        }
        
        try {
            $icaclsResult = icacls $userDataPath /grant "$env:USERNAME:F" /T /Q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Permissions set for user data directory"
            } else {
                Write-Log "Warning: Could not set permissions for user data directory: $icaclsResult"
            }
        } catch {
            Write-Log "Warning: Error setting permissions for user data directory: $_"
        }
    } else {
        Write-Log "Non-Windows system detected - skipping icacls permission setting"
        try {
            chmod 755 $extPath 2>/dev/null
            chmod 755 $userDataPath 2>/dev/null
            Write-Log "Set basic permissions using chmod"
        } catch {
            Write-Log "Warning: Could not set permissions using chmod: $_"
        }
    }
    
    # Create default settings.json if it doesn't exist
    $settingsPath = Join-Path $userDataPath "settings.json"
    if (!(Test-Path $settingsPath)) {
        try {
            $defaultSettings = @{
                "telemetry.telemetryLevel" = "off"
                "update.mode" = "manual"
                "extensions.autoUpdate" = $false
                "workbench.startupEditor" = "none"
                "window.newWindowDimensions" = "inherit"
            } | ConvertTo-Json -Depth 3
            
            Set-Content -Path $settingsPath -Value $defaultSettings -Encoding UTF8
            Write-Log "Created default settings.json with corporate-friendly defaults"
        } catch {
            Write-Log "Warning: Could not create settings.json: $_"
        }
    } else {
        Write-Log "settings.json already exists"
    }
    
    # Verify directories were created successfully
    $verification = @()
    if (Test-Path $extPath) { $verification += "Extensions directory ✓" } else { $verification += "Extensions directory ✗" }
    if (Test-Path $userDataPath) { $verification += "User data directory ✓" } else { $verification += "User data directory ✗" }
    if (Test-Path $settingsPath) { $verification += "Settings file ✓" } else { $verification += "Settings file ✗" }
    
    Write-Log "Verification results: $($verification -join ', ')"
    Write-Log "VS Code folder initialization completed successfully"
    
    exit 0
    
} catch {
    Write-Log "FATAL ERROR during VS Code folder initialization: $_"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
