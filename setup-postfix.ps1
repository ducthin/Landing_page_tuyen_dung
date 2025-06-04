# PowerShell script để setup Postfix trên VPS

param(
    [Parameter(Mandatory=$true)]
    [string]$VpsIp = "tuyendungwellcenter.com",
    
    [string]$VpsUser = "root",
    [string]$VpsPath = "/opt/wellcenter"
)

Write-Host "📮 POSTFIX SETUP FOR VPS" -ForegroundColor Green
Write-Host "======================="

# Upload script
Write-Host "⬆️ Uploading Postfix setup script..." -ForegroundColor Yellow
try {
    scp setup-postfix.sh "${VpsUser}@${VpsIp}:${VpsPath}/"
    Write-Host "✅ Script uploaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to upload script: $_" -ForegroundColor Red
    exit 1
}

# Set permissions
Write-Host "🔧 Setting permissions..." -ForegroundColor Yellow
try {
    ssh "${VpsUser}@${VpsIp}" "chmod +x ${VpsPath}/setup-postfix.sh"
    Write-Host "✅ Permissions set successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to set permissions: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. SSH to VPS and run setup:"
Write-Host "   ssh $VpsUser@$VpsIp" -ForegroundColor Cyan
Write-Host "   cd $VpsPath" -ForegroundColor Cyan
Write-Host "   sudo ./setup-postfix.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. The script will automatically:"
Write-Host "   ✓ Install and configure Postfix" -ForegroundColor Green
Write-Host "   ✓ Update application configuration" -ForegroundColor Green
Write-Host "   ✓ Rebuild Docker containers" -ForegroundColor Green
Write-Host "   ✓ Test email sending" -ForegroundColor Green
Write-Host ""
Write-Host "📋 POSTFIX ADVANTAGES:" -ForegroundColor Magenta
Write-Host "✓ No external dependencies" -ForegroundColor Green
Write-Host "✓ No API keys needed" -ForegroundColor Green
Write-Host "✓ Free unlimited emails" -ForegroundColor Green
Write-Host "✓ Fast local delivery" -ForegroundColor Green
Write-Host "✓ Works offline" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  CONSIDERATIONS:" -ForegroundColor Yellow
Write-Host "• Some email providers may mark as spam"
Write-Host "• Requires proper domain/DNS setup for best delivery"
Write-Host "• VPS provider must allow outbound port 25"
Write-Host ""
Write-Host "🔧 AFTER SETUP, TEST WITH:" -ForegroundColor Cyan
Write-Host "curl https://tuyendungwellcenter.com/test-email"
