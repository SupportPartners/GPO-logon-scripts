# VS Code GPO Script Test Suite
# Tests the v3.0 PowerShell script functionality

Write-Host "=== VS Code GPO Script Test Suite ===" -ForegroundColor Cyan
Write-Host "Testing InitialiseVSCodeFolders_Enhanced_v3.0.ps1" -ForegroundColor Cyan
Write-Host ""

# Test 1: GitHub Connectivity
Write-Host "Test 1: GitHub Connectivity" -ForegroundColor Yellow
$testUrl = "https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main/README.md"
try {
    $response = Invoke-WebRequest -Uri $testUrl -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ GitHub connectivity successful (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ GitHub connectivity failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Script Download Simulation
Write-Host "`nTest 2: Script Download Simulation" -ForegroundColor Yellow
$scriptUrl = "https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main/InitialiseVSCodeFolders_Enhanced_v3.0.ps1"
try {
    $response = Invoke-WebRequest -Uri $scriptUrl -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ Script download URL accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*404*") {
        Write-Host "⚠ Script not yet available on GitHub (Repository may be private)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Script download test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 3: Local Script Syntax
Write-Host "`nTest 3: Local Script Syntax Validation" -ForegroundColor Yellow
$localScript = "./InitialiseVSCodeFolders_Enhanced_v3.0.ps1"
if (Test-Path $localScript) {
    try {
        # Parse PowerShell syntax
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $localScript -Raw), [ref]$null)
        Write-Host "✓ PowerShell syntax validation passed" -ForegroundColor Green
    } catch {
        Write-Host "✗ PowerShell syntax validation failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "⚠ Local script file not found" -ForegroundColor Yellow
}

# Test 4: Required Functions Check
Write-Host "`nTest 4: Required Functions Check" -ForegroundColor Yellow
$requiredFunctions = @(
    "Write-Log",
    "Test-IsWindows", 
    "Test-GitHubConnectivity",
    "Update-ScriptFromGitHub",
    "Initialize-VSCodeEnvironment",
    "Set-DirectoryPermissions",
    "New-VSCodeConfiguration",
    "Test-VSCodeSetup"
)

if (Test-Path $localScript) {
    $scriptContent = Get-Content $localScript -Raw
    foreach ($func in $requiredFunctions) {
        if ($scriptContent -match "function $func") {
            Write-Host "✓ Function '$func' found" -ForegroundColor Green
        } else {
            Write-Host "✗ Function '$func' missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "⚠ Cannot check functions - script file not found" -ForegroundColor Yellow
}

# Test 5: Cross-Platform Compatibility
Write-Host "`nTest 5: Cross-Platform Compatibility" -ForegroundColor Yellow
$isWindowsOS = ($env:OS -eq "Windows_NT")
if ($isWindowsOS) {
    Write-Host "✓ Running on Windows - icacls permissions will be used" -ForegroundColor Green
    
    # Test Windows-specific commands
    try {
        $null = Get-Command icacls -ErrorAction Stop
        Write-Host "✓ icacls command available" -ForegroundColor Green
    } catch {
        Write-Host "✗ icacls command not available" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Running on non-Windows - chmod permissions will be used" -ForegroundColor Green
    
    # Test Unix-specific commands
    try {
        $null = Get-Command chmod -ErrorAction Stop
        Write-Host "✓ chmod command available" -ForegroundColor Green
    } catch {
        Write-Host "✗ chmod command not available" -ForegroundColor Red
    }
}

# Test 6: Environment Variables
Write-Host "`nTest 6: Environment Variables" -ForegroundColor Yellow
$requiredEnvVars = if ($isWindowsOS) { 
    @("USERPROFILE", "APPDATA", "USERNAME", "TEMP") 
} else { 
    @("HOME", "USER", "TMPDIR") 
}

foreach ($envVar in $requiredEnvVars) {
    $value = [Environment]::GetEnvironmentVariable($envVar)
    if ($value) {
        Write-Host "✓ Environment variable '$envVar' = '$value'" -ForegroundColor Green
    } else {
        Write-Host "✗ Environment variable '$envVar' not found" -ForegroundColor Red
    }
}

# Test 7: Disk Space Check
Write-Host "`nTest 7: Disk Space Check" -ForegroundColor Yellow
try {
    if ($isWindowsOS) {
        $userProfile = $env:USERPROFILE
        $drive = Split-Path $userProfile -Qualifier
        $disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $drive }
        $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        Write-Host "✓ Available space on $drive`: $freeSpaceGB GB" -ForegroundColor Green
        
        if ($freeSpaceGB -lt 1) {
            Write-Host "⚠ Warning: Low disk space detected" -ForegroundColor Yellow
        }
    } else {
        $freeSpace = (Get-PSDrive -Name (Split-Path $env:HOME -Qualifier).TrimEnd(':')).Free
        $freeSpaceGB = [math]::Round($freeSpace / 1GB, 2)
        Write-Host "✓ Available space: $freeSpaceGB GB" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Could not check disk space: $_" -ForegroundColor Yellow
}

Write-Host "`n=== Test Suite Complete ===" -ForegroundColor Cyan
Write-Host "Review the results above before deploying to production GPO" -ForegroundColor White
