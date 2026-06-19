# 11 - Podman Rootless Container Stack

## Scenario
- TechBridge Solutions wanted to modernize their application deployment. The IT manager requested deploying their internal web applications using containers without root access, fully isolated, and able to start automatically on boot like any other system service , using podman integrated with systemd.

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox
- Server: server1.techbridge.local (192.168.56.10)
- Role: Rootless container deployment with systemd service integration

## Tasks Completed
- Installed Podman and and container-tools on server1
- Pulled Nginx image from docker hub
- Ran rootless Nginx container as a regular user ops.mike (no root priviledges)
- Mapped container portt 80 to host port 8082
- Generated systemd unit file using podman generate systemd 
- Enabled container service under systemd user session with lingering enabled for boot persistence 
- Verified container running and accessible via curl

## Commands Used

### 1. Podman Installation
- dnf install -y container-tools

### 2. Image Pull
- podman pull docker.io/library/nginx as user ops.mike

### 3. Run Rootless Container
- podman run -d techbridge-nginx -p 8082:80 docker.io/library/nginx

### 4. Generate Systemd Unit File
- mkdir ~/.config/systemd/user
- cd ~/.config/systemd/user
- podman generate systemd --name techbridge-nginx --new --files

### 5. Enable Systemd Service
- Exported XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS
- export XDG_RUNTIME_DIR=/run/user/$(id -u)
- export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
- systemctl --user daemon-reload
- systemctl --user enable --now container-techbridge-nginx.service
- systemctl --user status container-techbridge-nginx.service

### 6. Boot Persistence
- loginctl enable-linger ops.mike

### 7. Testing 
- curl http://localhost:8082

## Key Concepts
- Rootless containers run entirely under a regular user's namespace. This eliminates the security risk of a compromised container gaining root access to the host
- Podman has no central daemon unlike docker, each container is a direct child process, reducing attack surface
- Podman generate systemd creates a unit file that allows a container to be managed exactly like any other systemd service(start, stop, restart, enable on boot)
- loginctl enable-linger is required for rootless systemd user services to persist after the user logs out or the system reboots, without it the sontainer stopsthe moment the session ends

## Lessons Learned 
- Official Nginx container images failed to start(exit code 127) on this RHEL 10 install due to a SELinux policy enforcement issue. This was resolved by temporarily setting setenforce 0 
- systemctl --user commands fail with a DBUS connection error when run inside an an su session. I manually export XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS to establish the user systemd bus connection
- podman generate systemd is now deprecated in favor of Quadlets (podman-systemd.unit), still functional and widely used in production
- podman ps only shows running containers while podman ps -a is required to see stopped or exited containers, important for debugging exit codes.  
