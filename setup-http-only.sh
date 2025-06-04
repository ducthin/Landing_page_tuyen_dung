#!/bin/bash

# Script tạo nginx config tạm thời chỉ HTTP (không SSL)
echo "🔧 Cấu hình nginx tạm thời chỉ HTTP (không SSL)"

# Backup nginx config hiện tại
if [ -f "nginx.conf" ]; then
    cp nginx.conf nginx.conf.ssl-backup
    echo "✅ Backup nginx config -> nginx.conf.ssl-backup"
fi

# Tạo nginx config tạm thời chỉ HTTP
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Server configuration
    server {
        listen 80;
        server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        
        # Proxy to Spring Boot app
        location / {
            proxy_pass http://app:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            
            # Timeout settings
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # Buffer settings
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "✅ Tạo nginx config HTTP-only"

# Restart containers với config mới
echo "🔄 Restart containers với HTTP config..."
docker-compose restart nginx

# Chờ nginx khởi động
sleep 5

# Kiểm tra nginx status
echo "🔍 Kiểm tra nginx status..."
if docker-compose logs nginx | grep -q "ready for start up"; then
    echo "✅ Nginx đã khởi động thành công!"
else
    echo "❌ Nginx chưa khởi động thành công, xem logs:"
    docker-compose logs nginx | tail -10
fi

echo ""
echo "🌐 Test HTTP connectivity..."
if curl -I http://localhost >/dev/null 2>&1; then
    echo "✅ HTTP localhost OK"
else
    echo "❌ HTTP localhost FAILED"
fi

if curl -I http://127.0.0.1 >/dev/null 2>&1; then
    echo "✅ HTTP 127.0.0.1 OK"
else
    echo "❌ HTTP 127.0.0.1 FAILED"
fi

echo ""
echo "📋 Tiếp theo:"
echo "1. Test domain: curl -I http://tuyendungwellcenter.com"
echo "2. Nếu HTTP OK, chạy SSL: ./fix-ssl.sh"
echo "3. Khôi phục SSL config: cp nginx.conf.ssl-backup nginx.conf (sau khi có SSL)"
