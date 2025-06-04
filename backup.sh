#!/bin/bash

# Backup script for recruitment application
BACKUP_DIR="/backup/recruitment"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="recruitment_db"
DB_USER="recruitment_user"
DB_PASS="your_strong_password"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Backup database
mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BACKUP_DIR}/db_backup_${DATE}.sql

# Backup application files
tar -czf ${BACKUP_DIR}/app_backup_${DATE}.tar.gz /opt/recruitment

# Keep only last 7 days of backups
find ${BACKUP_DIR} -name "*.sql" -mtime +7 -delete
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: ${DATE}"
