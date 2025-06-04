# Script deploy nhanh cho Windows
Write-Output "🚀 Bắt đầu deploy ứng dụng..."

# Kiểm tra file .env
if (!(Test-Path ".env")) {
    Write-Host "❌ Chưa có file .env. Vui lòng copy từ .env.example và cấu hình." -ForegroundColor Red
    Write-Host "Copy-Item .env.example .env" -ForegroundColor Yellow
    Write-Host "Sau đó chỉnh sửa các thông tin trong .env" -ForegroundColor Yellow
    exit 1
}

# Stop các container cũ
Write-Host "🛑 Dừng containers cũ..." -ForegroundColor Yellow
docker-compose down

# Build lại image
Write-Host "🏗️ Build application..." -ForegroundColor Yellow
docker-compose build --no-cache

# Start services
Write-Host "▶️ Khởi động services..." -ForegroundColor Yellow
docker-compose up -d

# Kiểm tra status
Write-Host "📊 Kiểm tra trạng thái..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker-compose ps

Write-Host "✅ Deploy hoàn thành!" -ForegroundColor Green
Write-Host "🌐 Ứng dụng đang chạy tại: http://localhost" -ForegroundColor Cyan
Write-Host "📊 Health check: http://localhost/actuator/health" -ForegroundColor Cyan
Write-Host "🔐 Đăng nhập admin: admintuyendung / Wellcenter" -ForegroundColor Magenta
Write-Host "⚠️  Lưu ý: Tất cả tài khoản admin cũ đã bị xóa để đảm bảo bảo mật" -ForegroundColor Yellow
