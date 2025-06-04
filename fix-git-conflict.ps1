# Quick fix for Git pull conflict on VPS

Write-Host "🔧 FIXING GIT PULL CONFLICT" -ForegroundColor Green
Write-Host "==========================="

$VpsHost = "root@tuyendungwellcenter.com"
$VpsPath = "/opt/wellcenter"

Write-Host "📋 Commands being executed on VPS:" -ForegroundColor Yellow

# Backup current file
Write-Host "1. Backing up application-prod.properties..." -ForegroundColor Cyan
ssh $VpsHost "cd $VpsPath && cp src/main/resources/application-prod.properties src/main/resources/application-prod.properties.backup"

# Stash changes
Write-Host "2. Stashing local changes..." -ForegroundColor Cyan  
ssh $VpsHost "cd $VpsPath && git stash push -m 'Backup local changes before pull'"

# Pull latest
Write-Host "3. Pulling latest changes..." -ForegroundColor Cyan
ssh $VpsHost "cd $VpsPath && git pull origin main"

# Apply stash
Write-Host "4. Applying stashed changes..." -ForegroundColor Cyan
ssh $VpsHost "cd $VpsPath && git stash pop"

# Set permissions
Write-Host "5. Setting permissions for scripts..." -ForegroundColor Cyan
ssh $VpsHost "cd $VpsPath && chmod +x test-direct-run.sh test-email-direct.sh cleanup-direct-test.sh monitor-direct-run.sh"

# Show status
Write-Host "6. Final status..." -ForegroundColor Cyan
ssh $VpsHost "cd $VpsPath && git status"

Write-Host ""
Write-Host "✅ Git conflict resolved!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Now you can run:" -ForegroundColor Yellow
Write-Host "   ssh $VpsHost" -ForegroundColor Cyan
Write-Host "   cd $VpsPath" -ForegroundColor Cyan
Write-Host "   ./test-direct-run.sh" -ForegroundColor Cyan
