#!/bin/bash

# Deploy script for recruitment application
APP_NAME="recruitment-landing-page"
APP_VERSION="0.0.1-SNAPSHOT"
JAR_FILE="landing-page-${APP_VERSION}.jar"
APP_HOME="/opt/recruitment"
LOG_DIR="/var/log/recruitment"
PID_FILE="${APP_HOME}/${APP_NAME}.pid"

# Create directories
sudo mkdir -p ${APP_HOME}
sudo mkdir -p ${LOG_DIR}

# Stop existing application
if [ -f ${PID_FILE} ]; then
    PID=$(cat ${PID_FILE})
    if ps -p $PID > /dev/null; then
        echo "Stopping application (PID: $PID)..."
        kill $PID
        sleep 5
        if ps -p $PID > /dev/null; then
            echo "Force killing application..."
            kill -9 $PID
        fi
    fi
    rm -f ${PID_FILE}
fi

# Copy new jar file
echo "Copying new application..."
sudo cp target/${JAR_FILE} ${APP_HOME}/

# Set permissions
sudo chown -R $(whoami):$(whoami) ${APP_HOME}
sudo chown -R $(whoami):$(whoami) ${LOG_DIR}

# Start application
echo "Starting application..."
cd ${APP_HOME}
nohup java -jar \
    -Dspring.profiles.active=prod \
    -Xms512m \
    -Xmx1024m \
    -Dserver.port=8080 \
    ${JAR_FILE} \
    > ${LOG_DIR}/app.log 2>&1 &

# Save PID
echo $! > ${PID_FILE}

echo "Application started with PID: $(cat ${PID_FILE})"
echo "Logs available at: ${LOG_DIR}/app.log"
echo "Application should be available at: http://your-server-ip:8080"
