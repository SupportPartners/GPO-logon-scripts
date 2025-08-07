# VS Code GPO Logon Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Batch](https://img.shields.io/badge/Batch-Windows-lightgrey.svg)](https://en.wikipedia.org/wiki/Batch_file)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/SupportPartners/GPO-logon-scripts)
[![GPO](https://img.shields.io/badge/GPO-Compatible-green.svg)](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/policy/group-policy-objects)
[![Azure AD DS](https://img.shields.io/badge/Azure%20AD%20DS-Compatible-blue.svg)](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/)

Enterprise-ready PowerShell scripts for configuring Visual Studio Code through Group Policy Object (GPO) deployment in Azure Active Directory Domain Services (AADDS) environments.

## ✨ Simplified Deployment

This repository has been streamlined to contain only the essential files needed for GitHub-based GPO deployment. All alternative deployment methods and legacy scripts have been removed for simplicity.

## 🚀 Features

- **Cross-platform compatibility** (Windows, macOS, Linux)
- **GitHub-based deployment** (no authentication required)
- **Comprehensive logging** and error handling
- **Self-updating capabilities**
- **Corporate-friendly VS Code settings**
- **Automated permissions configuration**

## 📋 Files Overview

| File | Version | Purpose |
|------|---------|---------|
| `InitialiseVSCodeFolders_Enhanced_v3.0.ps1` | 3.0 | 🏆 **Main script** - Full-featured with GitHub integration |
| `RunVSCodeSetup_GitHub.bat` | Latest | GitHub-based deployment launcher |
| `Test-VSCodeGPOScript.ps1` | Latest | Comprehensive testing suite |

## 🎯 Quick Start

### GitHub Deployment (Recommended)

1. **Make repository public** (if not already)
2. **Deploy via GPO:**
   ```batch
   RunVSCodeSetup_GitHub.bat
   ```
3. **Test locally first:**
   ```powershell
   .\Test-VSCodeGPOScript.ps1
   ```

## 📖 Script Capabilities

### InitialiseVSCodeFolders_Enhanced_v3.0.ps1

**Core Features:**
- ✅ Creates VS Code directories with proper permissions
- ✅ Installs corporate-friendly settings
- ✅ Cross-platform path handling
- ✅ Comprehensive error handling and logging
- ✅ Self-updating from GitHub
- ✅ Detailed verification and health checks

**Corporate Settings Applied:**
```json
{
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual",
  "extensions.autoUpdate": false,
  "workbench.startupEditor": "none",
  "security.workspace.trust.enabled": true
}
```

**Usage:**
```powershell
# Basic usage
.\InitialiseVSCodeFolders_Enhanced_v3.0.ps1

# With custom log path
.\InitialiseVSCodeFolders_Enhanced_v3.0.ps1 -LogPath "C:\Logs\VSCode.log"

# With GitHub auto-update
.\InitialiseVSCodeFolders_Enhanced_v3.0.ps1 -UpdateFromGitHub
```

## 🔧 GPO Configuration

### Computer Configuration Setup

1. **Open Group Policy Management Console**
2. **Navigate to:** Computer Configuration → Policies → Windows Settings → Scripts → Startup
3. **Add script:** `RunVSCodeSetup_GitHub.bat`
4. **Apply to:** Target OU with computers needing VS Code setup

### User Configuration Setup (Alternative)

1. **Navigate to:** User Configuration → Policies → Windows Settings → Scripts → Logon
2. **Add script:** `RunVSCodeSetup_GitHub.bat`
3. **Apply to:** Target OU with users needing VS Code setup

## 📊 Monitoring and Logging

### Log Locations
- **Windows:** `%TEMP%\VSCodeSetup.log`
- **macOS/Linux:** `$TMPDIR/VSCodeSetup.log`

### Log Levels
- `INFO` - General information
- `SUCCESS` - Successful operations
- `WARNING` - Non-critical issues
- `ERROR` - Critical errors

### Sample Log Output
```
[2025-08-07 13:30:15] [INFO] Starting VS Code folder initialization...
[2025-08-07 13:30:15] [INFO] Script Version: 3.0
[2025-08-07 13:30:15] [SUCCESS] Windows environment detected
[2025-08-07 13:30:16] [SUCCESS] Created extensions directory: C:\Users\user\.vscode\extensions
[2025-08-07 13:30:16] [SUCCESS] Permissions set successfully
[2025-08-07 13:30:17] [SUCCESS] VS Code folder initialization completed successfully
```

## 🧪 Testing

Run the comprehensive test suite before deployment:

```powershell
.\Test-VSCodeGPOScript.ps1
```

**Test Coverage:**
- ✅ GitHub connectivity
- ✅ Script download capability
- ✅ PowerShell syntax validation
- ✅ Required functions check
- ✅ Cross-platform compatibility
- ✅ Environment variables
- ✅ Disk space requirements

## 🌐 Deployment URLs

### GitHub Raw URLs (Public Repository)
```
https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main/InitialiseVSCodeFolders_Enhanced_v3.0.ps1
https://raw.githubusercontent.com/SupportPartners/GPO-logon-scripts/main/RunVSCodeSetup_GitHub.bat
```

## 🔒 Security Considerations

- **Execution Policy:** Scripts use `-ExecutionPolicy Bypass` for GPO deployment
- **Permissions:** Minimal required permissions for VS Code functionality
- **Telemetry:** Disabled by default for corporate privacy
- **Updates:** Manual update mode to prevent unwanted changes
- **Trust:** Workspace trust enabled for security

## 📈 Version History

| Version | Date | Changes |
|---------|------|---------|
| 3.0 | 2025-08-07 | GitHub integration, self-updating, enhanced logging, simplified deployment |
| 2.1 | 2025-08-07 | Cross-platform compatibility, improved error handling |
| 2.0 | 2025-08-07 | Enhanced logging, corporate settings |
| 1.0 | Initial | Basic folder creation and permissions |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test thoroughly with `Test-VSCodeGPOScript.ps1`
4. Submit a pull request

## 📞 Support

For issues or questions:
- Check the log files first: `%TEMP%\VSCodeSetup.log`
- Review the test results: `.\Test-VSCodeGPOScript.ps1`
- Open an issue in this repository

---

**Repository:** https://github.com/SupportPartners/GPO-logon-scripts  
**License:** MIT  
**Maintainer:** SupportPartners