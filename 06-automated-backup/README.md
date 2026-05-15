# Title: 06 - Automated Backup & Restore Strategy

## Scenario: Techbridge Solutions had no formal backup strategy in place. During a recent incident, a developer accidentaly deleted critical application data and recovery took hours. The IT manager requested an automated backup solution for application data and logs, with timestamped archives, automatic cleanup of old backups, and a verified restore process.

## Environment:
- OS: Red Hat Enterprise Linux10 (x86_64)
- Virtualization: Oracle Virtual Box
- Server: server1.techbridge.local(192.168.56.10)
- Role: Automated bacckup and restore management on primary application server

## Tasks Completed
- Created dedicated backup directory at /backup/techbridge
- Wrote bash script to backup /mnt/app-data and /mnt/app-logs with daily timestamps
- Configured automatic cleanup of backups older than 7 days
- Made script executable and scheduled through cron to run daily at midnight 
- Tested script manually, confirmed both timestamped archives created successfully 
- Simulated restore from backup and verified data integrity

## Commands Used

### 1. Backup Directory Creation
- mkdir -p /backup/techbridge

### 2. Backup Script
- Created /usr/local/bin/techbridge-backup.sh
#!/bin/bash
#
DATE=$(date +%Y-%m-%d)
echo "Backup started on $DATE"
tar -czf /backup/techbridge/app-data-$DATE.tar.gz /mnt/app-data
tar -czf /backup/techbridge/app-logs-$DATE.tar.gz /mnt/app-logs
echo "Backup completed successfully"
find /backup/techbridge -name "*.tar.gz" -type f -mtime +7 -delete
echo "Cleanup done"

### 3. Make script executable
- chmod a+x /usr/local/bin/techbridge-backup.sh

### 4. Schedule through cron
- crontab -e
0 0 * * * /usr/local/bin/techbridge-backup.sh

### 5. Manual Test
- /usr/local/bin/techbridge-backup.sh
- ls -lh

### 6. Restore Simulation
- Created test file in /mnt/app-data, ran backup, extracted archive to /tmp

## Key Concepts
- Automated backups eliminate human error and ensure consistency. Manual backups are always skipped during busy periods.
- Timestamped filenames allow multiple backup versions to coexist and make point-in-time recovery possible
- Automatic cleanup through using the find -mtime prevents backup storage from growing, a common cause of disk exhaustion on production servers
- Cron is the standard Linux scheduler for recurring tasks. The pattern used means midnight every day
- Restore testing is as critical as backup creation. An untested backup cannot be tested in real disaster recovery scenario
- tar -czf creates compressed archives reducing storage usage; tar -xzf extractsthem for restore 

## Lesson Learned
- A space between = and $ in a bash variable assignment (DATE=$(date) causes the variable to be empty, bash requires no spaces around =in variable assignments
- The find command without -delete only lists matching files -delete must be explicitly added to actually remove them
- Backing up empty directories produces valid archives but restore verification requires actual data. Always create test files before validating a restore 
- tar warns "Removing leading / from member names" when archiving absolute paths. This is the expected behaviour ensuring safe extraction to any directory 
