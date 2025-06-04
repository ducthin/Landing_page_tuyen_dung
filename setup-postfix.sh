#!/bin/bash

# Script để setup Postfix cho email local trên VPS

echo "📮 SETTING UP POSTFIX FOR LOCAL EMAIL"
echo "===================================="

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo)"
    exit 1
fi

echo "1️⃣ Installing Postfix..."

# Cài đặt Postfix với config tự động
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y postfix mailutils

echo "2️⃣ Configuring Postfix..."

# Backup config cũ
cp /etc/postfix/main.cf /etc/postfix/main.cf.backup.$(date +%Y%m%d_%H%M%S)

# Lấy hostname và domain
HOSTNAME=$(hostname)
DOMAIN_NAME="tuyendungwellcenter.com"
SERVER_IP=$(curl -s ifconfig.me)

# Tạo config Postfix
cat > /etc/postfix/main.cf << EOF
# Basic Postfix configuration for VPS
smtpd_banner = \$myhostname ESMTP \$mail_name
biff = no

# Hostname and domain
myhostname = $HOSTNAME
mydomain = $DOMAIN_NAME
myorigin = \$mydomain

# Network configuration
inet_interfaces = localhost
inet_protocols = ipv4

# Destination configuration
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain
relayhost = 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

# Mailbox configuration
home_mailbox = Maildir/
mailbox_size_limit = 0
recipient_delimiter = +

# Security
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
disable_vrfy_command = yes
smtpd_helo_required = yes

# Performance
default_process_limit = 100
smtpd_client_connection_count_limit = 50
smtpd_client_connection_rate_limit = 30

# Logging
maillog_file = /var/log/postfix.log
EOF

echo "3️⃣ Configuring aliases..."

# Tạo aliases cho admin
cat > /etc/aliases << EOF
postmaster: root
webmaster: root
abuse: root
root: admin@$DOMAIN_NAME
EOF

# Update aliases database
newaliases

echo "4️⃣ Starting and enabling Postfix..."

# Restart và enable Postfix
systemctl restart postfix
systemctl enable postfix

# Kiểm tra status
if systemctl is-active --quiet postfix; then
    echo "✅ Postfix is running"
else
    echo "❌ Postfix failed to start"
    systemctl status postfix
    exit 1
fi

echo "5️⃣ Testing Postfix configuration..."

# Test cấu hình
postfix check
if [ $? -eq 0 ]; then
    echo "✅ Postfix configuration is valid"
else
    echo "❌ Postfix configuration has errors"
    exit 1
fi

echo "6️⃣ Testing email sending..."

# Test gửi email
echo "Test email from Postfix on $(date)" | mail -s "Postfix Test Email" root

if [ $? -eq 0 ]; then
    echo "✅ Test email sent successfully"
else
    echo "❌ Failed to send test email"
fi

echo "7️⃣ Updating application configuration..."

# Backup .env
cp .env .env.backup.postfix.$(date +%Y%m%d_%H%M%S)

# Update .env cho Postfix
cat > .env << EOF
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=recruitment_db
DB_USERNAME=recruitment_user
DB_PASSWORD=StrongPassword123!

# Postfix SMTP Configuration (Local)
MAIL_HOST=localhost
MAIL_PORT=25
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_FROM=noreply@$DOMAIN_NAME

# Admin Configuration
ADMIN_EMAIL=admin@$DOMAIN_NAME
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# Domain Configuration
DOMAIN_NAME=$DOMAIN_NAME
USE_HTTPS=true

# SSL Configuration
SSL_EMAIL=admin@$DOMAIN_NAME
EOF

# Update application-prod.properties
cat > src/main/resources/application-prod.properties << 'EOF'
# Server configuration
server.port=8080
server.servlet.context-path=/

# Database configuration
spring.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

# Postfix SMTP configuration (Local)
spring.mail.host=${MAIL_HOST}
spring.mail.port=${MAIL_PORT}
# No authentication needed for localhost
spring.mail.properties.mail.smtp.auth=false
spring.mail.properties.mail.smtp.starttls.enable=false
spring.mail.properties.mail.smtp.ssl.enable=false

# Email sender configuration
spring.mail.from=${MAIL_FROM}

# Admin configuration
app.admin.email=${ADMIN_EMAIL}
app.admin.username=${ADMIN_USERNAME}
app.admin.password=${ADMIN_PASSWORD}

# File upload
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
app.upload.dir=uploads

# Logging
logging.level.org.springframework.mail=INFO
logging.level.com.sun.mail=INFO
EOF

echo "8️⃣ Rebuilding application..."

# Fix permissions
chmod +x mvnw mvnw.cmd

# Stop containers
docker-compose down

# Rebuild
docker-compose build --no-cache app

# Start containers
docker-compose up -d

echo "9️⃣ Waiting for application to start..."
sleep 15

echo "🔟 Testing application email..."

# Test email qua ứng dụng
curl -s https://tuyendungwellcenter.com/test-email

echo ""
echo ""
echo "🎉 POSTFIX SETUP COMPLETED!"
echo "=========================="
echo ""
echo "📮 Postfix Configuration:"
echo "   SMTP Host: localhost"
echo "   SMTP Port: 25"
echo "   Authentication: None (local)"
echo "   From Email: noreply@$DOMAIN_NAME"
echo ""
echo "🧪 Test Commands:"
echo "   # Test Postfix directly:"
echo "   echo 'Test email' | mail -s 'Test Subject' admin@$DOMAIN_NAME"
echo ""
echo "   # Test via application:"
echo "   curl https://tuyendungwellcenter.com/test-email"
echo ""
echo "📊 Monitor Postfix:"
echo "   # Check status:"
echo "   systemctl status postfix"
echo ""
echo "   # Check logs:"
echo "   tail -f /var/log/postfix.log"
echo "   tail -f /var/log/mail.log"
echo ""
echo "   # Check mail queue:"
echo "   postqueue -p"
echo ""
echo "⚠️  Important Notes:"
echo "   - Emails will be sent from: noreply@$DOMAIN_NAME"
echo "   - Make sure port 25 is not blocked by VPS provider"
echo "   - Some email providers may mark emails as spam"
echo "   - Consider setting up SPF/DKIM records for better delivery"
echo ""
echo "🔧 Troubleshooting:"
echo "   # If emails not delivered, check:"
echo "   tail -f /var/log/postfix.log"
echo "   postqueue -p"
echo "   postsuper -d ALL  # (to clear queue)"
EOF
