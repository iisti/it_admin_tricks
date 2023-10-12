# How to reset Windows password with Linux

* Windows 2003 32bit password was reset.
    * debian-live-11.0.0-i386-standard.iso image was used for these instructions.
    * Notice that the Windows machine was 32bit, so 32bit version of Debian was used.

1. Choose Live Kernel when booting.
1. Run update check
    ~~~
    sudo apt update
    ~~~
1. Install password changer and support for NTFS file system.
    ~~~
    sudo apt install chntpw ntfs-3g
    ~~~
1. One can check that the Windows boot disk is showing with command lsblk
1. Mount Windows hard drive
    ~~~
    sudo ntfs-3g /dev/sda1 /mnt –o force
    ~~~
1. Browse into config directory, Linux is case sensitive and depending on Windows version the path could be written with capital or small letters.
    ~~~
    cd /mnt/Windows/system32/config
    ~~~
1. List users (for some reason the full path of the binary was required)
    ~~~
    /usr/sbin/chntpw -l SAM
    ~~~
1. Change password
    ~~~
    /usr/sbin/chntpw –u username SAM
    ~~~
