#!/bin/bash

echo "=============================================="
echo "CHECKING APPLICATION STATUS"
echo "=============================================="
echo "Current time: $(date)"
echo ""

echo "1. DOCKER CONTAINER STATUS:"
echo "----------------------------"
docker-compose ps
echo ""

echo "2. CONTAINER HEALTH DETAILS:"
echo "----------------------------"
echo "MySQL Health:"
docker inspect recruitment_mysql --format='{{.State.Health.Status}}'
echo ""
echo "App Health:"
docker inspect recruitment_app --format='{{.State.Health.Status}}'
echo ""

echo "3. APPLICATION LOGS (last 20 lines):"
echo "------------------------------------"
docker-compose logs --tail=20 app
echo ""

echo "4. TESTING CONNECTIVITY:"
echo "------------------------"
echo "Testing app container internal health endpoint:"
docker exec recruitment_app curl -s http://localhost:8080/actuator/health || echo "Health endpoint not accessible"
echo ""

echo "Testing main application endpoint:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost/
echo ""

echo "Testing email endpoint:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost/test-email
echo ""

echo "5. PORT STATUS:"
echo "---------------"
netstat -tlnp | grep -E ":80|:443|:8080|:3306"
echo ""

echo "6. ENVIRONMENT VARIABLES IN APP CONTAINER:"
echo "------------------------------------------"
echo "Checking email configuration:"
docker exec recruitment_app printenv | grep -E "MAIL_|SPRING_MAIL"
echo ""

echo "=============================================="
echo "STATUS CHECK COMPLETE"
echo "=============================================="
