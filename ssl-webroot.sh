#!/bin/bash

# Script cài đặt SSL với HTTP validation (thay vì standalone)
echo "🔐 Cài đặt SSL với HTTP validation cho tuyendungwellcenter.com"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Script này cần chạy với quyền root. Sử dụng: sudo $0"
    exit 1
fi

DOMAIN="tuyendungwellcenter.com"
EMAIL="hr.wellcenter@gmail.com"

echo "📋 Cài đặt SSL với webroot validation"
echo "   - Domain: $DOMAIN"
echo "   - Method: Webroot (HTTP validation)"
echo ""

# Tạo thư mục webroot cho validation
WEBROOT="/var/www/letsencrypt"
mkdir -p $WEBROOT/.well-known/acme-challenge

# Cấu hình nginx tạm thời cho webroot validation
cat > /tmp/nginx-ssl-temp.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
        
        # Let's Encrypt validation
        location /.well-known/acme-challenge/ {
            root /var/www/letsencrypt;
            try_files $uri =404;
        }
        
        # Proxy tất cả request khác đến app
        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

echo "🛑 Dừng Docker containers..."
docker-compose down

# Dừng các nginx services
systemctl stop nginx 2>/dev/null || true
pkill -f nginx 2>/dev/null || true

# Khởi động app container (không có nginx)
echo "🚀 Khởi động app container..."
docker-compose up -d app mysql

# Đợi app khởi động
echo "⏳ Đợi app khởi động..."
sleep 15

# Chạy nginx tạm thời với config validation
echo "🌐 Khởi động nginx với webroot config..."
nginx -c /tmp/nginx-ssl-temp.conf

# Tạo certificate với webroot
echo "🔐 Tạo SSL certificate với webroot validation..."
certbot certonly --webroot \
    --webroot-path=$WEBROOT \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive \
    -d $DOMAIN \
    -d www.$DOMAIN

# Kiểm tra certificate
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ SSL certificate đã được tạo thành công!"
    
    # Dừng nginx tạm thời
    pkill -f nginx
    
    # Khôi phục nginx config với SSL và khởi động full stack
    echo "🚀 Khởi động full stack với SSL..."
    docker-compose up -d
    
    echo "🎉 HOÀN TẤT!"
    echo "   Website: https://$DOMAIN"
    
else
    echo "❌ Không thể tạo SSL certificate với webroot method!"
    echo "🔍 Kiểm tra logs:"
    tail -20 /var/log/letsencrypt/letsencrypt.log
    
    # Dừng nginx tạm thời
    pkill -f nginx
    
    # Khởi động lại với HTTP only
    echo "🚀 Khởi động lại với HTTP only..."
    docker-compose up -d
fi

# Cleanup
rm -f /tmp/nginx-ssl-temp.conf
rm -rf $WEBROOT
