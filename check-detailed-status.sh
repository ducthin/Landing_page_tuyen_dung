#!/bin/bash

echo "🔍 Kiểm tra chi tiết trạng thái ứng dụng..."
echo "=========================================="

echo ""
echo "📊 Trạng thái Docker containers:"
docker-compose ps

echo ""
echo "🔌 Kiểm tra port đang listen (không cần netcat):"
ss -tlnp | grep -E ":80|:443|:8080" || netstat -tlnp | grep -E ":80|:443|:8080"

echo ""
echo "📝 Log gần đây từ nginx:"
docker-compose logs --tail=10 nginx

echo ""
echo "📝 Log gần đây từ app:"
docker-compose logs --tail=10 app

echo ""
echo "🌐 Test full HTTP response:"
echo "=== HTTP Response ==="
curl -v http://localhost 2>&1 | head -20

echo ""
echo "=== HTTPS Response ==="
curl -v https://tuyendungwellcenter.com 2>&1 | head -20

echo ""
echo "🔧 Kiểm tra nginx config:"
docker-compose exec nginx nginx -t

echo ""
echo "🏥 Test health endpoints:"
echo "App health check:"
curl -s http://localhost:8080/actuator/health 2>/dev/null || curl -s http://localhost:8080/ | head -5

echo ""
echo "📋 Firewall status:"
ufw status || echo "UFW not installed"

echo ""
echo "🎯 Kết luận:"
echo "Nếu curl trả về HTTP/1.1 200, website đang hoạt động!"
echo "Lỗi ERR_CONNECTION_REFUSED có thể do:"
echo "1. Cache browser - thử Ctrl+F5 hoặc mở incognito"
echo "2. DNS cache local - thử flushdns"
echo "3. ISP/Firewall local block domain"
