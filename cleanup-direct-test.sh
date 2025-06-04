#!/bin/bash

# Script để dọn dẹp sau khi test direct run

echo "🧹 CLEANUP AFTER DIRECT RUN TEST"
echo "================================"

# Dừng app nếu đang chạy (kill process on port 8080)
echo "1️⃣ Stopping any process on port 8080..."
PID=$(lsof -ti:8080 2>/dev/null || echo "")
if [ ! -z "$PID" ]; then
    echo "   Killing process $PID on port 8080"
    kill -9 $PID
    sleep 2
else
    echo "   No process found on port 8080"
fi

# Xóa file config tạm thời
echo "2️⃣ Removing temporary config file..."
rm -f /tmp/app-direct-test.properties
echo "   ✅ Temporary config removed"

# Khởi động lại containers
echo "3️⃣ Restarting Docker containers..."
docker-compose up -d

# Đợi containers sẵn sàng
echo "4️⃣ Waiting for containers to be ready..."
sleep 10

# Kiểm tra status
echo "5️⃣ Checking container status..."
docker-compose ps

echo ""
echo "✅ Cleanup completed!"
echo "   - Direct run process stopped"
echo "   - Temporary files removed"
echo "   - Docker containers restarted"
echo ""
echo "🌐 Your application should now be available at:"
echo "   http://tuyendungwellcenter.com"
echo "   http://$(curl -s ifconfig.me)"
