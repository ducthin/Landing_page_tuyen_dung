# Upload and run quick diagnosis on VPS
Write-Host "🚀 Uploading quick diagnosis script..." -ForegroundColor Green

# Upload the script
scp "d:\Code\Job\quick-diagnose.sh" "root@14.225.207.250:/opt/wellcenter/"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Script uploaded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔍 Running diagnosis on VPS..." -ForegroundColor Yellow
    
    # Make executable and run
    ssh root@14.225.207.250 "cd /opt/wellcenter && chmod +x quick-diagnose.sh && ./quick-diagnose.sh"
} else {
    Write-Host "❌ Failed to upload script" -ForegroundColor Red
}
