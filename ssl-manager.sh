#!/bin/bash

# Script chuyển đổi giữa HTTP và HTTPS
echo "🔄 SSL Configuration Manager"
echo "============================"

# Kiểm tra current configuration
if grep -q "listen 443 ssl" nginx.conf; then
    CURRENT_MODE="HTTPS"
else
    CURRENT_MODE="HTTP"
fi

echo "📊 Current mode: $CURRENT_MODE"
echo ""
echo "Chọn chế độ:"
echo "1. HTTP only (for initial setup/testing)"
echo "2. HTTPS (production with SSL)"
echo "3. Force HTTPS redirect"
echo ""

read -p "Nhập lựa chọn (1-3): " choice

case $choice in
    1)
        echo "🔄 Chuyển sang HTTP only mode..."
        # Backup current config
        cp nginx.conf nginx.conf.backup
        
        # Create HTTP-only config
        cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

    client_max_body_size 10M;

    # Security headers
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    location / {
        proxy_pass http://recruitment_app:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
        echo "✅ HTTP only mode đã được cấu hình"
        ;;
        
    2)
        echo "🔄 Chuyển sang HTTPS mode..."
        # Check if SSL certificates exist
        if [ ! -f "/etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem" ]; then
            echo "❌ SSL certificates không tồn tại!"
            echo "   Chạy ./setup-ssl.sh để tạo certificates trước"
            exit 1
        fi
        
        # Backup current config
        cp nginx.conf nginx.conf.backup
        
        # Restore HTTPS config (already in file)
        echo "✅ HTTPS mode đã được cấu hình"
        ;;
        
    3)
        echo "🔄 Cấu hình Force HTTPS redirect..."
        # Check if SSL certificates exist
        if [ ! -f "/etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem" ]; then
            echo "❌ SSL certificates không tồn tại!"
            echo "   Chạy ./setup-ssl.sh để tạo certificates trước"
            exit 1
        fi
        
        # Backup current config
        cp nginx.conf nginx.conf.backup
        
        # Create config with forced HTTPS redirect
        cat > nginx.conf << 'EOF'
# HTTP server - force redirect to HTTPS
server {
    listen 80;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tuyendungwellcenter.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/tuyendungwellcenter.com/chain.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    client_max_body_size 10M;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; img-src 'self' data:; font-src 'self' https://cdnjs.cloudflare.com;" always;

    location / {
        proxy_pass http://recruitment_app:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
        echo "✅ Force HTTPS redirect đã được cấu hình"
        ;;
        
    *)
        echo "❌ Lựa chọn không hợp lệ"
        exit 1
        ;;
esac

# Restart nginx
echo "🔄 Restart nginx..."
docker-compose restart nginx

# Test configuration
echo "🔍 Test nginx configuration..."
if docker-compose exec nginx nginx -t; then
    echo "✅ Nginx configuration OK"
else
    echo "❌ Nginx configuration có lỗi!"
    if [ -f "nginx.conf.backup" ]; then
        echo "🔄 Khôi phục configuration cũ..."
        cp nginx.conf.backup nginx.conf
        docker-compose restart nginx
    fi
    exit 1
fi

echo ""
echo "🎉 Hoàn tất!"
case $choice in
    1)
        echo "🌐 Website: http://tuyendungwellcenter.com"
        ;;
    2|3)
        echo "🔐 Website: https://tuyendungwellcenter.com"
        echo "🔗 HTTP redirect: http://tuyendungwellcenter.com"
        ;;
esac
