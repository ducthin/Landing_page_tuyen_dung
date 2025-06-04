#!/bin/bash

# Script để monitor logs khi app chạy trực tiếp

echo "📊 MONITORING DIRECT RUN LOGS"
echo "============================="

APP_URL="http://localhost:8080"

# Kiểm tra app có chạy không
echo "🔍 Checking if application is running..."
if curl -s "$APP_URL" > /dev/null; then
    echo "✅ Application is running on $APP_URL"
else
    echo "❌ Application is not running"
    echo "   Make sure test-direct-run.sh is running in another terminal"
    exit 1
fi

echo ""
echo "📋 Available monitoring options:"
echo "1. Check application logs (if running with nohup)"
echo "2. Monitor Java process"
echo "3. Check email configuration"
echo "4. Test email sending"
echo "5. Monitor network connections"
echo ""

read -p "Select option (1-5): " choice

case $choice in
    1)
        echo "📄 Application logs:"
        if [ -f nohup.out ]; then
            tail -f nohup.out
        else
            echo "⚠️ No nohup.out found. App might be running in foreground."
            echo "   Check the terminal where you ran test-direct-run.sh"
        fi
        ;;
    2)
        echo "🔍 Java processes:"
        ps aux | grep java | grep -v grep
        echo ""
        echo "📊 Memory usage:"
        ps aux | grep java | grep -v grep | awk '{print "PID: " $2 ", CPU: " $3 "%, MEM: " $4 "%, CMD: " $11}'
        ;;
    3)
        echo "📧 Email configuration:"
        curl -s "$APP_URL/email-config"
        ;;
    4)
        echo "🧪 Testing email sending..."
        curl -s "$APP_URL/test-email"
        ;;
    5)
        echo "🌐 Network connections:"
        echo "Port 8080 status:"
        netstat -tlnp | grep 8080
        echo ""
        echo "SMTP connections (if any):"
        netstat -an | grep 587
        echo ""
        echo "Established connections:"
        netstat -an | grep ESTABLISHED | head -10
        ;;
    *)
        echo "❌ Invalid option"
        ;;
esac
