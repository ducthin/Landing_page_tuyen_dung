#!/bin/bash

echo "🔍 Chẩn đoán lỗi ERR_CONNECTION_REFUSED..."
echo "========================================="

# Thông tin server
SERVER_IP="14.225.207.250"
DOMAIN="tuyendungwellcenter.com"

echo ""
echo "📍 Kiểm tra DNS và địa chỉ IP:"
echo "Domain: $DOMAIN"
echo "Expected IP: $SERVER_IP"

# Kiểm tra DNS resolution
echo ""
echo "🌐 Kiểm tra DNS resolution:"
nslookup $DOMAIN || dig $DOMAIN || echo "❌ Không thể resolve DNS"

echo ""
echo "🏓 Kiểm tra kết nối mạng đến server:"
ping -c 3 $SERVER_IP || echo "❌ Không thể ping server IP"

echo ""
echo "🔌 Kiểm tra các port quan trọng:"
echo "Port 22 (SSH):"
nc -zv $SERVER_IP 22 2>&1 || echo "❌ Port 22 không mở"

echo "Port 80 (HTTP):"
nc -zv $SERVER_IP 80 2>&1 || echo "❌ Port 80 không mở"

echo "Port 443 (HTTPS):"
nc -zv $SERVER_IP 443 2>&1 || echo "❌ Port 443 không mở"

echo "Port 8080 (App direct):"
nc -zv $SERVER_IP 8080 2>&1 || echo "❌ Port 8080 không mở"

echo ""
echo "🌍 Kiểm tra HTTP/HTTPS response:"
echo "HTTP test:"
curl -I --connect-timeout 10 http://$DOMAIN 2>/dev/null | head -1 || echo "❌ HTTP không hoạt động"

echo "HTTPS test:"
curl -I --connect-timeout 10 https://$DOMAIN 2>/dev/null | head -1 || echo "❌ HTTPS không hoạt động"

echo "Direct IP HTTP test:"
curl -I --connect-timeout 10 http://$SERVER_IP 2>/dev/null | head -1 || echo "❌ Direct IP HTTP không hoạt động"

echo ""
echo "🔍 Chẩn đoán nguyên nhân có thể:"
echo "1. Server đã tắt hoặc restart"
echo "2. Docker containers không chạy"
echo "3. Firewall/UFW đã chặn port"
echo "4. Nginx không start được"
echo "5. Cloud provider có vấn đề mạng"

echo ""
echo "✅ Để khắc phục, SSH vào server và chạy:"
echo "ssh root@$SERVER_IP"
echo "docker-compose ps                  # Kiểm tra container status"
echo "sudo ufw status                    # Kiểm tra firewall"
echo "docker-compose logs nginx         # Xem log nginx"
echo "docker-compose up -d              # Restart containers"
echo "systemctl status docker           # Kiểm tra Docker service"
