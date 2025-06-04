#!/bin/bash

echo "🔧 Khắc phục lỗi HTTPS SSL..."
echo "=============================="

echo ""
echo "🔍 Kiểm tra SSL certificates hiện tại:"
if [ -d "/etc/letsencrypt/live/tuyendungwellcenter.com" ]; then
    echo "✅ SSL certificates tồn tại:"
    ls -la /etc/letsencrypt/live/tuyendungwellcenter.com/
    echo ""
    echo "📅 Expiry date:"
    openssl x509 -in /etc/letsencrypt/live/tuyendungwellcenter.com/cert.pem -text -noout | grep "Not After"
else
    echo "❌ SSL certificates không tồn tại"
fi

echo ""
echo "📝 Kiểm tra nginx SSL config:"
docker-compose exec nginx cat /etc/nginx/conf.d/default.conf | grep -A 20 "listen 443"

echo ""
echo "🔧 Giải pháp khắc phục:"
echo "1. Tạm thời chuyển về HTTP-only để website hoạt động:"
echo "   ./setup-http-only.sh"
echo ""
echo "2. Sau đó tái tạo SSL certificates:"
echo "   ./setup-ssl-dns.sh"
echo ""
echo "3. Hoặc dùng self-signed certificate (cho test):"
echo "   ./setup-ssl-self-signed.sh"

echo ""
echo "🚀 Chạy ngay lệnh này để website hoạt động:"
echo "========================================"
echo "./setup-http-only.sh && docker-compose restart nginx"
echo ""
echo "Sau đó truy cập: http://tuyendungwellcenter.com"
