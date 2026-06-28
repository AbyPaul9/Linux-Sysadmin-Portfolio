# 12 - Systemd Service Customization and Management 

## TechBridge Solutions had an internal disk monitoring script that was beign run manually by a developer whenever they remembered to. This manual process has already caused a them to miss a near-full disk incident. The IT manager requested the script be converted into a proper background service, starting on boot, restarting automatically on failure, and running continuosly rather than as a scheduled cron job.

## Environment 
- OS: Red Hat Enterprise Linux 10(x86_64)
- Virtualization: Oracle VirtualBox
- Server: server1.techbridge.local (192.168.56.10)
- Role: Custom systemd service for continuos disk usage monitoring 

## Tasks Completed
- Wrote bash script checking disk usage every 60 seconds, logging a warning when usage exceeds 80%
- Moved script to /usr/local/bin for standard system service placement
- Created custom systemd unit file disk-monitor.service
- Configured automatic restart on failure 
- Configured service to run as non-root user ops.mike
- Enabled service to start automatically on boot 
- Started service and verified continuos running with no errors 

## Commands Used
### 1. Disk Monitoring Script
- Created disk_usage.sh, it loops every 60 seconds checking df -h / output, logs warning to /var/log/disk-monitor.log when usgae exceeds threshold. Tested with lowered threshold to confirm logging works before setting to production value of 80%.

### 2. Moved Script to SystemLocation
- cp disk_usage.sh /usr/local/bin, chmod +x /usr/local/bin/disk_usage.sh

### 3. Systemd Unit File Creation
- Created /etc/systemd/system/disk-monitor.service with [Unit], [Service], and [Install] sections as seen in the script

### 4. Enabled & Started Services 
- systemctl daemon-reload
- systemctl enable --now disk-monitor.service

### 5. Verification
- journalctl -u disk-monitor.service confirmed clean start up with no errors
- systemctl status disk-monitor.service

## Key Concepts
- Systemd unit file give systemd full lifecycle control over a script (start, stop, restart and automatic recovery) turning a manually run script into a managed system service 
- The three core sections of a unit file each answer a different question [Unit]describes the service, [Service] defines how it runs, and [Install] defines when it activates
- A continuosly looping service is more appropriate than a cron job  when the task needs sub-minute precision or persistent process state.

## Lessons Learned 
- The script must be moved to a standard system path like /usr/local/bin rather than left in a user's home directory. This keeps systemd service definitions stable and independent of any one's user environment
- journalctl -u servicename is the fastest way to confirm a systemd service started cleanly without checking through generic system logs   

