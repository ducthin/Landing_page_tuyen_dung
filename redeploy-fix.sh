#!/bin/bash

# Redeploy script to fix Docker image issue
echo "🔄 Redeploying with fixed Docker image..."

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found. Are you in the project directory?"
    exit 1
fi

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker-compose down --remove-orphans

# Remove the problematic image if it exists
echo "🗑️ Removing old images..."
docker image rm recruitment-landing-page-app:latest 2>/dev/null || true
docker image rm openjdk:17-jre-slim 2>/dev/null || true

# Pull latest changes from git
echo "📥 Pulling latest changes..."
git pull origin main

# Build and start with new image
echo "🚀 Building and starting services..."
docker-compose up --build -d

# Wait a bit for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check status
echo "📊 Checking service status..."
docker-compose ps

# Check logs
echo "📋 Recent logs:"
docker-compose logs --tail=20

# Test if application is accessible
echo "🔍 Testing application..."
if curl -f http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Application is running successfully!"
    echo "🌐 Access your application at: http://YOUR_SERVER_IP:8080"
else
    echo "⚠️ Application might still be starting. Check logs with: docker-compose logs -f"
fi

echo "🎉 Redeployment complete!"
