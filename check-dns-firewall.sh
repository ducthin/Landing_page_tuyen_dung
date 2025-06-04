#!/bin/bash

# Script kiểm tra và khắc phục các vấn đề DNS/Firewall cho SSL
echo "🔍 Kiểm tra DNS và Firewall cho tuyendungwellcenter.com"

DOMAIN="tuyendungwellcenter.com"
CURRENT_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipecho.net/plain)

echo "📋 Thông tin server:"
echo "   - Server IP: $CURRENT_IP"
echo "   - Domain: $DOMAIN"
echo ""

# Kiểm tra DNS
echo "🌐 Kiểm tra DNS resolution..."
echo "Domain DNS:"
dig +short $DOMAIN
echo "WWW DNS:"
dig +short www.$DOMAIN

DOMAIN_IP=$(dig +short $DOMAIN | tail -n1)
if [ "$CURRENT_IP" = "$DOMAIN_IP" ]; then
    echo "✅ DNS trỏ đúng về server"
else
    echo "❌ DNS KHÔNG trỏ về server!"
    echo "   Expected: $CURRENT_IP"
    echo "   Current: $DOMAIN_IP"
    echo ""
    echo "🔧 Cần cấu hình DNS records:"
    echo "   A record: @ -> $CURRENT_IP"
    echo "   A record: www -> $CURRENT_IP"
    echo ""
    read -p "Nhấn Enter sau khi đã cấu hình DNS..."
fi

# Kiểm tra firewall
echo ""
echo "🔥 Kiểm tra Firewall..."
if command -v ufw >/dev/null 2>&1; then
    echo "UFW Status:"
    ufw status
    
    if ufw status | grep -q "Status: active"; then
        echo ""
        echo "🔧 Cấu hình UFW cho web traffic..."
        ufw allow 22/tcp
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 8080/tcp
        echo "✅ Đã mở ports 22, 80, 443, 8080"
    fi
else
    echo "UFW không có sẵn"
fi

# Kiểm tra iptables
echo ""
echo "🛡️  Kiểm tra iptables..."
if iptables -L INPUT -n | grep -q "DROP\|REJECT"; then
    echo "⚠️  Có rules DROP/REJECT trong iptables:"
    iptables -L INPUT -n | grep -E "DROP|REJECT"
    echo ""
    echo "🔧 Thêm rules cho HTTP/HTTPS..."
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT
    iptables -I INPUT -p tcp --dport 22 -j ACCEPT
    echo "✅ Đã thêm iptables rules"
else
    echo "✅ Không có restrictive iptables rules"
fi

# Kiểm tra cloud firewall
echo ""
echo "☁️  Kiểm tra Cloud Provider Firewall..."
echo "Nếu bạn sử dụng VPS từ nhà cung cấp như:"
echo "- DigitalOcean: Kiểm tra Firewalls trong control panel"
echo "- AWS: Kiểm tra Security Groups"
echo "- Google Cloud: Kiểm tra Firewall Rules"
echo "- Vultr: Kiểm tra Firewall trong control panel"
echo ""
echo "Đảm bảo ports 80, 443, 22 được mở từ mọi IP (0.0.0.0/0)"

# Test connectivity từ bên ngoài
echo ""
echo "🌍 Test connectivity từ bên ngoài..."
echo "Đang test HTTP connectivity..."

# Test với curl từ server local
if curl -I http://$DOMAIN --connect-timeout 10 >/dev/null 2>&1; then
    echo "✅ HTTP connectivity OK từ server"
else
    echo "❌ HTTP connectivity FAILED từ server"
fi

# Test với public DNS
echo ""
echo "📡 Test DNS từ public resolvers..."
echo "Google DNS (8.8.8.8):"
nslookup $DOMAIN 8.8.8.8 | grep "Address:"

echo "Cloudflare DNS (1.1.1.1):"
nslookup $DOMAIN 1.1.1.1 | grep "Address:"

# Test ports
echo ""
echo "🔌 Test port accessibility..."
for port in 80 443; do
    if nc -z -v -w5 $CURRENT_IP $port 2>/dev/null; then
        echo "✅ Port $port accessible"
    else
        echo "❌ Port $port NOT accessible"
    fi
done

echo ""
echo "🛠️  Khuyến nghị tiếp theo:"
echo "1. Nếu DNS chưa đúng: Đợi DNS propagation (5-60 phút)"
echo "2. Nếu firewall chặn: Kiểm tra cloud provider firewall"
echo "3. Test từ bên ngoài: https://www.yougetsignal.com/tools/open-ports/"
echo "4. Sau khi khắc phục: Chạy lại ./fix-ssl.sh"

echo ""
echo "📋 Commands hữu ích:"
echo "   - Test DNS: dig $DOMAIN"
echo "   - Test HTTP: curl -I http://$DOMAIN"
echo "   - Check ports: nmap -p 80,443 $CURRENT_IP"
