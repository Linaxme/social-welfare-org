# Deploy Flutter web to Firebase Hosting (socialwelfare-org)
# Run in an interactive PowerShell terminal:
#   powershell -ExecutionPolicy Bypass -File .\scripts\deploy_web.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\deploy_web.ps1 -Rebuild

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "Login account should be: linaxme@gmail.com" -ForegroundColor Cyan
firebase login:list

Write-Host ""
Write-Host "Using project socialwelfare-org..." -ForegroundColor Yellow
firebase use socialwelfare-org

if ((-not (Test-Path "build\web\index.html")) -or ($args -contains "-Rebuild")) {
  Write-Host "Building Flutter web..." -ForegroundColor Yellow
  flutter build web --release
} else {
  Write-Host "Found build\web (skip rebuild). Pass -Rebuild to force." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Deploying hosting..." -ForegroundColor Yellow
firebase deploy --only hosting --project socialwelfare-org

Write-Host ""
Write-Host "Live URL: https://socialwelfare-org.web.app" -ForegroundColor Green
Write-Host "Also: https://socialwelfare-org.firebaseapp.com" -ForegroundColor Green
