#!/bin/bash

echo "🔍 QUICK APPLICATION STATUS CHECK"
echo "=================================="

# Check current status
echo "1. Container Status:"
docker-compose ps | grep recruitment_app

echo ""
echo "2. App Health:"
docker inspect recruitment_app --format='{{.State.Health.Status}}'

echo ""
echo "3. Recent logs (last 10 lines):"
docker-compose logs --tail=10 app

echo ""
echo "4. Testing endpoints if app is healthy..."
APP_STATUS=$(docker inspect recruitment_app --format='{{.State.Health.Status}}')

if [ "$APP_STATUS" = "healthy" ]; then
    echo "✅ App is healthy! Testing endpoints..."
    echo ""
    echo "Testing main page:"
    curl -v http://localhost/ 2>&1 | head -10
    echo ""
    echo "Testing email endpoint:"
    curl -v http://localhost/test-email 2>&1 | head -10
elif [ "$APP_STATUS" = "starting" ]; then
    echo "⏳ App is still starting. Wait a few more minutes and run this script again."
    echo "💡 Tip: Run 'docker-compose logs -f app' to watch the startup process"
else
    echo "❌ App status: $APP_STATUS"
    echo "Check the logs above for errors."
fi
