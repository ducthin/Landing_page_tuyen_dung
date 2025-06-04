#!/bin/bash

# Script cấu hình domain tạm thời chỉ với HTTP (để test DNS trước khi cài SSL)
echo "🌐 Cấu hình domain tuyendungwellcenter.com (HTTP only)"

# Tạo nginx config tạm thời chỉ HTTP
cat > nginx-temp.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app_backend {
        server app:8080;
    }

    # HTTP server only (for testing DNS)
    server {
        listen 80;
        server_name tuyendungwellcenter.com www.tuyendungwellcenter.com;

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

echo "✅ Tạo nginx config tạm thời (HTTP only)"

# Backup current config
cp nginx.conf nginx.conf.backup
echo "📋 Backup nginx config hiện tại -> nginx.conf.backup"

# Replace with temp config
cp nginx-temp.conf nginx.conf
echo "🔄 Áp dụng config tạm thời"

# Restart services
echo "🚀 Khởi động lại services..."
docker-compose down
docker-compose up -d

echo ""
echo "🎯 HƯỚNG DẪN TIẾP THEO:"
echo ""
echo "1. 📋 CẤU HÌNH DNS TẠI NHÀ CUNG CẤP DOMAIN:"
echo "   - Truy cập quản lý DNS của tuyendungwellcenter.com"
echo "   - Tạo A record: @ -> $(curl -s ifconfig.me)"
echo "   - Tạo A record: www -> $(curl -s ifconfig.me)"
echo ""
echo "2. ⏳ ĐỢI DNS CẬP NHẬT (5-60 phút):"
echo "   - Kiểm tra: dig +short tuyendungwellcenter.com"
echo "   - Kiểm tra: dig +short www.tuyendungwellcenter.com"
echo ""
echo "3. 🧪 TEST DOMAIN:"
echo "   - Mở browser: http://tuyendungwellcenter.com"
echo "   - Test: curl -I http://tuyendungwellcenter.com"
echo ""
echo "4. 🔐 CÀI ĐẶT SSL (sau khi domain hoạt động):"
echo "   - Chạy: ./setup-ssl.sh"
echo ""
echo "📊 KIỂM TRA HIỆN TẠI:"
echo "   - Server IP: $(curl -s ifconfig.me)"
echo "   - Service status: docker-compose ps"

# Clean up temp file
rm nginx-temp.conf

echo ""
echo "💡 LƯU Ý:"
echo "   - Config hiện tại chỉ HTTP (không an toàn cho production)"
echo "   - Sau khi DNS hoạt động, chạy setup-ssl.sh để có HTTPS"
echo "   - Backup được lưu tại: nginx.conf.backup"
