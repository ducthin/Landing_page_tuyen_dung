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

# Cài đặt DNS utilities
echo "📦 Cài đặt DNS utilities..."
apt update
apt install -y dnsutils

# Kiểm tra DNS đã trỏ về server chưa
echo "🔍 Kiểm tra DNS configuration..."
CURRENT_IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(dig +short $DOMAIN | tail -n1)
WWW_IP=$(dig +short www.$DOMAIN | tail -n1)

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
apt install -y certbot python3-certbot-nginx

# Dừng Docker containers để giải phóng port 80
echo "🛑 Dừng Docker containers tạm thời..."
docker-compose down

# Đảm bảo không có process nào đang sử dụng port 80
echo "🔍 Kiểm tra processes đang sử dụng port 80..."
if lsof -i :80 >/dev/null 2>&1; then
    echo "⚠️  Có processes đang sử dụng port 80:"
    lsof -i :80
    echo "🛑 Dừng các processes này..."
    sudo pkill -f nginx || true
    sudo systemctl stop nginx || true
    sudo systemctl stop apache2 || true
    sleep 3
fi

# Kiểm tra lại port 80
if lsof -i :80 >/dev/null 2>&1; then
    echo "❌ Port 80 vẫn đang được sử dụng. Không thể tiếp tục."
    lsof -i :80
    exit 1
fi

echo "✅ Port 80 đã sẵn sàng"

# Tạo certificate với Let's Encrypt (standalone mode)
echo "🔐 Tạo SSL certificate..."
certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive \
    -d $DOMAIN \
    -d www.$DOMAIN

# Kiểm tra certificate đã được tạo chưa
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "❌ Không thể tạo SSL certificate!"
    echo "   Lý do có thể:"
    echo "   1. DNS chưa trỏ về server"
    echo "   2. Firewall chặn port 80/443"
    echo "   3. Domain không accessible từ internet"
    echo ""
    echo "   Khởi động lại containers với HTTP only..."
    docker-compose up -d
    exit 1
fi

echo "✅ SSL certificate đã được tạo thành công!"

# Khôi phục nginx config với SSL
if [ -f "nginx.conf.backup" ]; then
    cp nginx.conf.backup nginx.conf
    echo "✅ Khôi phục nginx config với SSL"
else
    echo "⚠️  Không tìm thấy backup, nginx config hiện tại sẽ được sử dụng"
fi

# Khởi động lại containers với SSL
echo "🚀 Khởi động lại services với SSL..."
docker-compose up -d

# Tạo cron job để auto-renew certificate
echo "⏰ Cài đặt auto-renewal..."
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --deploy-hook 'docker-compose -f /opt/wellcenter/docker-compose.yml restart nginx'") | crontab -

# Kiểm tra kết nối HTTPS
echo "🔍 Kiểm tra SSL..."
sleep 15

if curl -I https://$DOMAIN --connect-timeout 10 >/dev/null 2>&1; then
    echo "✅ HTTPS hoạt động bình thường!"
    echo ""
    echo "🎉 CÀI ĐẶT HOÀN TẤT!"
    echo "   Website: https://$DOMAIN"
    echo "   WWW: https://www.$DOMAIN"
    echo "   Certificate sẽ tự động renew"
else
    echo "⚠️  HTTPS chưa hoạt động hoàn toàn, kiểm tra logs:"
    echo "   docker-compose logs nginx"
    echo ""
    echo "📋 Troubleshooting:"
    echo "   1. Kiểm tra certificate: ls -la /etc/letsencrypt/live/$DOMAIN/"
    echo "   2. Kiểm tra nginx config: docker-compose exec nginx nginx -t"
    echo "   3. Restart services: docker-compose restart"
fi

echo ""
echo "📋 Các bước tiếp theo:"
echo "1. Kiểm tra website: https://$DOMAIN"
echo "2. Test form submit và upload CV"
echo "3. Cấu hình monitoring (optional)"
echo "4. Backup database định kỳ (optional)"
