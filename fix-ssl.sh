#!/bin/bash

# Script khắc phục nhanh lỗi SSL - dành cho trường hợp đã chạy setup-ssl.sh không thành công
echo "🔧 Khắc phục lỗi SSL cho tuyendungwellcenter.com"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Script này cần chạy với quyền root. Sử dụng: sudo $0"
    exit 1
fi

DOMAIN="tuyendungwellcenter.com"
EMAIL="hr.wellcenter@gmail.com"

echo "🛑 Dừng tất cả Docker containers..."
docker-compose down
docker stop $(docker ps -aq) 2>/dev/null || true

echo "🔍 Dừng tất cả services có thể chiếm port 80/443..."
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop apache2 2>/dev/null || true
sudo pkill -f nginx 2>/dev/null || true
sudo pkill -f apache 2>/dev/null || true

# Chờ một chút để các processes dừng hoàn toàn
sleep 5

echo "🔍 Kiểm tra port 80 và 443..."
if netstat -tlnp | grep :80 >/dev/null; then
    echo "❌ Port 80 vẫn đang được sử dụng:"
    netstat -tlnp | grep :80
    echo "Vui lòng dừng process này trước khi tiếp tục"
    exit 1
fi

if netstat -tlnp | grep :443 >/dev/null; then
    echo "❌ Port 443 vẫn đang được sử dụng:"
    netstat -tlnp | grep :443
    echo "Vui lòng dừng process này trước khi tiếp tục"
    exit 1
fi

echo "✅ Ports 80 và 443 đã sẵn sàng"

# Cài đặt Certbot nếu chưa có
if ! command -v certbot &> /dev/null; then
    echo "📦 Cài đặt Certbot..."
    apt update
    apt install -y certbot
fi

# Xóa certificates cũ nếu có (để tạo lại)
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🗑️  Xóa certificate cũ để tạo lại..."
    certbot delete --cert-name $DOMAIN --non-interactive
fi

echo "🔐 Tạo SSL certificate mới..."
certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive \
    --force-renewal \
    -d $DOMAIN \
    -d www.$DOMAIN

# Kiểm tra certificate
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ SSL certificate đã được tạo thành công!"
    echo "📁 Certificate location: /etc/letsencrypt/live/$DOMAIN/"
    
    # Hiển thị thông tin certificate
    echo "📋 Certificate info:"
    openssl x509 -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem -text -noout | grep -A 2 "Validity"
    
    # Khởi động lại Docker containers
    echo "🚀 Khởi động lại services..."
    docker-compose up -d
    
    # Chờ services khởi động
    echo "⏳ Chờ services khởi động..."
    sleep 20
    
    # Test HTTPS
    echo "🔍 Kiểm tra HTTPS..."
    if curl -I https://$DOMAIN --connect-timeout 10 >/dev/null 2>&1; then
        echo "✅ HTTPS hoạt động bình thường!"
        echo "🎉 Website: https://$DOMAIN"
    else
        echo "⚠️  HTTPS chưa hoạt động, kiểm tra nginx logs:"
        docker-compose logs nginx | tail -20
    fi
    
else
    echo "❌ Không thể tạo SSL certificate!"
    echo "🔍 Kiểm tra lỗi Certbot:"
    cat /var/log/letsencrypt/letsencrypt.log | tail -20
    
    echo "🚀 Khởi động lại services với HTTP only..."
    docker-compose up -d
fi

echo ""
echo "📋 Nếu vẫn có lỗi, kiểm tra:"
echo "1. DNS: dig $DOMAIN"
echo "2. Firewall: ufw status"
echo "3. Docker logs: docker-compose logs"
echo "4. Certbot logs: tail -f /var/log/letsencrypt/letsencrypt.log"
