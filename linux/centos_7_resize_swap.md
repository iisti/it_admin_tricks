# Resize swap CentOS 7
* Sources:
    * https://computingforgeeks.com/extending-root-filesystem-using-lvm-linux/
    * https://askubuntu.com/questions/226520/how-can-i-modify-the-size-of-swap-with-lvm-partitions


## Resize process
* Disclaimer: this process was done with a CentOS 7 VM running on ESXi 6.7
1. Install tool packages, gdisk is required for resizing GPT
    ~~~
    yum -y install cloud-utils-growpart gdisk
    ~~~
1. Shutdown VM
1. Remove all snapshots (if running ESXi)
1. Increase disk size, it was increased by 5GB
1. Power on
1. Some checks
    ~~~
    lsblk
        NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda               8:0    0   55G  0 disk
        ├─sda1            8:1    0  200M  0 part /boot/efi
        ├─sda2            8:2    0    1G  0 part /boot
        └─sda3            8:3    0 48.8G  0 part
          ├─centos-root 253:0    0 43.8G  0 lvm  /
          └─centos-swap 253:1    0    5G  0 lvm
        sr0              11:0    1  918M  0 rom


    pvs
        PV         VG     Fmt  Attr PSize  PFree
        /dev/sda3  centos lvm2 a--  48.80g    0


    free -m
                      total        used        free      shared  buff/cache   available
        Mem:           7820         401        7275           8         144        7209
        Swap:          5119           0        5119
    ~~~
1. Turn swap off
    ~~~
    swapoff -a
    ~~~
1. Grow the disk size
    ~~~
    growpart /dev/sda 3
        CHANGED: partition=3 start=2508800 old: size=102346752 end=104855552 new: size=112834526 end=115343326
    ~~~
1. Check what happened
    ~~~
    lsblk
        NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda               8:0    0   55G  0 disk
        ├─sda1            8:1    0  200M  0 part /boot/efi
        ├─sda2            8:2    0    1G  0 part /boot
        └─sda3            8:3    0 53.8G  0 part
          ├─centos-root 253:0    0 43.8G  0 lvm  /
          └─centos-swap 253:1    0    5G  0 lvm
        sr0              11:0    1  918M  0 rom
    ~~~
1. Resize physical volume /dev/sda3
    ~~~
    pvresize /dev/sda3
        Physical volume "/dev/sda3" changed
        1 physical volume(s) resized or updated / 0 physical volume(s) not resized
    ~~~
1. Check out come
    ~~~
    vgs
        VG     #PV #LV #SN Attr   VSize  VFree
        centos   1   2   0 wz--n- 53.80g 5.00g
    ~~~
1. Resize logical volume
    ~~~
    lvresize -L +5G /dev/centos/swap
        Size of logical volume centos/swap changed from 5.00 GiB (1280 extents) to 10.00 GiB (2560 extents).
        Logical volume centos/swap successfully resized.
    ~~~
1. Recreate swap
    ~~~
    mkswap /dev/mapper/centos-swap
        mkswap: /dev/mapper/centos-swap: warning: wiping old swap signature.
        Setting up swapspace version 1, size = 10485756 KiB
        no label, UUID=7d1e121d-dcf3-410c-83ee-96f532c8fbfd
    ~~~
1. Check what happened
    ~~~
    lsblk
        NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda               8:0    0   55G  0 disk
        ├─sda1            8:1    0  200M  0 part /boot/efi
        ├─sda2            8:2    0    1G  0 part /boot
        └─sda3            8:3    0 53.8G  0 part
          ├─centos-root 253:0    0 43.8G  0 lvm  /
          └─centos-swap 253:1    0   10G  0 lvm
        sr0              11:0    1  918M  0 rom

    free -m
                      total        used        free      shared  buff/cache   available
        Mem:           7820         746        5721          13        1352        6818
        Swap:         10239           0       10239
    ~~~
1. Turn swap back on
    ~~~
    swapon /dev/mapper/centos-swap
    ~~~
