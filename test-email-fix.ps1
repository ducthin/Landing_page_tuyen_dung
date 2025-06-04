# TESTING GMAIL SMTP CONFIGURATION

Write-Host "=== TESTING GMAIL SMTP CONFIGURATION ===" -ForegroundColor Green

# Stop containers
Write-Host "1. Stopping containers..." -ForegroundColor Yellow
docker-compose down

# Rebuild app container to pick up new config
Write-Host "2. Rebuilding app container..." -ForegroundColor Yellow
docker-compose build app

# Start containers
Write-Host "3. Starting containers..." -ForegroundColor Yellow
docker-compose up -d

# Wait for containers to be ready
Write-Host "4. Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep 30

# Check container status
Write-Host "5. Container status:" -ForegroundColor Yellow
docker-compose ps

# Check app logs for email configuration
Write-Host "6. Checking app logs for email config..." -ForegroundColor Yellow
docker-compose logs app | Select-String -Pattern "mail" -CaseSensitive:$false

# Test email endpoint
Write-Host "7. Testing email endpoint..." -ForegroundColor Yellow
Start-Sleep 10
Write-Host "Testing /test-email endpoint..." -ForegroundColor Cyan

$response = try {
    Invoke-RestMethod -Uri "http://localhost:8080/test-email" -Method POST -ContentType "application/x-www-form-urlencoded" -Body "email=ducthinh123b@gmail.com"
    Write-Host "Response: $response" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== EMAIL TEST COMPLETED ===" -ForegroundColor Green
Write-Host "Check the app logs with: docker-compose logs app" -ForegroundColor Cyan
Write-Host "Check if email was sent to: ducthinh123b@gmail.com" -ForegroundColor Cyan
