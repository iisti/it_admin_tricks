# How to resize CentOS root partition

## Rocky 8
* Original nvme0n1 is 12 GB, and it's increased into 26 GB.
* The VM is running in AWS.
1. Extend the disk via AWS console.
1. Original disk information
    ~~~
    df -hT
    Filesystem     Type      Size  Used Avail Use% Mounted on
    devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
    tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
    tmpfs          tmpfs     1.8G  8.4M  1.8G   1% /run
    tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
    /dev/nvme0n1p1 xfs        12G  2.6G  9.5G  22% /
    tmpfs          tmpfs     369M     0  369M   0% /run/user/1000
    
    lsblk
    NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
    nvme0n1     259:0    0  26G  0 disk
    └─nvme0n1p1 259:1    0  12G  0 part /
    ~~~
1. Growpart
    ~~~
    sudo growpart /dev/nvme0n1 1
    CHANGED: partition=1 start=2048 old: size=25163743 end=25165791 new: size=54523871 end=54525919
    ~~~
1. Check that partition has grown.
    ~~~
    lsblk
    NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
    nvme0n1     259:0    0  26G  0 disk
    └─nvme0n1p1 259:1    0  26G  0 part /
    ~~~
1. The file system hasn't grown.
    ~~~
    df -hT
    Filesystem     Type      Size  Used Avail Use% Mounted on
    devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
    tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
    tmpfs          tmpfs     1.8G  8.4M  1.8G   1% /run
    tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
    /dev/nvme0n1p1 xfs        12G  2.6G  9.5G  22% /
    tmpfs          tmpfs     369M     0  369M   0% /run/user/1000
    ~~~
1. Grow filesystem
    ~~~
    sudo xfs_growfs -d /
 
    meta-data=/dev/nvme0n1p1         isize=512    agcount=7, agsize=508800 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=1        finobt=1, sparse=1, rmapbt=0
             =                       reflink=1    bigtime=0 inobtcount=0
    data     =                       bsize=4096   blocks=3145467, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
    log      =internal log           bsize=4096   blocks=2560, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0
    data blocks changed from 3145467 to 6815483
    ~~~
1. check that filesystem has grown.
    ~~~
    df -hT
    Filesystem     Type      Size  Used Avail Use% Mounted on
    devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
    tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
    tmpfs          tmpfs     1.8G  8.4M  1.8G   1% /run
    tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
    /dev/nvme0n1p1 xfs        26G  2.7G   24G  11% /
    tmpfs          tmpfs     369M     0  369M   0% /run/user/1000
    ~~~

## CentOS 7
* Original sda disk is 8 GB, and it's increased into 16 GB.
* The VM is running on ESXi 6.7, but that shouldn't matter for these instructions.
1. Extend the primary disk from 8 GB -> 16 GB.
1. Original disk information
    ~~~
    [root@centos7 ~]# df -h
    Filesystem                                       Size  Used Avail Use% Mounted on
    devtmpfs                                         908M     0  908M   0% /dev
    tmpfs                                            920M     0  920M   0% /dev/shm
    tmpfs                                            920M   97M  823M  11% /run
    tmpfs                                            920M     0  920M   0% /sys/fs/cgroup
    /dev/mapper/centos_centos7-root                   6.2G  5.9G  305M  96% /
    /dev/sda1                                       1014M  251M  764M  25% /boot
    /dev/sdb1                                        250G  241G  9.6G  97% /opt/storage
    freenas01.domain.com:/mnt/pool01/backups         3.7T  1.9T  1.9T  50% /opt/freenas01_backups
    tmpfs                                            184M     0  184M   0% /run/user/1000
    tmpfs                                            184M     0  184M   0% /run/user/1033
    [root@centos7 ~]# lsblk
    NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda                      8:0    0    8G  0 disk
    ├─sda1                   8:1    0    1G  0 part /boot
    └─sda2                   8:2    0    7G  0 part
      ├─centos_centos7-root 253:0    0  6.2G  0 lvm  /
      └─centos_centos7-swap 253:1    0  820M  0 lvm  [SWAP]
    sdb                      8:16   0  250G  0 disk
    └─sdb1                   8:17   0  250G  0 part /opt/storage
    sr0                     11:0    1 1024M  0 rom

    [root@centos7 ~]# pvs
      PV         VG            Fmt  Attr PSize  PFree
      /dev/sda2  centos_centos7 lvm2 a--  <7.00g    0
    ~~~  
1. Install tools
    ~~~
    yum -y install cloud-utils-growpart gdisk
    ~~~
1. Scan for disk changes
    ~~~
    echo 1 > /sys/block/sda/device/rescan
    ~~~
1. Resize physical volume
    ~~~
    [root@sftp03 ~]# pvresize /dev/sda2
      Physical volume "/dev/sda2" changed
      1 physical volume(s) resized or updated / 0 physical volume(s) not resized
    ~~~ 
1. Grow partition size
    ~~~
    [root@centos7 ~]# growpart /dev/sda 2
    CHANGED: partition=2 start=2099200 old: size=14678016 end=16777216 new: size=31455199 end=33554399
    ~~~
1. Check changes
    ~~~
    [root@centos7 ~]# lsblk
    NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda                      8:0    0   16G  0 disk
    ├─sda1                   8:1    0    1G  0 part /boot
    └─sda2                   8:2    0   15G  0 part
      ├─centos_centos7-root 253:0    0  6.2G  0 lvm  /
      └─centos_centos7-swap 253:1    0  820M  0 lvm  [SWAP]
    sdb                      8:16   0  250G  0 disk
    └─sdb1                   8:17   0  250G  0 part /opt/storage
    sr0                     11:0    1 1024M  0 rom
    ~~~
1. Resize logical volume
    ~~~  
    [root@centos7 ~]# lvresize -L +8G /dev/mapper/centos_centos7-root
      Size of logical volume centos_centos7/root changed from <6.20 GiB (1586 extents) to <14.20 GiB (3634 extents).
      Logical volume centos_centos7/root successfully resized.  
    ~~~
1. Check changes
    ~~~
    [root@centos7 ~]# lsblk
    NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda                      8:0    0   16G  0 disk
    ├─sda1                   8:1    0    1G  0 part /boot
    └─sda2                   8:2    0   15G  0 part
      ├─centos_centos7-root 253:0    0 14.2G  0 lvm  /
      └─centos_centos7-swap 253:1    0  820M  0 lvm  [SWAP]
    sdb                      8:16   0  250G  0 disk
    └─sdb1                   8:17   0  250G  0 part /opt/storage
    sr0                     11:0    1 1024M  0 rom
    ~~~
1. The filesystem is still only 8GB
    ~~~
        [root@centos7 ~]# df -Th
        Filesystem                                      Type      Size  Used Avail Use% Mounted on
        devtmpfs                                        devtmpfs  908M     0  908M   0% /dev
        tmpfs                                           tmpfs     920M     0  920M   0% /dev/shm
        tmpfs                                           tmpfs     920M   97M  823M  11% /run
        tmpfs                                           tmpfs     920M     0  920M   0% /sys/fs/cgroup
        /dev/mapper/centos_centos7-root                  xfs       6.2G  5.9G  302M  96% /
        /dev/sda1                                       xfs      1014M  251M  764M  25% /boot
        /dev/sdb1                                       xfs       250G  241G  9.6G  97% /opt/storage
        freenas01.domain.com:/mnt/pool01/backups nfs4      3.7T  1.9T  1.9T  50% /opt/freenas01_backups
        tmpfs                                           tmpfs     184M     0  184M   0% /run/user/1000
        tmpfs                                           tmpfs     184M     0  184M   0% /run/user/1033
    ~~~
1. Checking current size of XFS volume
    ~~~
    [root@centos7 ~]# xfs_growfs -n /dev/mapper/centos_centos7-root
    meta-data=/dev/mapper/centos_centos7-root isize=512    agcount=4, agsize=406016 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=1        finobt=0 spinodes=0
    data     =                       bsize=4096   blocks=1624064, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
    log      =internal               bsize=4096   blocks=2560, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0
    ~~~
1. Grow XFS volume
    ~~~
    [root@centos7 ~]# xfs_growfs /dev/mapper/centos_centos7-root
    meta-data=/dev/mapper/centos_centos7-root isize=512    agcount=4, agsize=406016 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=1        finobt=0 spinodes=0
    data     =                       bsize=4096   blocks=1624064, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
    log      =internal               bsize=4096   blocks=2560, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0
    data blocks changed from 1624064 to 3721216
    ~~~
1. Check outcome
    ~~~
    [root@sftp03 ~]# df -Th
    Filesystem                                      Type      Size  Used Avail Use% Mounted on
    devtmpfs                                        devtmpfs  908M     0  908M   0% /dev
    tmpfs                                           tmpfs     920M     0  920M   0% /dev/shm
    tmpfs                                           tmpfs     920M   97M  823M  11% /run
    tmpfs                                           tmpfs     920M     0  920M   0% /sys/fs/cgroup
    /dev/mapper/centos_sftp03-root                  xfs        15G  5.9G  8.3G  42% /
    /dev/sda1                                       xfs      1014M  251M  764M  25% /boot
    /dev/sdb1                                       xfs       250G  241G  9.6G  97% /opt/storage
    freenas01.domain.com:/mnt/pool01/backups        nfs4      3.7T  1.9T  1.9T  50% /opt/freenas01_backups
    tmpfs                                           tmpfs     184M     0  184M   0% /run/user/1000
    tmpfs                                           tmpfs     184M     0  184M   0% /run/user/1033
    ~~~
