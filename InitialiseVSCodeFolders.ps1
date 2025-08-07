$basePath = $env:USERPROFILE
$extPath = Join-Path $basePath ".vscode\extensions"
$userDataPath = Join-Path $env:APPDATA "Code\User"
# Create folders if they don't exist
New-Item -ItemType Directory -Force -Path $extPath | Out-Null
New-Item -ItemType Directory -Force -Path $userDataPath | Out-Null
# Grant full control to the current user
icacls $extPath /grant "$env:USERNAME:F" /T | Out-Null
icacls $userDataPath /grant "$env:USERNAME:F" /T | Out-Null
