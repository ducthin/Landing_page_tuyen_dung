#!/bin/bash

echo "🔐 Tạo Self-Signed SSL Certificate cho tuyendungwellcenter.com"

# Dừng Docker containers
echo "🛑 Dừng Docker containers..."
docker-compose down

# Tạo thư mục cho SSL certificates
mkdir -p /etc/ssl/certs
mkdir -p /etc/ssl/private

# Tạo self-signed certificate
echo "🔧 Tạo self-signed SSL certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/tuyendungwellcenter.key \
    -out /etc/ssl/certs/tuyendungwellcenter.crt \
    -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=WellCenter/OU=IT/CN=tuyendungwellcenter.com"

# Cập nhật nginx.conf với self-signed SSL
echo "🔧 Cập nhật nginx.conf với self-signed SSL..."
cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

    ssl_certificate /etc/ssl/certs/tuyendungwellcenter.crt;
    ssl_certificate_key /etc/ssl/private/tuyendungwellcenter.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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

# Cập nhật docker-compose.yml để mount SSL certificates
echo "🔧 Cập nhật docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: recruitment_mysql
    environment:
      MYSQL_ROOT_PASSWORD: WellCenter2024!
      MYSQL_DATABASE: recruitment_db
      MYSQL_USER: recruitment_user
      MYSQL_PASSWORD: WellCenter2024!
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - recruitment_network
    restart: unless-stopped

  app:
    build: .
    container_name: recruitment_app
    depends_on:
      - mysql
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/recruitment_db
      SPRING_DATASOURCE_USERNAME: recruitment_user
      SPRING_DATASOURCE_PASSWORD: WellCenter2024!
    networks:
      - recruitment_network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: recruitment_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - /etc/ssl/certs:/etc/ssl/certs:ro
      - /etc/ssl/private:/etc/ssl/private:ro
    depends_on:
      - app
    networks:
      - recruitment_network
    restart: unless-stopped

volumes:
  mysql_data:

networks:
  recruitment_network:
    driver: bridge
EOF

echo "🚀 Khởi động lại Docker containers với Self-Signed SSL..."
docker-compose up -d

echo "✅ Website hiện có HTTPS với self-signed certificate!"
echo "🔗 https://tuyendungwellcenter.com"
echo "⚠️  Trình duyệt sẽ cảnh báo về certificate không tin cậy - điều này là bình thường với self-signed cert"
echo "📋 Sau này có thể thay thế bằng Let's Encrypt certificate khi DNS hoạt động ổn định"
