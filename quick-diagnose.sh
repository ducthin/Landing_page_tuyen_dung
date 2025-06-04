#!/bin/bash

echo "🔍 Quick 502 Diagnosis - $(date)"
echo "================================"

echo "1. Container Status:"
docker-compose ps

echo ""
echo "2. App Container Health:"
docker inspect recruitment_app --format='{{.State.Health.Status}}' 2>/dev/null || echo "Cannot get health status"

echo ""
echo "3. Recent App Logs (last 15 lines):"
docker-compose logs --tail=15 app

echo ""
echo "4. Test Internal App Health:"
docker exec recruitment_app curl -s http://localhost:8080/actuator/health 2>/dev/null || echo "App not responding internally"

echo ""
echo "5. Test App Direct Port:"
curl -s -m 5 http://localhost:8080/ || echo "Port 8080 not responding"

echo ""
echo "6. Check if app process is running:"
docker exec recruitment_app ps aux | grep java || echo "Java process not found"

echo ""
echo "================================"
echo "📝 If app is still starting, wait 30-60 seconds and try again"
echo "📝 If app failed to start, check the logs above for errors"
