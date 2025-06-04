#!/bin/bash

# Script to restart containers with proper timing
echo "🔄 Restarting containers for recruitment application..."

# Stop all containers
echo "⏹️  Stopping all containers..."
docker-compose down

# Remove any orphaned containers
echo "🧹 Cleaning up..."
docker system prune -f

# Start MySQL first and wait for it to be healthy
echo "🗄️  Starting MySQL and waiting for it to be ready..."
docker-compose up -d mysql

# Wait for MySQL to be healthy
echo "⏳ Waiting for MySQL to be healthy..."
timeout=300  # 5 minutes timeout
elapsed=0
while [ $elapsed -lt $timeout ]; do
    if docker-compose ps mysql | grep -q "healthy"; then
        echo "✅ MySQL is healthy!"
        break
    fi
    echo "   MySQL status: $(docker-compose ps mysql | grep mysql | awk '{print $4}')"
    sleep 5
    elapsed=$((elapsed + 5))
done

if [ $elapsed -ge $timeout ]; then
    echo "❌ MySQL failed to become healthy within 5 minutes"
    echo "📋 MySQL logs:"
    docker-compose logs mysql --tail=20
    exit 1
fi

# Start the application
echo "🚀 Starting Spring Boot application..."
docker-compose up -d app

# Wait a bit for app to start
echo "⏳ Waiting for application to start..."
sleep 15

# Check app status
echo "📊 Application status:"
docker-compose logs app --tail=10

# Start nginx
echo "🌐 Starting nginx..."
docker-compose up -d nginx

echo "✅ All containers started!"
echo ""
echo "📋 Container status:"
docker-compose ps
echo ""
echo "🌐 You can now access the application at:"
echo "   http://$(curl -s ifconfig.me)/ (external)"
echo "   http://localhost/ (local)"
echo ""
echo "📝 To view logs:"
echo "   docker-compose logs app"
echo "   docker-compose logs mysql"
echo "   docker-compose logs nginx"
