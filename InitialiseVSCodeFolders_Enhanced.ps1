# Enhanced VS Code Folder Initialization Script for AADDS GPO
# Version: 2.0
# Description: Creates and configures VS Code folders with proper permissions

param(
    [string]$LogPath = "$env:TEMP\VSCodeSetup.log"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

try {
    Write-Log "Starting VS Code folder initialization..."
    
    # Define paths
    $basePath = $env:USERPROFILE
    $extPath = Join-Path $basePath ".vscode\extensions"
    $userDataPath = Join-Path $env:APPDATA "Code\User"
    
    Write-Log "Base path: $basePath"
    Write-Log "Extensions path: $extPath"
    Write-Log "User data path: $userDataPath"
    
    # Create folders if they don't exist
    Write-Log "Creating VS Code directories..."
    
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
    
    # Grant full control to the current user
    Write-Log "Setting permissions..."
    
    try {
        icacls $extPath /grant "$env:USERNAME:F" /T /Q | Out-Null
        Write-Log "Permissions set for extensions directory"
    } catch {
        Write-Log "Warning: Could not set permissions for extensions directory: $_"
    }
    
    try {
        icacls $userDataPath /grant "$env:USERNAME:F" /T /Q | Out-Null
        Write-Log "Permissions set for user data directory"
    } catch {
        Write-Log "Warning: Could not set permissions for user data directory: $_"
    }
    
    # Create settings directory if it doesn't exist
    $settingsPath = Join-Path $userDataPath "settings.json"
    if (!(Test-Path $settingsPath)) {
        $defaultSettings = @{
            "telemetry.telemetryLevel" = "off"
            "update.mode" = "manual"
            "extensions.autoUpdate" = $false
        } | ConvertTo-Json -Depth 3
        
        Set-Content -Path $settingsPath -Value $defaultSettings
        Write-Log "Created default settings.json"
    }
    
    Write-Log "VS Code folder initialization completed successfully"
    exit 0
    
} catch {
    Write-Log "Error during VS Code folder initialization: $_"
    exit 1
}
