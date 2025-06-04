#!/bin/bash

# Quick update script - chỉ pull code và restart
set -e

APP_DIR="/opt/recruitment"
APP_NAME="recruitment-app"
PID_FILE="/tmp/${APP_NAME}.pid"

echo "🔄 Quick update and restart..."

cd ${APP_DIR}

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin main

# Stop app
if [ -f ${PID_FILE} ]; then
    PID=$(cat ${PID_FILE})
    if ps -p $PID > /dev/null 2>&1; then
        echo "⏹️  Stopping app..."
        kill $PID
        sleep 3
    fi
    rm -f ${PID_FILE}
fi

# Build and start
echo "🔨 Building..."
./mvnw clean package -DskipTests -q

echo "🚀 Starting app..."
nohup java -jar \
    -Dspring.profiles.active=prod \
    -Xms512m \
    -Xmx1024m \
    target/landing-page-0.0.1-SNAPSHOT.jar \
    > /var/log/recruitment/app.log 2>&1 &

echo $! > ${PID_FILE}

echo "✅ Update completed! PID: $(cat ${PID_FILE})"
echo "🔍 Logs: tail -f /var/log/recruitment/app.log"
