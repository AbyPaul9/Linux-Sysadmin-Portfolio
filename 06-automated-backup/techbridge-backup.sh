#!/bin/bash
#
DATE=$(date +%Y-%m-%d)
echo "Backup started on $DATE"
tar -czf /backup/techbridge/app-data-$DATE.tar.gz /mnt/app-data
tar -czf /backup/techbridge/app-logs-$DATE.tar.gz /mnt/app-logs
echo "Backup completed successfully"
find /backup/techbridge -name "*.tar.gz" -type f -mtime +7 -delete
echo "Cleanup done"
