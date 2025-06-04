#!/bin/bash

# Auto deploy script cho recruitment app
set -e

echo "🚀 Starting deployment..."

# Configuration
APP_DIR="/opt/recruitment"
APP_NAME="recruitment-app"
JAR_FILE="landing-page-0.0.1-SNAPSHOT.jar"
LOG_DIR="/var/log/recruitment"
PID_FILE="/tmp/${APP_NAME}.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create directories
log_info "Creating directories..."
sudo mkdir -p ${LOG_DIR}
sudo chown $USER:$USER ${LOG_DIR}

# Navigate to app directory
cd ${APP_DIR}

# Pull latest code
log_info "Pulling latest code from Git..."
git pull origin main

# Stop existing application
if [ -f ${PID_FILE} ]; then
    PID=$(cat ${PID_FILE})
    if ps -p $PID > /dev/null 2>&1; then
        log_warn "Stopping existing application (PID: $PID)..."
        kill $PID
        sleep 5
        
        # Force kill if still running
        if ps -p $PID > /dev/null 2>&1; then
            log_warn "Force killing application..."
            kill -9 $PID
        fi
    fi
    rm -f ${PID_FILE}
fi

# Build application
log_info "Building application..."
./mvnw clean package -DskipTests -q

# Check if JAR file exists
if [ ! -f "target/${JAR_FILE}" ]; then
    log_error "JAR file not found: target/${JAR_FILE}"
    exit 1
fi

# Start application
log_info "Starting application..."
nohup java -jar \
    -Dspring.profiles.active=prod \
    -Xms512m \
    -Xmx1024m \
    -Dserver.port=8080 \
    -Dfile.encoding=UTF-8 \
    target/${JAR_FILE} \
    > ${LOG_DIR}/app.log 2>&1 &

# Save PID
APP_PID=$!
echo $APP_PID > ${PID_FILE}

# Wait a bit and check if app started successfully
sleep 10

if ps -p $APP_PID > /dev/null 2>&1; then
    log_info "✅ Application started successfully!"
    log_info "   PID: $APP_PID"
    log_info "   Logs: ${LOG_DIR}/app.log"
    log_info "   URL: http://localhost:8080"
    
    # Show last few log lines
    log_info "Recent logs:"
    tail -n 10 ${LOG_DIR}/app.log
else
    log_error "❌ Failed to start application"
    log_error "Check logs: ${LOG_DIR}/app.log"
    exit 1
fi

log_info "🎉 Deployment completed successfully!"
