# User & Group Management + Role Based Access Control

## Scenario: TechBridge Solutionsonboarded three departments(Devops, Developers,& Auditors). The IT infrastructure team was tasked with establishing a structured user and group management framework with role based access control, enforced password policies and shared collaborative storage for each department.

## Environment
- OS: Red Hat Enterprise Linux 10 (x86_64)
- Virtualization: Oracle VirtualBox
- Hostname: server1.techbridge.local
- IP Address: 192.168.56.10
- Role: Primary Application Server

## Tasks Completed
- Created three department groups(devops, developers,auditors)

- Created two users per group following enterprise naming convention

- Enforced password ageing policies across all users(90 days maximum, 7 days minimum, 14 days warning period, 12 characters minimum length.

- Configured sudo access for the different groups created(full sudo for devops, limited command-specific for developers, no sudo for auditors)

- Created shared group directories under /srv with SGID bit ensuring new files inherit group ownership automatically.

- Demonstrated account life cycle management(locking and unlocking account to simulate offboarding and onboarding)

## Commands Used
### 1. Group Creation
- command: groupadd devops developers auditors
- verification: getent groups devops developers auditors
- output: devops:x:1002:ops.mike,ops.linda
developers:x:1001:dev.john,dev.sarah
auditors:x:1003:aud.james,aud.grace

### 2. User Creation
- command: useradd -G devops ops.mike ops.linda
useradd -G developers dev.john dev.sarah
useradd -G auditors aud.grace aud.james
- verification: getent passwd dev.jon dev.sarah ops.mike ops.linda aud.grace aud.james
- output: dev.sarah:x:1002:1005::/home/dev.sarah:/bin/bash
ops.mike:x:1003:1006::/home/ops.mike:/bin/bash
ops.linda:x:1004:1007::/home/ops.linda:/bin/bash
aud.grace:x:1006:1009::/home/aud.grace:/bin/bash
aud.james:x:1005:1008::/home/aud.james:/bin/bash

### 3. Password Policies
- file edited: /etc/login.defs
- command: chage -M 90 -m 7 -W 14 dev.john dev.sarah ops.mike ops.linda aud.grace aud.james
- verification: chage -l ops.linda
- output: Last password change					: May 03, 2026
Password expires					: Aug 01, 2026
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 7
Maximum number of days between password change		: 90
Number of days of warning before password expires	: 14

### 4. Sudo Configuration
- file edited: /etc/sudoers.d/devops, /etc/sudoers.d/developers, /etc/sudoers.d/auditors
- commands: /etc/sudoers.d/devops(%devops ALL=(ALL) ALL)
/etc/sudoers.d/developers(%developers ALL=(ALL) /usr/bin/journalctl, /usr/bin/systemctl restart tomcat, /usr/bin/systemctl restart nginx
- verification: cat /etc/sudoers.d/devops
- output: %devops ALL=(ALL) ALL

### Shared Directories
- command: mkdir -p /srv/devops, mkdir -p /srv/developers, mkdir -p /srv/auditors, chown :devops /srv/devops, chown :developers /srv/developers, chown :auditors/srv/auditors, chmod 2770 /srv/devops, chmod 2770 /srv/developers, chmod 2770 /srv/auditors
- verification: ls -ld /srv/devops
- output: drwxrws---. 2 root devops 6 May  3 06:34 /srv/devops

### Account Lock/Unlock
- command: usermod -L aud.grace/usermod -p aud.grace
- verification: passwd -S aud.grace
- output:aud.grace P 2026-05-03 7 90 14 -1

## Key Concept
- Role Based Access Control restrict system access based on a user's role within the organization rather than individual permissions, reducing attackk surface and enforcing least priviledge.

- SGID on directories ensures all files created inherit the parent directory's group ownership. This is critical for shared team collaboration without manual permission management .

- Password aging enforces credential rotation, reducing the risk of compromised credentials remaining valid indefinitely.

- Sudo access should always follow the prinsiples of least priviledge. Usersget only the elevated command their roles requires, nothing more.

- Account locking preserves user data and audit trail during offboarding while immediately revoking access.

## Lessons Learnt
- usermod -u alone cannot unlock a passwordless account. A password has to be set first.

- Sudoers entries requires absolute command paths, relative paths are rejected for security reasons
