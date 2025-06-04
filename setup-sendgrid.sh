#!/bin/bash

# Script để setup SendGrid SMTP

echo "📧 SETTING UP SENDGRID SMTP"
echo "==========================="

# Backup .env hiện tại
echo "1️⃣ Backing up current .env..."
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

echo "2️⃣ Please provide SendGrid details:"
echo ""

# Nhập thông tin SendGrid
read -p "Enter your SendGrid API Key: " SENDGRID_API_KEY
read -p "Enter your verified sender email (from SendGrid): " FROM_EMAIL
read -p "Enter admin email (to receive notifications): " ADMIN_EMAIL

# Validate inputs
if [ -z "$SENDGRID_API_KEY" ] || [ -z "$FROM_EMAIL" ] || [ -z "$ADMIN_EMAIL" ]; then
    echo "❌ Missing required information!"
    exit 1
fi

echo ""
echo "3️⃣ Updating .env with SendGrid configuration..."

# Update .env file
cat > .env << EOF
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=recruitment_db
DB_USERNAME=recruitment_user
DB_PASSWORD=StrongPassword123!

# SendGrid SMTP Configuration
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=$SENDGRID_API_KEY
MAIL_FROM=$FROM_EMAIL

# Admin Configuration
ADMIN_EMAIL=$ADMIN_EMAIL
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# Domain Configuration
DOMAIN_NAME=tuyendungwellcenter.com
USE_HTTPS=true

# SSL Configuration
SSL_EMAIL=$ADMIN_EMAIL
EOF

echo "✅ .env updated with SendGrid configuration"

echo ""
echo "4️⃣ Updating application-prod.properties..."

# Cập nhật application-prod.properties để sử dụng environment variables
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

# SendGrid SMTP configuration
spring.mail.host=${MAIL_HOST}
spring.mail.port=${MAIL_PORT}
spring.mail.username=${MAIL_USERNAME}
spring.mail.password=${MAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
spring.mail.properties.mail.smtp.ssl.trust=${MAIL_HOST}

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

# Logging (remove in production)
logging.level.org.springframework.mail=INFO
logging.level.com.sun.mail=INFO
EOF

echo "✅ application-prod.properties updated"

echo ""
echo "5️⃣ Rebuilding and restarting containers..."

# Stop containers
docker-compose down

# Fix permissions
chmod +x mvnw mvnw.cmd

# Rebuild with no cache
docker-compose build --no-cache app

# Start containers
docker-compose up -d

echo ""
echo "6️⃣ Waiting for containers to be ready..."
sleep 15

echo ""
echo "7️⃣ Testing SendGrid email..."
curl -s https://tuyendungwellcenter.com/test-email

echo ""
echo ""
echo "🎉 SENDGRID SETUP COMPLETED!"
echo "=========================="
echo ""
echo "📧 Configuration:"
echo "   SMTP Host: smtp.sendgrid.net"
echo "   SMTP Port: 587"  
echo "   From Email: $FROM_EMAIL"
echo "   Admin Email: $ADMIN_EMAIL"
echo ""
echo "🧪 Test email endpoint:"
echo "   https://tuyendungwellcenter.com/test-email"
echo ""
echo "📊 Check email config:"
echo "   https://tuyendungwellcenter.com/email-config"
echo ""
echo "💡 SendGrid Dashboard:"
echo "   https://app.sendgrid.com/stats"
echo ""
echo "⚠️  Important:"
echo "   - Verify your sender email in SendGrid dashboard"
echo "   - Check spam folder for test emails"
echo "   - Monitor SendGrid sending statistics"
EOF
