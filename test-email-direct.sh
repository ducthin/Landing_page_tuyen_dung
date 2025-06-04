#!/bin/bash

# Script để test email khi ứng dụng đang chạy trực tiếp
# Chạy script này trong terminal thứ 2 khi app đã start

echo "🧪 TESTING EMAIL WHEN APP RUNS DIRECTLY"
echo "======================================="

APP_URL="http://localhost:8080"

# Kiểm tra app có chạy không
echo "1️⃣ Checking if application is running..."
if curl -s "$APP_URL" > /dev/null; then
    echo "✅ Application is running"
else
    echo "❌ Application is not running on $APP_URL"
    echo "   Make sure you run test-direct-run.sh first"
    exit 1
fi

# Kiểm tra email config
echo ""
echo "2️⃣ Checking email configuration..."
curl -s "$APP_URL/email-config" | grep -E "(From Email|Admin Email|Status)" || {
    echo "📄 Full email config response:"
    curl -s "$APP_URL/email-config"
}

# Test gửi email
echo ""
echo "3️⃣ Testing email sending..."
echo "🔄 Sending test email..."

RESPONSE=$(curl -s "$APP_URL/test-email")
echo "📧 Email test response:"
echo "$RESPONSE"

if echo "$RESPONSE" | grep -q "✅ Test email sent successfully"; then
    echo ""
    echo "🎉 SUCCESS! Email was sent successfully!"
    echo "   Please check your email inbox and spam folder"
    echo "   Email should be sent to: $(grep ADMIN_EMAIL .env | cut -d'=' -f2)"
else
    echo ""
    echo "❌ Email sending failed. Check the error message above."
    echo "   Common issues when running directly:"
    echo "   - Gmail app password incorrect"
    echo "   - 2FA not enabled on Gmail account"
    echo "   - Gmail account locked/suspicious activity"
    echo "   - Firewall blocking SMTP connection"
fi

echo ""
echo "📊 Additional debugging info:"
echo "   - App running on: $APP_URL"
echo "   - Environment: Direct (not Docker)"
echo "   - Check app logs for detailed error messages"
echo ""
echo "🔧 If email still fails, try:"
echo "   1. Use a new Gmail account with fresh app password"
echo "   2. Switch to Outlook SMTP"
echo "   3. Use a transactional email service (SendGrid, Mailgun)"
