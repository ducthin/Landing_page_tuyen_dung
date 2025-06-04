#!/bin/bash

# VPS Setup Script
# Run this on your VPS server

echo "🔧 Setting up VPS for WELL CENTER Recruitment App..."

# Update system
echo "📦 Updating system packages..."
apt-get update && apt-get upgrade -y

# Install essential tools
apt-get install -y curl wget vim git htop net-tools

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed successfully"
else
    echo "✅ Docker Compose already installed"
fi

# Create directories
echo "📁 Creating application directories..."
mkdir -p /opt/wellcenter
mkdir -p /var/log/wellcenter
mkdir -p /opt/wellcenter/ssl

# Setup firewall
echo "🔥 Configuring firewall..."
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw --force enable

# Create systemd service for auto-start
echo "⚙️ Creating systemd service..."
cat > /etc/systemd/system/wellcenter.service << 'EOF'
[Unit]
Description=WELL CENTER Recruitment Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/wellcenter
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable wellcenter.service

# Show system info
echo "📊 System Information:"
echo "=========================="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "=========================="

echo "✅ VPS setup completed!"
echo "🚀 Ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Run deploy-to-vps.sh from your local machine"
echo "2. Or manually copy your application files to /opt/wellcenter"
echo "3. Navigate to /opt/wellcenter and run: docker-compose up -d"
