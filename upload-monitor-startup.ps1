# PowerShell script to upload monitor-startup.sh and run it on VPS
$vpsHost = "14.225.207.250"
$vpsUser = "root"
$remotePath = "/opt/wellcenter"

Write-Host "📤 Uploading monitor-startup.sh to VPS..." -ForegroundColor Cyan
scp "d:\Code\Job\monitor-startup.sh" "${vpsUser}@${vpsHost}:${remotePath}/"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Upload successful!" -ForegroundColor Green
    Write-Host "🔧 Making script executable and running..." -ForegroundColor Yellow
    
    # Connect to VPS and make script executable, then run it
    ssh "${vpsUser}@${vpsHost}" "cd ${remotePath} && chmod +x monitor-startup.sh && ./monitor-startup.sh"
} else {
    Write-Host "❌ Upload failed!" -ForegroundColor Red
}
