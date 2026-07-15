# Run this in your terminal (interactive browser login required)
# cd d:\flutter_projects\somiti_app
# powershell -ExecutionPolicy Bypass -File .\scripts\switch_firebase_account.ps1

Write-Host "Logging out current Firebase account..." -ForegroundColor Yellow
firebase logout

Write-Host ""
Write-Host "A browser will open. Login with: hilfulfuzulkpp@gmail.com" -ForegroundColor Cyan
firebase login

Write-Host ""
Write-Host "Setting project hilfulfuzul-a4092..." -ForegroundColor Yellow
firebase use hilfulfuzul-a4092

Write-Host ""
firebase projects:list

Write-Host ""
Write-Host "Configuring FlutterFire (android + web)..." -ForegroundColor Yellow
dart pub global run flutterfire_cli:flutterfire configure --project=hilfulfuzul-a4092 --platforms=android,web --yes --overwrite-firebase-options

Write-Host ""
Write-Host "Done. Tell the agent: Firebase configured" -ForegroundColor Green
