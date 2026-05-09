# 01 - Enterprise Linux Server Initial Setup

## Scenario:TechBridge Solutions provided a RHEL server for their development team. Before deployment, the IT infrastructure team required a hardened baseline confiuration which covers System Identity, Time Synchronization, Resource Limits, Security Warnings, and Kernel-Level Tuning.

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox 
- Hostname: server1.techbridge.local
- IP Address: 192.168.56.10
- Role: Primary Application Server

## Tasks Completed
- Configured system hostname following enterprise FQDN naming convention
- Set system timezone to WAT for accurate log timestamping
- Verified NTP synchronization via chrony for time consistency across infrastructure
- Enforced system wide resource limits through PAM limits to prevent resource exhaustion
- Deployed a legal Warning banner through message of the day (MOTD) for compliance and unauthorized access prohibition
- Hardened Kernel Parameters through sysctl for network security and performance optimization.

## Commands Used

### 1. Hostname Configuration
- hostnamectl set-hostname server1.techbridge.local
- verification: hostname
- output: server1.techbridge.local

### 2. Timezone Configuration
- timedatectl set-timezone Africa/Lagos
- verification:timedatectl
- output:  Local time: Sat 2026-05-02 14:39:19 WAT
           Universal time: Sat 2026-05-02 13:39:19 UTC
                 RTC time: Sat 2026-05-02 13:39:19
                Time zone: Africa/Lagos (WAT, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no

### 3. NTP/Chrony
- systemctl status chronyd(chronyd was already active)
- verification: chronyc tracking
- output: 
Reference ID    : 66CD2C10 (102.205.44.16)
Stratum         : 3
Ref time (UTC)  : Sat May 02 13:20:37 2026
System time     : 0.007296243 seconds slow of NTP time
Last offset     : -0.013986940 seconds
RMS offset      : 0.008335701 seconds
Frequency       : 8.771 ppm fast
Residual freq   : -0.474 ppm
Skew            : 9.638 ppm
Root delay      : 0.274973959 seconds
Root dispersion : 0.029148791 seconds
Update interval : 521.5 seconds
Leap status     : Normal

### 4. System ulimits
- File Edited: /etc/security/limits.conf
- Settings Added: 
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
* soft core 0
* hard core 0
- Reasons:
- nofile(Soft & Hard): A fintech application server handles thousands of TCP connections, database file descriptors, and log files handled concurrently. The default soft limit of 1024 is insufficient for production workloads. 65536(2^16) provides adequate headroom for high-concurrency applications while remaining within safe bounds to prevent file descriptor exhaustion.

- nproc(Soft & Hard): This limit the number of processes a single user can spawn. Set conservatively at 4096 to mitigate fork bomb attack where a malicious or compromised user spawns unlimited child processes, exhausting the process table and rendering the server unresponsive.

- core(Soft & Hard): Core dump files contain full memory snapshots of crashed processes. In a financial services environment,this is a critical security risk as memory may contain encryption keys, session tokens, plain text credentials, or customer account data. Setting core to '0' disables core dump generation in compliance with financial data security policies.

### 5. MOTD
- File Edited: /etc/motd
###############################################################
#      Welcome To TechBridge Solutions                        #
#      Authorized Users Only                                  #
#                                                             #
#      Server  : server1.techbridge.local                     #
#      Purpose : Production Application Server                #
#      Owner   : IT Infrastructure Team                       #
#                                                             #
#  WARNING  : Unauthorized access is strictly prohibited.     #
#  All activities on this system are monitored and logged     #
#  Violators will be prosecuted according to the law          #
#                                                             #
# Contact: itsupport@techbridge.com                           #
###############################################################
- Reasons:
It includes server identity, purpose and IT contact information. Administrators logging into multiple servers know the exact server they are on and who to contact for escalations. 
It also displays an unauthorized access warning, which establishes a legal notice

### 6. Kernel Parameters
- File Edited: /etc/sysctl.d/99-techbridge.conf
- Parameters & Values: 
net.ipv4.ip_forward=0
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.accept_redirects=0
kernel.randomize_va_space=2
fs.file-max=100000
net.core.somaxconn=4096

- Reasons:
- net.ipv4.ip_forward=0 Disables IP forwarding between network interface. The server is an application server not a router, enabling this would allow it to forward packets between networks which is a security risk

- net.ipv4.tcp_syncookies=1 Enables SYN cookie protection against SYN flood attacks. This is critical for fintech servers exposed to internet-facing traffic

- net.ipv4.conf.all.accept_redirects=0 Disables acceptance of ICMP redirect messages.

- kernel.randomize_va_space=2 Enables full address space layout randomization. Randomizes memory addresses of stack, heap, and libraries on every process execution, making it significantly harder for attackers to exploit memory corruption vulnerabilities like buffer overflow.

- fs.file-max=100000 Sets the system-wide maximum number of open file descriptors across all processes. The value 100000 supports high concurrency fintech workloads without risking system-wide file descriptor exhaustion.

- net.core.somaxconn=4096 Sets the maximum length of the incoming connection queue for network sockets. 4096 ensures connection requests are queued rather than dropped during traffic spikes.

## Key Concepts Learned
- ulimits protect shared infrastructure from resource exhaustion by individual users or processes
- sysctl exposes kernel tunables that controls network stack behaviour, memory layout and file system limits
- soft limits warn users while hard limits enforce absolute ceilings
- kernel address space randomization mitigates memory exploitation attacks

## Lessons Learned
- Git push failed through https because GitHub no longer supports password authentication. This was resolved by switching to SSH-key based authentication
- Empty directories cannot be tracked by git. This was resolved by adding .gitkeep placeholder files before committing
- sysctl changes must be applied with -p flag to take effect immediately without needing to reboot
- A typo in a sysctl parameter name causes the entire apply command to fail 
