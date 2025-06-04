#!/bin/bash

# Script để test email với Postfix

echo "📮 TESTING POSTFIX EMAIL SYSTEM"
echo "==============================="

# Kiểm tra Postfix đang chạy
echo "1️⃣ Checking Postfix status..."
if systemctl is-active --quiet postfix; then
    echo "✅ Postfix is running"
    systemctl status postfix --no-pager -l
else
    echo "❌ Postfix is not running"
    echo "   Try: sudo systemctl start postfix"
    exit 1
fi

echo ""
echo "2️⃣ Checking Postfix configuration..."
postfix check
if [ $? -eq 0 ]; then
    echo "✅ Postfix configuration is valid"
else
    echo "❌ Postfix configuration has errors"
    exit 1
fi

echo ""
echo "3️⃣ Testing direct email sending..."

# Test với mail command
TEST_EMAIL="admin@tuyendungwellcenter.com"
echo "Testing Postfix direct send to: $TEST_EMAIL"

echo "Test email sent directly via Postfix on $(date)" | mail -s "🧪 Postfix Direct Test" $TEST_EMAIL

if [ $? -eq 0 ]; then
    echo "✅ Direct email sent successfully"
else
    echo "❌ Failed to send direct email"
fi

echo ""
echo "4️⃣ Checking mail queue..."
QUEUE_COUNT=$(postqueue -p | grep -c "^[A-F0-9]")
echo "Mail queue has $QUEUE_COUNT messages"

if [ $QUEUE_COUNT -gt 0 ]; then
    echo "📋 Mail queue:"
    postqueue -p
fi

echo ""
echo "5️⃣ Testing application email..."

# Kiểm tra ứng dụng có chạy không
if curl -s --connect-timeout 5 http://localhost:8080 > /dev/null; then
    echo "✅ Application is running locally"
    
    # Test qua ứng dụng
    echo "🔄 Testing email via application..."
    RESPONSE=$(curl -s http://localhost:8080/test-email)
    echo "📧 Application response:"
    echo "$RESPONSE"
    
    if echo "$RESPONSE" | grep -q "successfully"; then
        echo "✅ Application email test passed"
    else
        echo "❌ Application email test failed"
    fi
    
elif curl -s --connect-timeout 5 https://tuyendungwellcenter.com > /dev/null; then
    echo "✅ Application is running via HTTPS"
    
    # Test qua HTTPS
    echo "🔄 Testing email via HTTPS..."
    RESPONSE=$(curl -s https://tuyendungwellcenter.com/test-email)
    echo "📧 Application response:"
    echo "$RESPONSE"
    
    if echo "$RESPONSE" | grep -q "successfully"; then
        echo "✅ Application email test passed"
    else
        echo "❌ Application email test failed"
    fi
else
    echo "❌ Application is not accessible"
fi

echo ""
echo "6️⃣ Checking recent Postfix logs..."
echo "📋 Last 10 Postfix log entries:"
tail -10 /var/log/postfix.log 2>/dev/null || tail -10 /var/log/mail.log 2>/dev/null || echo "No Postfix logs found"

echo ""
echo "7️⃣ Network connectivity test..."
echo "🌐 Testing outbound SMTP connectivity:"

# Test kết nối ra ngoài (port 25)
nc -zv gmail.com 25 2>&1 | head -1
nc -zv outlook.com 25 2>&1 | head -1

echo ""
echo "📊 POSTFIX TEST SUMMARY"
echo "======================"
echo "Postfix Status: $(systemctl is-active postfix)"
echo "Configuration: $(postfix check > /dev/null 2>&1 && echo 'Valid' || echo 'Invalid')"
echo "Mail Queue: $QUEUE_COUNT messages"
echo "Application: $(curl -s --connect-timeout 3 http://localhost:8080 > /dev/null && echo 'Running' || echo 'Not accessible')"

echo ""
echo "🔧 TROUBLESHOOTING COMMANDS:"
echo "# View live logs:"
echo "sudo tail -f /var/log/postfix.log"
echo ""
echo "# Check mail queue:"
echo "postqueue -p"
echo ""
echo "# Clear mail queue:"
echo "sudo postsuper -d ALL"
echo ""
echo "# Restart Postfix:"
echo "sudo systemctl restart postfix"
echo ""
echo "# Test manual send:"
echo "echo 'Test message' | mail -s 'Test Subject' your-email@domain.com"
