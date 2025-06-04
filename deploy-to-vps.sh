#!/bin/bash

# VPS Deployment Script for WELL CENTER Recruitment App
# Run this script from your local machine

VPS_IP="14.225.207.250"
VPS_USER="root"
APP_NAME="wellcenter-recruitment"
DEPLOY_DIR="/opt/wellcenter"

echo "🚀 Starting deployment to VPS..."

# 1. Create deployment package
echo "📦 Creating deployment package..."
tar -czf deployment.tar.gz \
    Dockerfile \
    docker-compose.yml \
    nginx.conf \
    pom.xml \
    mvnw \
    mvnw.cmd \
    .mvn/ \
    src/ \
    --exclude='target/' \
    --exclude='*.log'

# 2. Copy files to VPS
echo "📤 Uploading files to VPS..."
scp deployment.tar.gz ${VPS_USER}@${VPS_IP}:/tmp/

# 3. Deploy on VPS
echo "🔧 Deploying on VPS..."
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
    # Update system
    apt-get update
    
    # Install Docker if not exists
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl start docker
        systemctl enable docker
    fi
    
    # Install Docker Compose if not exists
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Create deployment directory
    mkdir -p /opt/wellcenter
    cd /opt/wellcenter
    
    # Extract deployment package
    tar -xzf /tmp/deployment.tar.gz
    
    # Stop existing containers
    docker-compose down 2>/dev/null || true
    
    # Remove old images
    docker system prune -f
    
    # Build and start new containers
    docker-compose up --build -d
    
    # Show status
    docker-compose ps
    
    echo "✅ Deployment completed!"
    echo "🌐 Application will be available at: http://14.225.207.250"
    echo "📊 Check logs with: docker-compose logs -f app"
EOF

# 4. Clean up
rm deployment.tar.gz

echo "🎉 Deployment script completed!"
echo "🔗 Your application should be available at: http://14.225.207.250"
