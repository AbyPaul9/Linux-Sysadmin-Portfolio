# 10 - Apache/Nginx Web Server with Virtual Hosting

## Scenario: TechBridge Solutions was lauching two internal web applications, a developer portal and a Devops dashboard. The IT manager requested both websites running on the same server, with the developer portal served by Apache and the Devops dashboard served by Nginx acting as a reverse proxy in front of Apache. Both sites must be accessible by hostname.

## Environment 
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox
- Server: server1.techbridge.local (192.168.56.10)
- Client: client1.lab.local (192.168.56.20)

## Tasks Completed
- Installed Apache(httpd) and Nginx on server1
- Moved Apache from port 80 to port 8080 and 8081 to allow Nginx to take port 80
- Created two apache virtual hosts, dev.techbridge.local(8080) & devops.techbridge.local(8081)
- Created index.html for each site
- Configured Nginx as a reverse proxy forwarding requests to both Apache virtual hosts 
- Update /etc/hosts on both server1 and client1 for hostnames resolution
- Opened Http port in firewalld
- Tested both sides by hostname from client1 using curl

## Commands Used

### 1. Installation
- dnf install -y httpd
- dnf -y install nginx

### 2. Apache Port Configuration
- Edited /etc/httpd/conf/httpd.conf

### 3. Apache Virtual Host Configuration
- Created /etc/httpd/conf.d/dev.techbridge.local.conf and added the needed parameters
- Created /etc/httpd/conf.d/devops.techbridge.local.conf and added the neccessary parameters 

### 4. Create Site Content
- Used echo statements to create index.html in /var/www/dev and /var/www/devops

### 5. Nginx Reverse Proxy Configuration
- Created /etc/nginx/conf.d/techbridge.conf with 2 server blocks as in the config file

### 6. Hostname Resolution
- Added 192.168.56.10 dev.techbridge.local devops.techbridge.local using echo statements to /etc/hosts on both server1 and client1

### 7. Firewall Configuration
- firewall-cmd --add-service=http --permanent
- firewall-cmd --reload

### 8. Verification
- curl http://dev.techbridge.local
- curl http://devops.techbridge.local
- Both commands returned correct HTML content from client1

## Key Concepts:
- Virtual hosting allows one server to host multiple websites on the same IP, each sites has its own document root, server name, and log files 
- Nginx as a reverse proxy sits in between the client and Apache, clients connect to Nginx on port 80, Nginx forwards to the appropriate Apache virtual host based on the hostname

## Lesson Learned
- Nginx failed to start because Apache was already using port 80
- Apache requires Listen directives for each port it serves, adding a virtual host on a new port without corresponding Listen directive causes startup failure
- Both Nginx server blocks can listen on port 80 simultaneously. Nginx uses the server_name directive to route requests to the correct upstream
