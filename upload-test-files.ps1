# PowerShell script để upload test files lên VPS

param(
    [Parameter(Mandatory=$true)]
    [string]$VpsIp,
    
    [Parameter(Mandatory=$true)]
    [string]$VpsUser = "root",
    
    [string]$VpsPath = "/root/recruitment-app"
)

Write-Host "🚀 UPLOADING DIRECT RUN TEST FILES TO VPS" -ForegroundColor Green
Write-Host "=========================================="

# Kiểm tra SCP có sẵn không
if (!(Get-Command scp -ErrorAction SilentlyContinue)) {
    Write-Host "❌ SCP not found! Please install OpenSSH client" -ForegroundColor Red
    Write-Host "   Run: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
    exit 1
}

$filesToUpload = @(
    "test-direct-run.sh",
    "test-email-direct.sh", 
    "cleanup-direct-test.sh",
    "monitor-direct-run.sh",
    "DIRECT-RUN-GUIDE.md"
)

Write-Host "📂 Files to upload:" -ForegroundColor Yellow
foreach ($file in $filesToUpload) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file (not found)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📡 Uploading to VPS: $VpsUser@$VpsIp" -ForegroundColor Cyan
Write-Host "📁 Remote path: $VpsPath" -ForegroundColor Cyan

# Upload từng file
foreach ($file in $filesToUpload) {
    if (Test-Path $file) {
        Write-Host "⬆️ Uploading $file..." -ForegroundColor Yellow
        
        try {
            scp $file "${VpsUser}@${VpsIp}:${VpsPath}/"
            Write-Host "   ✅ $file uploaded successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Failed to upload $file`: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🔧 Setting permissions on VPS..." -ForegroundColor Yellow

$sshCommand = "chmod +x $VpsPath/test-direct-run.sh $VpsPath/test-email-direct.sh $VpsPath/cleanup-direct-test.sh $VpsPath/monitor-direct-run.sh"

try {
    ssh "${VpsUser}@${VpsIp}" $sshCommand
    Write-Host "✅ Permissions set successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to set permissions: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 UPLOAD COMPLETED!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. SSH to your VPS:"
Write-Host "   ssh $VpsUser@$VpsIp" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Navigate to app directory:"
Write-Host "   cd $VpsPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Run the direct test:"
Write-Host "   ./test-direct-run.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. In another terminal, test email:"
Write-Host "   ./test-email-direct.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Cleanup after test:"
Write-Host "   ./cleanup-direct-test.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 For detailed guide, check DIRECT-RUN-GUIDE.md on VPS" -ForegroundColor Magenta
