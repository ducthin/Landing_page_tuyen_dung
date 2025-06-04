#!/bin/bash

echo "=== TESTING GMAIL SMTP CONFIGURATION ==="

# Stop containers
echo "1. Stopping containers..."
docker-compose down

# Rebuild app container to pick up new config
echo "2. Rebuilding app container..."
docker-compose build app

# Start containers
echo "3. Starting containers..."
docker-compose up -d

# Wait for containers to be ready
echo "4. Waiting for containers to start..."
sleep 30

# Check container status
echo "5. Container status:"
docker-compose ps

# Check app logs for email configuration
echo "6. Checking app logs for email config..."
docker-compose logs app | grep -i mail

# Test email endpoint
echo "7. Testing email endpoint..."
sleep 10
echo "Testing /test-email endpoint..."
curl -X POST http://localhost:8080/test-email \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=ducthinh123b@gmail.com"

echo ""
echo "=== EMAIL TEST COMPLETED ==="
echo "Check the app logs with: docker-compose logs app"
echo "Check if email was sent to: ducthinh123b@gmail.com"
