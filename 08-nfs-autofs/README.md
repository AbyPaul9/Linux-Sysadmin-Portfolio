# 08 - Network File Sharing with NFS + Autofs

## Scenario: TechBridge Solutions needed a centralized file sharing solution for their development and operations teams. The IT manager requested shared storagethat mounts automatically when accessed, developers should have their own shareddirectory. DevOps should have theirs, and shares must mount on demand rather than at boot to avoid slowing down the system.

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox
- Server: server1.techbridge.local (192.168.56.10)
- Client: client1.lab.local(192.168.56.20)
- Role: Centralized network file sharing with on-demand automounting

## Tasks Completed
- Installed and configured NFS server on server1
- Created shared directories for developers and devops teams under /srv/nfs
- Exported shares through /etc/exports restricted to client1 ip
- Configured indirect autofs map (/etc/auto.master & /etc/auto.nfs)
- Tested on-demand mounting, share mounted automatically on access
- Verified write and read access from client1 to NFS share

## Commands Used

### 1. NFS Server Installation (server1)
- dnf install -y nfs-utils
- systemctl enable --now nfs-server

### 2. Shared Directory Creation
- mkdir -p /srv/nfs/developers
- mkdir -p /srv/nfs/devops

### 3. NFS Exports Configuration
- Edited /etc/exports
- Applied  exportfs -ra
- Applied exportfs -v

### 4. Firewall Configuration
- firewall-cmd --add-service=nfs --permanent
- firewall-cmd --add-service=rpc-bind --permanent
- firewall-cmd --add-service=mountd --permanent
- firewall-cmd --reload

### 5. Autofs Installation on client1
- dnf -y install autofs nfs-utils
- systemctl enable --now autofs

### 6. Autofs Map Configuration
- edited the /etc/auto.master config file 
- edited the /etc/auto.nfs config file 

## Key Concepts:
- NFS allows a server to share directories over the network so clients can access them as local storage, eliminating the need to duplicate files across multipleservers
- Autofs mounts NFS shares on demand when accessed on demand and unmounts them after a period of inactivity, this is more efficient than  /etc/fstab mounts which consumes resources regardless of use 
- Indirect autofs maps use a base directory (/mnt/nfs) with keys (developers,devops) that map to specific NFS exports which is cleaner and more scalable than direct maps
- /etc/auto.master is the master configuration pointing autofs to the indirect map file, seperation of concerns between where to mount and what to mount 
- root_squash (default NFS option) maps root on the client to the nobody user on the server, a security measure preventing clients from having unrestricted root access to NFS shares 
- NFS requires three firewalld services, nfs, mountd, rpc-bind. All three must be opened for mounting to suceed

## Lesson Learned
- Permission needed on NFS write was caused by root_squash mapping client root to nobody, this is fixed by setting directory ownership to nobody:nobody and permissions to 777
- autofs mounts are not visible with mount commands until the share is actually accessed
- The path in /etc/auto.nfs refers to the exported path on the NFS server, not a local path on the client
- NFS exports restricted to a specific client IP(192.168.56.20) is more secure than allowing the entire subnet   

