## How to extend disk in Debian 6 (should work for other OS versions also) without LVM
* Shutdown machine
* Extend disk in the virtualization layer
* Start machine

### TL;DR

~~~
# Check orignals
df -Th
lsblk
  # This is an example output from different machine than device /dev/sda which is beign used below.
  # In here disk has been extended to 450 G from hyper visor, but the OS still is configured with 400 G.
  nvme2n1      259:3    0  450G  0 disk
  └─nvme2n1p1  259:8    0  400G  0 part /opt/disk-02
fdisk -l

# Extend with fdisk
fdisk -u /dev/sda
  c # Disable DOS-compatible mode. There should be notification like below.
      # DOS Compatibility flag is not set
  p # Print original information
  d # Delete partition, deleting partition doesn't delete data on the disk, just partition information will be rewritten.
    2 # Partition 2 (in this VM the primary partition was 2)
  n # Create new patition
    p # Use as primariy partition
    2 # Set partition number
    defaults for the First and the Last sector should be okay, but check them still.
    
    # Don't remove the partition signature.
    Created a new partition 1 of type 'Linux' and of size 450 GiB.
    Partition #1 contains a ext4 signature.
    Do you want to remove the signature? [Y]es/[N]o: N

  p # Print information and check it's okay
  w # Write the information to disk
  q # Quit

# Check what has happened
fdisk -l
df -h

# Mount in fstab with UUIDs, especially if using XFS. Mounting with device names can prevent VM from booting if Linux changes device names!
# Check UUIDs
blkid
# Change UUIDs into /etc/fstab if needed

# If the filesystem is ext*
# Force kernel to use the new layout
partx /dev/sda
resize2fs /dev/sda2
# If resize2fs doesn't work, reboot the machine and use resize2fs again
shutdown -r now
resize2fs /dev/sda2

# Now the new space should show up, check it
df -h
~~~

* If the filesystem is XFS
    ~~~
    # Check device name
    lsblk

    # Grow partition, growpart device_name partition_number
    sudo growpart /dev/nvme1n1 1

      CHANGED: partition=1 start=2048 old: size=838858719 end=838860767 new: size=1258289119,end=1258291167

    # Check mount point
    mount -l
        /dev/nvme2n1p1 on /opt/disk-02 type xfs (rw,relatime,attr2,inode64,noquota)
    xfs_growfs /opt/disk-02
    
    # Now the new space should show up, check it
    df -h
    ~~~

### Check original information
* Shutdown machine and extend disk.

~~~
df -Th
    Dateisystem   Typ     Size  Used Avail Use% Eingehängt auf
    /dev/sda2     ext3    141G  124G  9,6G  93% /
    tmpfs        tmpfs    2,0G     0  2,0G   0% /lib/init/rw
    udev         tmpfs    2,0G   84K  2,0G   1% /dev
    tmpfs        tmpfs    2,0G     0  2,0G   0% /dev/shm

fdisk -l
    Disk /dev/sda: 171.8 GB, 171798691840 bytes
    255 heads, 63 sectors/track, 20886 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x0004a776

       Device Boot      Start         End      Blocks   Id  System
    /dev/sda1               1         973     7815591   82  Linux swap / Solaris
    /dev/sda2             974       19582   149470777+  83  Linux
    Partition 2 does not end on cylinder boundary.
~~~

### Extend disk
~~~
root@vm-name{~}:fdisk -u /dev/sda

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c').

Command (m for help): c
DOS Compatibility flag is not set

Command (m for help): p

Disk /dev/sda: 171.8 GB, 171798691840 bytes
255 heads, 63 sectors/track, 20886 cylinders, total 335544320 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0004a776

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1              63    15631244     7815591   82  Linux swap / Solaris
/dev/sda2        15631245   314572799   149470777+  83  Linux

Command (m for help): d
Partition number (1-4): 2

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 2
First sector (15631245-335544319, default 15631245):
Using default value 15631245
Last sector, +sectors or +size{K,M,G} (15631245-335544319, default 335544319):
Using default value 335544319

Command (m for help): p

Disk /dev/sda: 171.8 GB, 171798691840 bytes
255 heads, 63 sectors/track, 20886 cylinders, total 335544320 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0004a776

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1              63    15631244     7815591   82  Linux swap / Solaris
/dev/sda2        15631245   335544319   159956537+  83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Das Gerät oder die Ressource ist belegt.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.


root@vm-name{~}:fdisk -l

Disk /dev/sda: 171.8 GB, 171798691840 bytes
255 heads, 63 sectors/track, 20886 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0004a776

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1               1         973     7815591   82  Linux swap / Solaris
/dev/sda2             974       20887   159956537+  83  Linux
Partition 2 does not end on cylinder boundary.

root@vm-name{~}:partx /dev/sda
# 1:        63- 15631244 ( 15631182 sectors,   8003 MB)
# 2:  15631245-335544319 (319913075 sectors, 163795 MB)
# 3:         0-       -1 (        0 sectors,      0 MB)
# 4:         0-       -1 (        0 sectors,      0 MB)

root@vm-name{~}:df -h
Dateisystem           Size  Used Avail Use% Eingehängt auf
/dev/sda2             141G  124G  9,6G  93% /
tmpfs                 2,0G     0  2,0G   0% /lib/init/rw
udev                  2,0G   84K  2,0G   1% /dev
tmpfs                 2,0G     0  2,0G   0% /dev/shm

root@vm-name{~}:resize2fs /dev/sda2
resize2fs 1.41.12 (17-May-2010)
Das Dateisystem ist schon 37367694 Blöcke groß. Nichts zu tun!

shutdown -r now

root@vm-name{~}:df -h
Dateisystem           Size  Used Avail Use% Eingehängt auf
/dev/sda2             141G  124G  9,6G  93% /
tmpfs                 2,0G     0  2,0G   0% /lib/init/rw
udev                  2,0G   84K  2,0G   1% /dev
tmpfs                 2,0G     0  2,0G   0% /dev/shm
root@vm-name{~}:resize2fs /dev/sda2
resize2fs 1.41.12 (17-May-2010)
Das Dateisystem auf /dev/sda2 ist auf / eingehängt; Online-Grössenveränderung nötig
old desc_blocks = 9, new_desc_blocks = 10
Führe eine Online-Grössenänderung von /dev/sda2 auf 39989134 (4k) Blöcke durch.
Das Dateisystem auf /dev/sda2 ist nun 39989134 Blöcke groß.

root@vm-name{~}:df -h
Dateisystem           Size  Used Avail Use% Eingehängt auf
/dev/sda2             151G  124G   19G  87% /
tmpfs                 2,0G     0  2,0G   0% /lib/init/rw
udev                  2,0G   84K  2,0G   1% /dev
tmpfs                 2,0G     0  2,0G   0% /dev/shm
~~~
