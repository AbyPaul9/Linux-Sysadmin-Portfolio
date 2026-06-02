# 09 - Centralized Logging Server (rsyslog)

## Scenario: TechBridge Solutions' compliance team flagged servers logged independently with no central visibility. During a recent security incident, logs from a compromised server were deleted before they could be investigated. The IT manager requested all servers forward their logs to a central log server immediately to ensure infrastructure-wide visibilityand log survival even if an end-point is compromised

## Environment:
- OS: Red Hat Enterprise Linux 10(x86_64)
- Virtualization: Oracle virtualBox
- Server: server1.techbridge.local(192.168.56.10) - Central Log Receiver
- Client: client1.lab.local (192.168.56.20) - Log Sender
- KVM Host: kvmhost.lab.local(192.168.56.30) - Log Sender
- Role: Centralized log aggregator across all infrastructure nodes 

## Tasks Completed
- Enabled TCP input module on server1by uncommenting imtcpand port 514 in configuration file /etc/rsyslog.conf
- Created /var/log/remote/ directory to store incoming remote logs
- Added remote logs template to dynamically create per-host log files
- Opened port 514/tcp in firewalld on server1
- Configured client1 and kvmhost to forward all logs to server1 through TCP
- Restarted rsyslog on all VMs and verified port 514 listening on server1
- Generated test log entry on client1 and confirmed it appeared in /var/log/remote/client1.log on server1

## Commands Used 

### 1. Enable TCP input module on server1
- Edited /etc/rsyslog.conf(Uncommented module(load="imtcp") and input(type="imptcp" port="514)

### Create Remote Directory
- mkdir -p /var/log/remote

### Add Remote Log Templates
- $template, RemoteLogs,"/var/log/remote/%HOSTNAME%.log"
*.* ?RemoteLogs at the bottom of the config file

### Open Firewall Port
- firewall-cmd --add-port=514/tcp --permanent
- firewall-cmd --reload

### Configure client1 & kvmhost as log sender
- Added *.* @@192.168.56.10:514 to the both lines of the configuration files /etc/rsyslog.conf

### Restart & Verify
- systemctl restart rsyslogon all VMs, verified with ss -tlnp | grep 514 on server1

### Testing 
- logger -t TEST "TechBridge centralized logging test from client1"
- confirmed entry in /var/log/remote/client1.log on server1

## Key Concepts
- Centralized logging aggregates logs from all servers to one location. This enables infrastructure-wide visibility, faster incident response and log survival even if an end-point is compromised
- rsyslog uses input modules to receive logs. imtcp enables TCP-based log reception on port 514, preferred over UDP for guaranteed delivery in enterprise environments
- The template directive defines dynamic file paths(%HOSTNAME%) creates  seperate log file per semding host, making log management scalable across many servers 
- @@server:port in rsyslog config file means forward all logs over TCP. Single @ uses udp which has no delivery guarantee
- Port 514 is the standard rsyslog port. It must be opened in firewalld for remote log reception to work

## Lesson Learned
- Remote files are named after the sending hostname
- The RemoteLogs template and rule must both be present 
