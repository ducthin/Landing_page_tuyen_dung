#!/bin/bash

# Script khôi phục cấu hình SSL đầy đủ
echo "🔐 Khôi phục cấu hình SSL đầy đủ cho tuyendungwellcenter.com"

# Kiểm tra certificate đã tồn tại chưa
if [ ! -f "/etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem" ]; then
    echo "❌ SSL certificate chưa được tạo!"
    echo "   Chạy script setup-ssl.sh trước"
    exit 1
fi

# Khôi phục nginx config với SSL
if [ -f "nginx.conf.backup" ]; then
    cp nginx.conf.backup nginx.conf
    echo "✅ Khôi phục nginx config với SSL"
else
    echo "⚠️  Không tìm thấy backup, tạo config SSL mới..."
    # Tạo config SSL đầy đủ
    cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app_backend {
        server app:8080;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

        # SSL Configuration - Let's Encrypt
        ssl_certificate /etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/tuyendungwellcenter.com/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

        # Proxy settings
        location / {
            proxy_pass http://app_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Static files caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            proxy_pass http://app_backend;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # File upload size
        client_max_body_size 5M;
    }
}
EOF
fi

# Restart services
echo "🚀 Khởi động lại services với SSL..."
docker-compose down
docker-compose up -d

echo "✅ Hoàn tất! Website có SSL tại: https://tuyendungwellcenter.com"
