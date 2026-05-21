# 07 - FreeIPA Centralized Authentication

## Scenario: TechBridge Solutions was scaling rapidly and managing users individually on every server was becoming unmanageaable. The IT manager requested a centralized authentication system where every user is created once and can login to any enrolled serverautomatically. FreeIPA was selected as the identity management solution.

## Environment
- OS: Red Hat Enterprise Linux 10(x86_64) 
- Virtualization: Oracle Virtual Box
- Server: server1.techbridge.local(192.168.56.10)[FreeIPA Server]
- Client:client1.lab.local(192.168.56.20)[Intended FreeIPA client]
- Role: Centralized Identity and authentication management

## Tasks Completed
- Installed FreeIPA server with integrated DNS on server1
- Verified all FreeIPA services running(Directory, Kerberos, DNS, HTTP)
- Obtained Kerberos admin ticket and verified with klist
- Created FreeIPA user ipa.user and assigned to group ipa.users 
- Attempted client1 enrollment which got blocked by pyasn1python dependecy conflict on RHEL 10
- Documented platform limitation and workaround path

## Commands Used
 
### 1. FreeIPA Server Installation
- dnf install -y freeipa-server freeipa-server-dns
- ipa-server-install --setup-dns --no-forwarder --no-reverse (domain:techbridge.local, realm:TECHBRIDGE.LOCAL)
- Verification: ipactl status
- Output: Directory Service: RUNNING
krb5kdc Service: RUNNING
kadmin Service: RUNNING
named Service: RUNNING
httpd Service: RUNNING
ipa-custodia Service: RUNNING
pki-tomcatd Service: STOPPED
ipa-otpd Service: RUNNING
ipa-dnskeysyncd Service: RUNNING
1 service(s) are not running
 
### 2. Kerberos Ticket
- kinit admin: used to obtain ticket for admin@TECHBRIDGE.LOCAL
- Verification: klist (to show valid valid ticket and expiry)
- Output: Valid starting       Expires              Service principal
20/05/2026 04:36:42  21/05/2026 04:03:29  HTTP/server1.techbridge.local@TECHBRIDGE.LOCAL
20/05/2026 04:31:02  21/05/2026 04:03:29  krbtgt/TECHBRIDGE.LOCAL@TECHBRIDGE.LOCAL 

### 3. User Creation
- ipa user-add ipa.user --first=IPA --last=USER --password
- Verification: ipa user-find ipa.user
- Output: 
1 user matched
--------------
  User login: ipa.user
  First name: IPA
  Last name: User
  Home directory: /home/ipa.user
  Login shell: /bin/sh
  Principal name: ipa.user@TECHBRIDGE.LOCAL
  Principal alias: ipa.user@TECHBRIDGE.LOCAL
  Email address: ipa.user@techbridge.local
  UID: 571600003
  GID: 571600003
  Account disabled: False
----------------------------
Number of entries returned 1
----------------------------
### 4. Group Creation & Member Assignment
- ipa group-add ipa.users --desc="IPA Test Users"
- ipa group-add-member ipa.users --users=ipa.user
- Verification: ipa group-show ipa.users
- Output: Group name: ipa.users
  Description: IPA Test Users
  GID: 571600004
  Member users: ipa.user

### 5. Client Enrollment(Attempted)
- dnf install -y freeipa-client 
- ipa-client-install: This command failed with ImportError: cannot import name PyAsn1 Error from pyasn1.error. RHEL 10 ships pyasn1 0.6.x which is incompatible with FreeIPA client which expects 0.4.x. Downgrade attempt through dnf and pip were unsuccessful as RHEL10 repos do not carry pyasn1 0.4.x

## Key Concepts
- FreeIPA(Identity, Policy, & Audit) is the linux equivalent of Microsoft Active Directory. It provides centralized identity management solution across multiple servers.
- Kerberos is the authentication protocol which FreeIPA uses, users obtain a ticket once and use it to authenticate to any enrolled service without re-entering credentials.
- SSSD(System Security Services Daemon) runs on enrolled clients and and acts as the bridge between the client and the FreeIPA server for authentication requests
- LDAP stores all user and group data in FreeIPA. When a user logs in, SSSD queries LDAP to retrieve their identity information
- Centralized authentication eliminates the need to create and manage local accounts on every server. A critical operational requirement at scale
- DNS integration in FreeIPA allows enrolled clients to automatically discover the FreeIPA server by hostname rather than hardcoded IPs 

## Lesson Learned 
- FreeIPA server installation requires at least 1.5GB available RAM on a virtualVM with default 2GB allocation this required increasing RAM to 3GB before installation could proceed 
- The ipa-server-install confirmation prompt defaults to "no", pressing enter key aborts the installation; must explicitly type "yes" to proceed.
- chrony must be configured and time must be synchronized before FreeIPA installation 
- Kerberos authentication is time sensitive and fails if server and client clocks are out of sync by more than 5 minutes 
