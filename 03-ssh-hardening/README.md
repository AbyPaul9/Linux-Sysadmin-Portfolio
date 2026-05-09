# SSH Hardening & Secure Remote Access

## Scenario: TechBridge Solutions security audit flagged the SSH configuration on server1 as a critical vulnerability. The IT infrastructure team was tasked with hardening SSH to meet security standards.

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox
- Server: server1.techbridge.local (192.168.56.10)[SSH server being hardened]
- Client: client1.techbridge.local(192.168.56.20)[Used to test key based authentication]
- Role: Secure remote configuration across two nodes 

## Tasks Completed
- Disabled Root Login through SSH
- Disabled password authentication and enforced key-based authentication only
- Changed default SSH port from port 22 to port 2222
- Restricted SSH access to devops users only
- Configured idle session timeout
- Generated SSH key-pairs on client1 and tested successful key-based login to server1
- Opened port 2222 in firewalld and added SELinux port context for sshd

## Commands Used
### 1. Disable Root Login
- File Edited: /etc/ssh/sshd_config
- PermitRootLogin no
- Verification: grep PermitRootLogin /etc/ssh/sshd_config
- Output: PermitRootLogin no

### 2. Disable Password Authentication 
- File Edited: /etc/ssh/sshd_config
- PasswordAuthentication no
- Temporarily re-enabled to allow ssh-copy-id, then disabled again after keys were copied

### 3. Change default SSH port
- set port to 2222 in /etc/ssh/sshd_config
- semanage port -a -t ssh_port_t -p tcp 2222
- firewall-cmd --add-port=2222/tcp --permanent
- firewall-cmd --reload

### 4. Restrict SSH access to specific users
- File Edited: /etc/ssh/sshd_config
- AllowUsers ops.mike ops.linda

### 5. Set Idle Timeout
- File Edited: /etc/ssh/sshd_config
- ClientAliveInterval 60
- ClientAliveCountMax 3

### 6. Generate SSH Keys and Test Key-Based Login
- ssh-keygen to generate keypair on client1
- ssh-copy-id -p 2222 ops.mike@192.168.56.10
- ssh-copy-id -p 2222 ops.linda@192.168.56.10
- ssh -p 2222 ops.mike@192.168.56.10 to test login
- MOTD banner confirmed on successful login

## Key Concepts
- Disabling root SSH login forces administrators to use named accounts, creating a full audit trail of who did what on the server
- Key-Based authentication is significantly more secured than passwords. Private keys cannot be brute-forced remotely.
- Changing the default port reduces automated port scanning and attacks targetting port 22
- SELinux enforces port access at the kernel level, even if firewalld allows a port, SELinux must also permit the service to bind it 
- ClientAliveInterval and ClientAliveCountMax work together to terminate idle sessions, reducing the risks of abandoned opened sessions being exploited
- ssh-copy-id requires password authentication to deliver the public key.

## Lesson Learned
- Disabling PasswordAuthentication before copying SSH keys creates a lockout situation(Always copy keys first then disable afterwards)
- SELinux blocked sshd from binding to port 2222 even after firewalld was configured. both layers must be updated when changing service ports
- ssh-copy-id fails silently with permission denied when the target user has no password set. Always set user passwords before attempting key distribution. 
