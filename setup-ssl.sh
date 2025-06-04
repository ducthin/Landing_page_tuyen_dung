#!/bin/bash

# Script cài đặt SSL certificate với Let's Encrypt cho tuyendungwellcenter.com
echo "🔐 Cài đặt SSL Certificate cho tuyendungwellcenter.com"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Script này cần chạy với quyền root. Sử dụng: sudo $0"
    exit 1
fi

# Domain configuration
DOMAIN="tuyendungwellcenter.com"
EMAIL="hr.wellcenter@gmail.com"  # Email để nhận thông báo từ Let's Encrypt

echo "📋 Cấu hình:"
echo "   - Domain: $DOMAIN"
echo "   - WWW Domain: www.$DOMAIN"
echo "   - Email: $EMAIL"
echo ""

# Kiểm tra DNS đã trỏ về server chưa
echo "🔍 Kiểm tra DNS configuration..."
CURRENT_IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(dig +short $DOMAIN)
WWW_IP=$(dig +short www.$DOMAIN)

echo "Server IP: $CURRENT_IP"
echo "Domain IP: $DOMAIN_IP"
echo "WWW IP: $WWW_IP"

if [ "$CURRENT_IP" != "$DOMAIN_IP" ] || [ "$CURRENT_IP" != "$WWW_IP" ]; then
    echo "⚠️  CẢNH BÁO: DNS chưa trỏ đúng về server!"
    echo "   Bạn cần cấu hình DNS records:"
    echo "   A record: @ -> $CURRENT_IP"
    echo "   A record: www -> $CURRENT_IP"
    echo ""
    read -p "Bạn có muốn tiếp tục không? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Hủy bỏ cài đặt SSL"
        exit 1
    fi
fi

# Cài đặt Certbot
echo "📦 Cài đặt Certbot..."
apt update
apt install -y certbot python3-certbot-nginx

# Dừng nginx tạm thời để Let's Encrypt có thể verify domain
echo "🛑 Dừng Nginx tạm thời..."
docker-compose exec nginx nginx -s stop 2>/dev/null || true

# Tạo certificate với Let's Encrypt
echo "🔐 Tạo SSL certificate..."
certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

# Kiểm tra certificate đã được tạo chưa
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "❌ Không thể tạo SSL certificate!"
    echo "   Kiểm tra lại DNS và thử lại sau"
    exit 1
fi

echo "✅ SSL certificate đã được tạo thành công!"

# Khởi động lại containers với SSL
echo "🚀 Khởi động lại services với SSL..."
docker-compose down
docker-compose up -d

# Tạo cron job để auto-renew certificate
echo "⏰ Cài đặt auto-renewal..."
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet && docker-compose exec nginx nginx -s reload") | crontab -

# Kiểm tra kết nối HTTPS
echo "🔍 Kiểm tra SSL..."
sleep 10

if curl -I https://$DOMAIN --connect-timeout 10 >/dev/null 2>&1; then
    echo "✅ HTTPS hoạt động bình thường!"
    echo ""
    echo "🎉 CÀI ĐẶT HOÀN TẤT!"
    echo "   Website: https://$DOMAIN"
    echo "   WWW: https://www.$DOMAIN"
    echo "   Certificate sẽ tự động renew"
else
    echo "⚠️  HTTPS chưa hoạt động, kiểm tra logs:"
    echo "   docker-compose logs nginx"
fi

echo ""
echo "📋 Các bước tiếp theo:"
echo "1. Kiểm tra website: https://$DOMAIN"
echo "2. Test form submit và upload CV"
echo "3. Cấu hình monitoring (optional)"
echo "4. Backup database định kỳ (optional)"
