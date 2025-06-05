#!/bin/bash

# Script deploy đặc biệt để fix vấn đề admin cũ trên VPS
echo "🔧 FORCE DEPLOY - Fix admin account issue"
echo "========================================"

# Bước 1: Dừng tất cả containers
echo "🛑 Stopping all containers..."
docker-compose down

# Bước 2: Xóa volume database cũ (nếu muốn reset hoàn toàn)
read -p "⚠️  Bạn có muốn XÓA HOÀN TOÀN database cũ? (y/N): " reset_db
if [[ $reset_db =~ ^[Yy]$ ]]; then
    echo "🗑️ Removing old database volume..."
    docker volume rm $(docker-compose config --services | grep mysql)_data 2>/dev/null || true
    echo "✅ Database volume removed"
fi

# Bước 3: Build lại image không cache
echo "🏗️ Building new image (no cache)..."
docker-compose build --no-cache recruitment-app

# Bước 4: Start MySQL trước
echo "🗄️ Starting MySQL first..."
docker-compose up -d mysql

# Đợi MySQL sẵn sàng
echo "⏳ Waiting for MySQL to be ready..."
sleep 15

# Bước 5: Start ứng dụng chính
echo "🚀 Starting main application..."
docker-compose up -d recruitment-app

# Đợi app khởi động
echo "⏳ Waiting for application to start..."
sleep 20

# Bước 6: Start Nginx
echo "🌐 Starting Nginx..."
docker-compose up -d nginx

# Bước 7: Kiểm tra logs của app để xem DataLoader có chạy không
echo "📋 Checking application logs for DataLoader..."
docker-compose logs recruitment-app | grep -E "(Removed all existing admin|New admin user created|admin)"

# Bước 8: Kiểm tra status
echo "📊 Final status check..."
docker-compose ps

echo ""
echo "✅ FORCE DEPLOY COMPLETED!"
echo "🔐 Admin login: admintuyendung / Wellcenter"
echo "🌐 URL: http://localhost/login"
echo "📊 Health: http://localhost/actuator/health"
echo ""
echo "🔍 Để kiểm tra database, chạy: ./check-database.sh"
