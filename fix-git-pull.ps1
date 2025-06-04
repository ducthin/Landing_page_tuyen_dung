# PowerShell script để xử lý Git conflicts khi pull code từ Windows lên VPS

param(
    [string]$VpsHost = "root@tuyendungwellcenter.com", 
    [string]$VpsPath = "/opt/wellcenter",
    [string]$Password = "g7bKRNJbEqo8g0Lw63fV"
)

Write-Host "🔄 RESOLVING GIT CONFLICTS ON VPS" -ForegroundColor Green
Write-Host "================================="

Write-Host "1️⃣ Checking current Git status on VPS..." -ForegroundColor Yellow
ssh $VpsHost "cd $VpsPath && git status"

Write-Host ""
Write-Host "2️⃣ Backing up local changes..." -ForegroundColor Yellow
ssh $VpsHost "cd $VpsPath && cp src/main/resources/application-prod.properties src/main/resources/application-prod.properties.backup"

Write-Host ""
Write-Host "3️⃣ Showing differences in application-prod.properties..." -ForegroundColor Yellow
ssh $VpsHost "cd $VpsPath && git diff src/main/resources/application-prod.properties"

Write-Host ""
Write-Host "4️⃣ Options to resolve conflict:" -ForegroundColor Cyan
Write-Host "   a) Stash local changes and pull (recommended)" -ForegroundColor Green
Write-Host "   b) Reset local changes and pull (lose local changes)" -ForegroundColor Red
Write-Host "   c) Commit local changes first" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Select option (a/b/c)"

switch ($choice) {    'a' {
        Write-Host "🔄 Stashing local changes and pulling..." -ForegroundColor Yellow
        ssh $VpsHost "cd $VpsPath; git stash; git pull origin main"
        Write-Host ""
        Write-Host "✅ Pull completed. Local changes are stashed." -ForegroundColor Green
        Write-Host "📋 To see stashed changes: git stash show -p" -ForegroundColor Cyan
        Write-Host "📋 To apply stashed changes: git stash pop" -ForegroundColor Cyan
        Write-Host "📋 Backup file available at: application-prod.properties.backup" -ForegroundColor Cyan
    }
    'b' {
        Write-Host "⚠️ Resetting local changes and pulling..." -ForegroundColor Red
        ssh $VpsHost "cd $VpsPath; git checkout -- src/main/resources/application-prod.properties; git pull origin main"
        Write-Host "✅ Pull completed. Local changes discarded." -ForegroundColor Green
        Write-Host "📋 Backup file available at: application-prod.properties.backup" -ForegroundColor Cyan
    }
    'c' {
        Write-Host "💾 Committing local changes first..." -ForegroundColor Yellow
        ssh $VpsHost "cd $VpsPath; git add src/main/resources/application-prod.properties; git commit -m 'Local VPS changes to application-prod.properties'; git pull origin main"
        Write-Host "✅ Local changes committed and pulled." -ForegroundColor Green
    }
    default {
        Write-Host "❌ Invalid option" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "5️⃣ Final Git status:" -ForegroundColor Yellow
ssh $VpsHost "cd $VpsPath && git status"

Write-Host ""
Write-Host "6️⃣ Verifying new test scripts are available:" -ForegroundColor Yellow
ssh $VpsHost "cd $VpsPath && ls -la *.sh *.ps1 *.md | grep -E '(test-direct|cleanup|monitor|upload|DIRECT)'"

Write-Host ""
Write-Host "🎉 Git pull resolved successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Set permissions: chmod +x *.sh" -ForegroundColor White
Write-Host "   2. Run direct test: ./test-direct-run.sh" -ForegroundColor White
Write-Host "   3. Check guide: cat DIRECT-RUN-GUIDE.md" -ForegroundColor White
