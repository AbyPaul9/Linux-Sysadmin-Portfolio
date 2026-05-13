# Title: 04 - Firewalld + SElLinux Hardening

## Scenario: A penetration test commisioned by TechBridge Solutions revealed that server1 had no proper firewall zones configured and SELinux was running in permissive mode. The security team escalated it as a critical finding requiring immediate remediation before the server could be cleared for production use handling finanacial transactions

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle Virtual Box
- Server: server1.techbridge.local (192.168.56.19)
- Client: client1.lab.local (192.168.56.20)
- Role: Firewall hardening and SELinux to enforcement on the primary application server 

## Tasks Completed 
- Verified and set SELinux to enforcing mode permanently through /etc/selinux/config
- Assigned host-only interface enp0s8 to the internal firewalld zone
- Opened only required services and ports(HTTP, HTTPS, and SSH on ports 2222)
- Added rich rule to block suspicious IP 192.168.56.99
- Added rich rule to rate-limit ssh connections to 3 per minute to prevent brute force attacks
- Verified all firewalld rules and confirmed SELinux enforcing status

## Commands Used
### 1. SELinux Configuration
- File Edited: /etc/selinux/config( set SELinux = enforcing)
- Verification: getenforce
- Output: Enforcing

### 2. Firewalld Assignment
- firewall-cmd --zone=internal --change-interface=enp0s8 --permanent
- Output: Success
- firewall-cmd --reload (to make it persistent)

### 3. Open required service port
- firewall-cmd --zone=internal --add-service=http --permanent
- firewall-cmd --zone=internal --add-service=https --permanent
- firewall-cmd --zone=internal --add-port=2222/tcp --permanent 
- Output: Success
- firewall-cmd --reload (to make it persistent)

### 4. Block suspicious IP - Added Rich Rule
- firewall-cmd --zone=internal --add-rich-rule='rule family="ipv4" source address="192.168.56.99" drop' --permanent
- Output: Success
- firewall-cmd --reload

### 5. Rate-Limit SSH - Added Rich Rule
- firewall-cmd --zone=internal --add-rich-rule='rule family="ipv4" service name="ssh" limit value="3/m" accept' --permanent
- Output: Success
- firewall-cmd --reload

### 6. General Verification
- firewall-cmd --zone=internal --list-all
- Output: internal (active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: enp0s8
  sources: 
  services: cockpit dhcpv6-client http https mdns samba-client ssh
  ports: 2222/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" service name="ssh" accept limit value="3/m"
	rule family="ipv4" source address="192.168.56.99" drop

## Key Concepts
- SELinux enforcing mode actively blocks policy violations rather than just logging them. Permissive mode provides no real protection and should not exist exist on a production server
- Firewalld zones define trust levels for network interfaces. Internal zone is appropriate for controlled lab and enterprise internal networks
- Rich rule extend firewalld beyond simple service allow/deny, enabling IP based blocking, rate limiting and logging. This is critical for fintech servers exposed to external threats
- Rate-limiting SSH connections at the firewall level stops bruteforce attacks before they reach the authentication layer
- Blocking suspicious IPs at firewall drops packet silently, attackers receives no response, giving no confirmation the server exists.
- Port 2222 must be explicitly added as a firewalld port since the built-in ssh service definition only definition references port 22

## Lessons Learned 
- Adding services to firewalld without specifying the zone applies them to default zone not the intended zone
- Firewalld rich rules are more powerful than standard service rules and should be the go-to for any IP specific or rate-based access control in enterprise environments 
- SELinux and firewalld are independent security layers, both must be correctly configured, one cannot compensate for the other.
