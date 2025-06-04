# PowerShell script để setup SendGrid trên VPS

param(
    [Parameter(Mandatory=$true)]
    [string]$VpsIp = "tuyendungwellcenter.com",
    
    [string]$VpsUser = "root",
    [string]$VpsPath = "/opt/wellcenter"
)

Write-Host "📧 SENDGRID SETUP FOR VPS" -ForegroundColor Green
Write-Host "========================="

# Upload script
Write-Host "⬆️ Uploading SendGrid setup script..." -ForegroundColor Yellow
try {
    scp setup-sendgrid.sh "${VpsUser}@${VpsIp}:${VpsPath}/"
    Write-Host "✅ Script uploaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to upload script: $_" -ForegroundColor Red
    exit 1
}

# Set permissions
Write-Host "🔧 Setting permissions..." -ForegroundColor Yellow
try {
    ssh "${VpsUser}@${VpsIp}" "chmod +x ${VpsPath}/setup-sendgrid.sh"
    Write-Host "✅ Permissions set successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to set permissions: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Get SendGrid API Key:"
Write-Host "   → Go to https://sendgrid.com/" -ForegroundColor Yellow
Write-Host "   → Sign up for free account" -ForegroundColor Yellow
Write-Host "   → Settings → API Keys → Create API Key" -ForegroundColor Yellow
Write-Host "   → Copy the API Key (shown only once!)" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. SSH to VPS and run setup:"
Write-Host "   ssh $VpsUser@$VpsIp" -ForegroundColor Cyan
Write-Host "   cd $VpsPath" -ForegroundColor Cyan
Write-Host "   ./setup-sendgrid.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. The script will ask for:"
Write-Host "   - SendGrid API Key" -ForegroundColor Yellow
Write-Host "   - Verified sender email" -ForegroundColor Yellow
Write-Host "   - Admin notification email" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 SENDGRID SETUP CHECKLIST:" -ForegroundColor Magenta
Write-Host "☐ Create SendGrid account"
Write-Host "☐ Verify your email address"
Write-Host "☐ Create API Key with Mail Send permission"
Write-Host "☐ Run setup-sendgrid.sh on VPS"
Write-Host "☐ Test email sending"
Write-Host "☐ Check SendGrid dashboard for statistics"
