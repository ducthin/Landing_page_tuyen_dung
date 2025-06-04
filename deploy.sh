#!/bin/bash

# Script deploy nhanh
echo "🚀 Bắt đầu deploy ứng dụng..."

# Kiểm tra file .env
if [ ! -f ".env" ]; then
    echo "❌ Chưa có file .env. Vui lòng copy từ .env.example và cấu hình."
    echo "cp .env.example .env"
    echo "Sau đó chỉnh sửa các thông tin trong .env"
    exit 1
fi

# Stop các container cũ
echo "🛑 Dừng containers cũ..."
docker-compose down

# Build lại image
echo "🏗️ Build application..."
docker-compose build --no-cache

# Start services
echo "▶️ Khởi động services..."
docker-compose up -d

# Kiểm tra status
echo "📊 Kiểm tra trạng thái..."
sleep 10
docker-compose ps

echo "✅ Deploy hoàn thành!"
echo "🌐 Ứng dụng đang chạy tại: http://localhost"
echo "📊 Health check: http://localhost/actuator/health"
