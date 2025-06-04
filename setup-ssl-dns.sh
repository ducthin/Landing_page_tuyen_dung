#!/bin/bash

echo "🔐 Thiết lập SSL bằng DNS Challenge cho tuyendungwellcenter.com"

# Dừng Docker containers
echo "🛑 Dừng Docker containers..."
docker-compose down

# Cài đặt Certbot DNS plugin (nếu chưa có)
echo "📦 Cài đặt Certbot DNS plugins..."
apt update
apt install -y certbot python3-certbot-nginx python3-certbot-dns-cloudflare

# Tạo SSL certificate bằng manual DNS challenge
echo "🔐 Tạo SSL certificate bằng DNS challenge..."
certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --email admin@tuyendungwellcenter.com \
  --agree-tos \
  --no-eff-email \
  -d tuyendungwellcenter.com \
  -d www.tuyendungwellcenter.com

if [ $? -eq 0 ]; then
    echo "✅ SSL certificate được tạo thành công!"
    
    # Cập nhật nginx.conf với SSL
    echo "🔧 Cập nhật nginx.conf với SSL..."
    cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

    ssl_certificate /etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tuyendungwellcenter.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    client_max_body_size 10M;

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
    
    echo "🚀 Khởi động lại Docker containers với SSL..."
    docker-compose up -d
    
    echo "✅ Website hiện có thể truy cập qua HTTPS!"
    echo "🔗 https://tuyendungwellcenter.com"
    
else
    echo "❌ Không thể tạo SSL certificate!"
    echo "🔄 Khởi động lại với HTTP only..."
    ./setup-http-only.sh
fi

echo "📋 Kiểm tra SSL certificate:"
echo "openssl s_client -connect tuyendungwellcenter.com:443 -servername tuyendungwellcenter.com"
