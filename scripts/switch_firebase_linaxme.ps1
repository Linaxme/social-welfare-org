# Switch Firebase CLI to linaxme@gmail.com
# Run interactively:
#   powershell -ExecutionPolicy Bypass -File .\scripts\switch_firebase_linaxme.ps1

Write-Host "Logging out current Firebase account..." -ForegroundColor Yellow
firebase logout

Write-Host ""
Write-Host "A browser will open. Login with: linaxme@gmail.com" -ForegroundColor Cyan
firebase login

Write-Host ""
Write-Host "Your projects:" -ForegroundColor Yellow
firebase projects:list

Write-Host ""
Write-Host "Done. Tell the agent which project ID to use." -ForegroundColor Green
