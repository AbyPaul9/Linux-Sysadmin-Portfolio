# Title: 05-LVM Storage Implementation & Live Expansion

## Scenario: TechBridge Solutions' development team was running out of storage on server1. The infrastructure manager requested a dedicated LVM storage structure on two spare disks, with seperate logical volumes for application data and logs, persistent mounts, and a live expansion demonstration to prove storage caqn be grown without downtime

## Environment
- OS: Red Hat Enterprise Linux10 (x86_64)
- Virtualization: Oracle Virtual Box
- Server:server1.techbridge.local (192.168.56.10)
- Role: LVM storage provisioning and management on primary application server

## Tasks Completed
- Created physical volumes on /dev/sdb & /dev/sdc
- Created volume group techbridge-vg spanning both disks(20GB total)
- Created logical volumes app-data (5GB) and app-logs(3GB)
- Formatted both logical volumes with xfs filesystem
- Created mount points and mounted both volumes persistently through /etc/fstab
- Extended app-data live from 5GB-7GB without unmounting which deminstrates zero downtime

## Commands Used

### 1. Physical Volume Creation
- pvcreate /dev/sdb
- pvcreate /dev/sdc
- Verification: pvs
- Output: PV         VG            Fmt  Attr PSize   PFree
  /dev/sda3  rhel          lvm2 a--   18.41g    0 
  /dev/sdb   techbridge-vg lvm2 a--  <10.00g    0 
  /dev/sdc   techbridge-vg lvm2 a--  <10.00g 9.99g

### 2. Volume Group Creation
- vgcreate techbridge-vg /dev/sdb
- vgextend techbridge-vg /dev/sdc
- Verification: vgs
- Output:VG            #PV #LV #SN Attr   VSize  VFree
  rhel            1   2   0 wz--n- 18.41g    0 
  techbridge-vg   2   2   0 wz--n- 19.99g 9.99g

### 3. Logical Volume Creatiuon
- lvcreate -n app-data -L 5G techbridge-vg
- lvcreate -n app-logs -L 3G techbridge-vg
- Verification: lvs
- Output:  LV       VG            Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root     rhel          -wi-ao---- 16.41g                                                    
  swap     rhel          -wi-ao----  2.00g                                                    
  app-data techbridge-vg -wi-ao----  7.00g                                                    
  app-logs techbridge-vg -wi-ao----  3.00g   

### 4. Filesystem Formatting
- mkfs.xfs /dev/techbridge-vg/app-data
- mkfs.xfs /dev/techbridge-vg/app-logs
- Verification: blkid /dev/techbridge-vg/app-data
- Output:/dev/techbridge-vg/app-data: UUID="1b8f6a10-ff07-4968-b466-2d26812224af" BLOCK_SIZE="512" TYPE="xfs"

### 5. Persistent Mounting
- mkdir -p /mnt/app-data
- mkdir -p /mnt/app-logs
- Files Edited: /etc/fstab
- Added Entries: UUID=1b8f6a10-ff07-4968-b466-2d26812224af /mnt/app-data xfs defaults 0 0
- Verification: mount -a, df -h

### 6. Live Extension
- lvextend -r -L +2G /dev/techbridge-vg/app-data
- Verification: lvs, df -h
- Output:Filesystem                            Size  Used Avail Use% Mounted on
/dev/mapper/rhel-root                  17G  5.4G   11G  33% /
devtmpfs                              4.0M     0  4.0M   0% /dev
tmpfs                                 844M   84K  844M   1% /dev/shm
efivarfs                              256K   77K  175K  31% /sys/firmware/efi/efivars
tmpfs                                 338M  6.8M  331M   3% /run
tmpfs                                 1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
/dev/sda2                             960M  326M  635M  34% /boot
/dev/sda1                             599M  8.4M  591M   2% /boot/efi
tmpfs                                 169M  136K  169M   1% /run/user/1000
tmpfs                                 169M   60K  169M   1% /run/user/0
/dev/mapper/techbridge--vg-app--data  7.0G  169M  6.8G   3% /mnt/app-data
/dev/mapper/techbridge--vg-app--logs  3.0G   90M  2.9G   3% /mnt/app-logs

## Key Concepts
- LVM seperates storage management into three layers, physical volumes(PV), volume groups(VG), and logical volumes(LV) providing flexibility that raw disk partitioning can not match
- Spanning a volume group across multiple disks pools storage, allowing logical volumes larger than any single disk and enabling live expansion as new disks are added 
- Live storage expansion is a critical enterprise capability.

## Lessons Learned
- vgcreate can accept multiple disks in one command. vgextend is only needed when adding disks to an existing VG after creation
- Always verify with df -h after extension. lvs shows logical volume size but df -h confirms the filesystem has actually grown  

