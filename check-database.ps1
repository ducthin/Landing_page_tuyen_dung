# Script kiểm tra và làm sạch database trên VPS
Write-Host "🔍 Kiểm tra database trên VPS..." -ForegroundColor Yellow

# Kiểm tra xem có container MySQL đang chạy không
$mysqlContainer = docker ps --filter "name=mysql" --format "{{.Names}}"

if ($mysqlContainer) {
    Write-Host "📊 MySQL container đang chạy: $mysqlContainer" -ForegroundColor Green
    
    # Kết nối vào MySQL và kiểm tra table users
    Write-Host "🔍 Kiểm tra users trong database..." -ForegroundColor Yellow
    docker exec -it $mysqlContainer mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "SELECT username, role FROM users WHERE role='ADMIN';"
    
    Write-Host ""
    Write-Host "⚠️  Nếu thấy tài khoản admin cũ ở trên, chúng ta sẽ xóa toàn bộ để đảm bảo bảo mật" -ForegroundColor Yellow
    $confirm = Read-Host "🗑️  Bạn có muốn xóa TẤT CẢ users admin cũ? (y/N)"
    
    if ($confirm -match "^[Yy]$") {
        Write-Host "🗑️ Xóa tất cả admin users cũ..." -ForegroundColor Red
        docker exec -it $mysqlContainer mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "DELETE FROM users WHERE role='ADMIN';"
        Write-Host "✅ Đã xóa tất cả admin users cũ" -ForegroundColor Green
        
        Write-Host "📊 Kiểm tra lại database:" -ForegroundColor Yellow
        docker exec -it $mysqlContainer mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "SELECT username, role FROM users WHERE role='ADMIN';"
    }
    
} else {
    Write-Host "❌ Không tìm thấy MySQL container đang chạy" -ForegroundColor Red
    Write-Host "💡 Hãy chạy: docker-compose up -d mysql" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Bây giờ hãy build và deploy lại ứng dụng để DataLoader tạo admin mới:" -ForegroundColor Cyan
Write-Host "   .\deploy.ps1" -ForegroundColor White
