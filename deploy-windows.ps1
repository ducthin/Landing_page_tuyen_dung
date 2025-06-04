# WELL CENTER Deployment Script for Windows PowerShell

$VPS_IP = "14.225.207.250"
$VPS_USER = "root"

Write-Host "🚀 WELL CENTER - VPS Deployment Script" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Step 1: Build application
Write-Host "📦 Building application..." -ForegroundColor Yellow
try {
    & .\mvnw.cmd clean package -DskipTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Application built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error building application: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Create deployment package
Write-Host "📦 Creating deployment package..." -ForegroundColor Yellow
$files = @(
    "Dockerfile",
    "docker-compose.yml", 
    "nginx.conf",
    "pom.xml",
    "mvnw",
    "mvnw.cmd",
    ".mvn",
    "src",
    ".env.example"
)

# Check if tar is available (Windows 10 build 17063+)
try {
    tar -czf deployment.tar.gz @files --exclude='target' --exclude='*.log'
    Write-Host "✅ Deployment package created!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creating package. Please install tar or use WSL." -ForegroundColor Red
    exit 1
}

# Step 3: Upload to VPS
Write-Host "📤 Uploading to VPS..." -ForegroundColor Yellow
try {
    scp deployment.tar.gz ${VPS_USER}@${VPS_IP}:/tmp/
    Write-Host "✅ Files uploaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Upload failed. Check SSH connection." -ForegroundColor Red
    exit 1
}

# Step 4: Deploy on VPS
Write-Host "🔧 Deploying on VPS..." -ForegroundColor Yellow
$deployScript = @"
# Create deployment directory
mkdir -p /opt/wellcenter
cd /opt/wellcenter

# Extract files
tar -xzf /tmp/deployment.tar.gz

# Create .env file if not exists
if [ ! -f .env ]; then
    cp .env.example .env
    echo 'Please update .env file with your configuration'
fi

# Install Docker if needed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
fi

# Install Docker Compose if needed
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Deploy application
docker-compose down 2>/dev/null || true
docker-compose up --build -d

# Show status
echo '================================'
echo 'Deployment Status:'
echo '================================'
docker-compose ps
echo '================================'
echo 'Application URL: http://14.225.207.250'
echo 'Admin URL: http://14.225.207.250/admin/dashboard'
echo 'Logs: docker-compose logs -f app'
echo '================================'
"@

try {
    $deployScript | ssh ${VPS_USER}@${VPS_IP}
    Write-Host "✅ Deployment completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}

# Cleanup
Remove-Item deployment.tar.gz -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Application URL: http://14.225.207.250" -ForegroundColor Cyan
Write-Host "👨‍💼 Admin Dashboard: http://14.225.207.250/admin/dashboard" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "1. Update .env file on VPS with your email credentials"
Write-Host "2. Setup SSL certificate (optional)"
Write-Host "3. Configure domain name (optional)"
Write-Host ""
Write-Host "🔧 Useful commands:" -ForegroundColor Yellow
Write-Host "- Check logs: ssh root@14.225.207.250 'cd /opt/wellcenter && docker-compose logs -f app'"
Write-Host "- Restart app: ssh root@14.225.207.250 'cd /opt/wellcenter && docker-compose restart app'"
