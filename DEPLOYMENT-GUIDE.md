# WELL CENTER - VPS Deployment Guide

## 📋 Prerequisites
- VPS: 14.225.207.250 (2GB RAM, 40GB Disk)
- OS: Debian 10 (buster)
- SSH access as root

## 🚀 Step-by-Step Deployment

### Step 1: Setup VPS Environment
```bash
# Run on VPS
ssh root@14.225.207.250

# Copy and run setup script
wget https://raw.githubusercontent.com/your-repo/setup-vps.sh
chmod +x setup-vps.sh
./setup-vps.sh
```

### Step 2: Build Application Locally
```bash
# Run on your local machine
cd d:\Code\Job

# Build JAR file
./mvnw clean package -DskipTests

# Verify build
ls -la target/landing-page-*.jar
```

### Step 3: Deploy to VPS

#### Option A: Automatic Deploy (Recommended)
```bash
# Make deploy script executable
chmod +x deploy-to-vps.sh

# Run deployment
./deploy-to-vps.sh
```

#### Option B: Manual Deploy
```bash
# 1. Create deployment package
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

# 2. Upload to VPS
scp deployment.tar.gz root@14.225.207.250:/opt/wellcenter/

# 3. SSH to VPS and deploy
ssh root@14.225.207.250
cd /opt/wellcenter
tar -xzf deployment.tar.gz

# 4. Create environment file
cp .env.example .env
nano .env  # Update with your values

# 5. Deploy with Docker
docker-compose down
docker-compose up --build -d
```

### Step 4: Verify Deployment
```bash
# Check containers status
docker-compose ps

# Check application logs
docker-compose logs -f app

# Check if app is running
curl http://14.225.207.250:8080

# Check database connection
docker-compose exec mysql mysql -u recruitment_user -p recruitment_db
```

### Step 5: Access Application
- **Main Application**: http://14.225.207.250
- **Admin Dashboard**: http://14.225.207.250/admin/dashboard
- **Health Check**: http://14.225.207.250:8080/actuator/health

## 🔧 Useful Commands

### Docker Management
```bash
# View logs
docker-compose logs -f app
docker-compose logs -f mysql

# Restart application
docker-compose restart app

# Update application
docker-compose down
docker-compose up --build -d

# Database backup
docker-compose exec mysql mysqldump -u root -p recruitment_db > backup.sql

# Database restore
docker-compose exec -T mysql mysql -u root -p recruitment_db < backup.sql
```

### System Management
```bash
# Check system resources
htop
df -h
free -h

# Check network
netstat -tulpn
ufw status

# Service management
systemctl status wellcenter
systemctl start wellcenter
systemctl stop wellcenter
```

## 🔒 Security Checklist
- [ ] Change default passwords in .env
- [ ] Setup SSL certificate (Let's Encrypt)
- [ ] Configure firewall (UFW)
- [ ] Setup backup schedule
- [ ] Monitor disk usage
- [ ] Setup log rotation

## 🐛 Troubleshooting

### Application won't start
```bash
# Check logs
docker-compose logs app

# Check database connection
docker-compose logs mysql

# Restart everything
docker-compose down
docker-compose up -d
```

### Database issues
```bash
# Reset database
docker-compose down -v
docker-compose up -d
```

### Memory issues
```bash
# Check memory usage
free -h
docker stats

# Increase swap if needed
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## 📞 Support
If you encounter issues, check:
1. Docker logs: `docker-compose logs`
2. System resources: `htop`, `df -h`
3. Network connectivity: `ping google.com`
4. Service status: `systemctl status docker`
