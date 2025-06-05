#!/usr/bin/env pwsh

# Script kiểm tra Google Maps hoạt động
Write-Host "🚀 Bắt đầu test Google Maps..."

# Kill existing processes
Write-Host "📋 Dừng các process hiện tại..."
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Build và start application
Write-Host "🔨 Build application..."
./mvnw.cmd clean package -DskipTests

Write-Host "🏃 Khởi động ứng dụng..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "./mvnw.cmd spring-boot:run" -WindowStyle Minimized

# Wait for app to start
Write-Host "⏳ Đợi ứng dụng khởi động (20 giây)..."
Start-Sleep -Seconds 20

# Test health endpoint
Write-Host "🏥 Kiểm tra health endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method GET
    Write-Host "✅ Health check OK: $($response.status)"
} catch {
    Write-Host "❌ Health check failed: $_"
}

# Open browser for manual test
Write-Host "🌐 Mở trình duyệt để test Google Maps..."
Start-Process "http://localhost:8080"

Write-Host "📝 Hướng dẫn test:"
Write-Host "   1. Kiểm tra Google Maps có hiển thị không"
Write-Host "   2. Kiểm tra console F12 có lỗi không" 
Write-Host "   3. Test click vào bản đồ"
Write-Host "   4. Test các nút 'Chỉ đường' và 'Mở Google Maps'"
Write-Host ""
Write-Host "✅ Test hoàn tất! Nhấn Enter để thoát..."
Read-Host
