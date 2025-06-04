#!/bin/bash

# Script để test ứng dụng Spring Boot chạy trực tiếp trên VPS (không qua Docker)
# Mục đích: Kiểm tra xem Gmail SMTP có hoạt động khi chạy native không

set -e

echo "🚀 TESTING SPRING BOOT APP DIRECTLY ON VPS"
echo "========================================="

# Kiểm tra Java
echo "1️⃣ Checking Java installation..."
if ! command -v java &> /dev/null; then
    echo "❌ Java not found! Installing OpenJDK 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
else
    echo "✅ Java version: $(java -version 2>&1 | head -n 1)"
fi

# Kiểm tra Maven
echo "2️⃣ Checking Maven installation..."
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven not found! Installing Maven..."
    sudo apt update
    sudo apt install -y maven
else
    echo "✅ Maven version: $(mvn -version | head -n 1)"
fi

# Dừng containers để tránh xung đột port
echo "3️⃣ Stopping Docker containers to avoid port conflicts..."
docker-compose down || echo "⚠️ No containers to stop"

# Load environment variables
echo "4️⃣ Loading environment variables from .env..."
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "✅ Environment variables loaded"
    echo "   - DB_HOST: $DB_HOST"
    echo "   - DB_NAME: $DB_NAME"
    echo "   - DB_USERNAME: $DB_USERNAME"
    echo "   - MAIL_USERNAME: $MAIL_USERNAME"
    echo "   - ADMIN_EMAIL: $ADMIN_EMAIL"
else
    echo "❌ .env file not found!"
    exit 1
fi

# Kiểm tra MySQL đang chạy
echo "5️⃣ Checking MySQL availability..."
if ! command -v mysql &> /dev/null; then
    echo "⚠️ MySQL client not installed. Installing..."
    sudo apt update
    sudo apt install -y mysql-client
fi

# Test kết nối MySQL
echo "   Testing MySQL connection..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1;" || {
    echo "❌ Cannot connect to MySQL. Starting MySQL container..."
    docker-compose up -d mysql
    echo "   Waiting for MySQL to be ready..."
    sleep 30
}

# Build ứng dụng
echo "6️⃣ Building the application..."
./mvnw clean package -DskipTests

# Kiểm tra JAR file
JAR_FILE="target/landing-page-0.0.1-SNAPSHOT.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR file not found: $JAR_FILE"
    exit 1
fi
echo "✅ JAR file created: $JAR_FILE"

# Tạo file application.properties tạm thời với config production
echo "7️⃣ Creating temporary application.properties..."
cat > /tmp/app-direct-test.properties << EOF
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

# Gmail SMTP configuration
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=${MAIL_USERNAME}
spring.mail.password=${MAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
spring.mail.properties.mail.smtp.ssl.trust=smtp.gmail.com

# Debug email (temporary)
logging.level.org.springframework.mail=DEBUG
logging.level.com.sun.mail=DEBUG

# Admin configuration
app.admin.email=${ADMIN_EMAIL}
app.admin.username=${ADMIN_USERNAME}
app.admin.password=${ADMIN_PASSWORD}

# File upload
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
app.upload.dir=uploads
EOF

echo "✅ Temporary config file created"

# Chạy ứng dụng
echo "8️⃣ Starting Spring Boot application directly..."
echo "   Application will run on: http://localhost:8080"
echo "   Test email endpoint: http://localhost:8080/test-email"
echo "   Email config endpoint: http://localhost:8080/email-config"
echo ""
echo "⚠️  IMPORTANT: This will run in foreground. Press Ctrl+C to stop."
echo "   After starting, open another terminal and run:"
echo "   curl http://localhost:8080/test-email"
echo ""
echo "🔥 Starting application in 3 seconds..."
sleep 3

# Chạy với config tạm thời
java -jar "$JAR_FILE" --spring.config.location=file:/tmp/app-direct-test.properties

echo "✅ Application stopped"
