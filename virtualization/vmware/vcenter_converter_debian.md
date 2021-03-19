# How to convert Debian machine with VMWare vCenter Converter

* Debian OS is not officially supported by VMware vCenter Converter

## How to convert Debian 9 machine
* VMware vCenter Converter Standalone server 6.2.0 build-8466193

* Debian version
  ~~~
  cat /etc/os-release
  PRETTY_NAME="Debian GNU/Linux 9 (stretch)"
  uname -r
  4.9.0-6-amd64
  ~~~
  
* The source machine of these instructions was using BIOS. Check if UEFI boot, the error below means that boot mode is BIOS
  ~~~
  ls /sys/firmware/efi
  ls: cannot access '/sys/firmware/efi': No such file or directory
  ~~~

* Converting a Debian VM usually fails at 98%. Some users have reported that the VM boots normally after conversion failure, so there's not really need for any special steps. In the case of these instructions the destination machine was removed automatically after conversion and there seemed to be no way of preventing it from happening.
  * Source https://serverfault.com/questions/916829/vmware-converter-standalone-gives-a-cannot-find-source-file-error-at-98-when

## Errors and failed attempts to fix them

* Converting a VM from a cloud provider failed at 98% with error:
  ~~~
  FAILED: An error occurred during the conversion: ' * Looking for deps of module scsi_mod * * Looking for deps of module sd_mod * * Looking for deps of module mptspi * * Looking for deps of module mptscsih * * Looking for deps of module BusLogic * * Looking for deps of module ahci * * Looking for deps of module ide-disk * Cannot find in 4.9.0-6-amd64 module ide-disk * Looking for deps of module pcnet32 * fstab file is /mnt/p2v-src-root/etc/fstab * found root filesystem type as ext4 * Looking for deps of module ext4 * * found root filesystem mount options as rw,discard,errors=remount-ro * processed root filesystem mount options are rw discard,errors=remount-ro * busybox mount options are --rw * new root will not be mounted as read-only * printing module list: * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/scsi/scsi_mod.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/scsi/sd_mod.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/message/fusion/mptspi.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/message/fusion/mptscsih.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/scsi/BusLogic.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/ata/ahci.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/drivers/net/ethernet/amd/pcnet32.ko * /mnt/p2v-src-root/lib/modules/4.9.0-6-amd64/kernel/fs/ext4/ext4.ko * got lib dir as lib64 * /mnt/p2v-src-root/lib64/libc.so.6 -> /mnt/p2v-src-root/tmp/initrd.iO1eO3/lib ERROR:
  cannot find source file /mnt/p2v-src-root/lib64/libc.so.6 during file copy (return code 1)'
  ~~~
* The error's last last line can be also
  ~~~
  cannot find source file /mnt/p2v-src-root/lib64/libm.so.6 during file copy (return code 1)
  ~~~
* Or
  ~~~
  cannot find source file /mnt/p2v-src-root/lib64/libcrypt.so.1 during file copy (return code 1)'
  ~~~
* Or
  ~~~
  cannot find source file /mnt/p2v-src-root/lib64/ld-linux-x86-64.so.2 during file copy (return code 1)'
  ~~~
* The different errors occur because those missing files are symbolic links and when the file system is mounted in converter helper VM, the symlinks are broken. The output below is from a test when the source machine's disk was mounted to another VM.
  ~~~
  file /mnt/root-debian-vm/lib64/ld-linux-x86-64.so.2
  /mnt/root-debian-vm/lib64/ld-linux-x86-64.so.2: broken symbolic link to /lib/x86_64-linux-gnu/ld-2.24.so
  ~~~
* There was an attempt to fix the symlink failure by replacing the symlinks with their targets. This was somehow successful as the conversion went 100% through without errors, but when the destination machine was booted, a kernel panic message popped up.

## Steps for successful conversion and boot

* Take note of the different disks on the source machine. 
    ~~~
    sudo fdisk -l
    Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
    Disk model: Virtual disk
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe4610dd5

    Device     Boot    Start      End  Sectors Size Id Type
    /dev/sda1  *        2048 44040191 44038144  21G 83 Linux
    /dev/sda2       44042238 52426751  8384514   4G  5 Extended
    /dev/sda5       44042240 52426751  8384512   4G 82 Linux swap / Solaris
    ~~~~

### Conversion
1. In vCenter Converter ***uncheck*** from Advanced options -> Post-conversion processing: ***Reconfigure destination virtual machine***
    * Also in Networks set Controller type E1000E, just to be sure there's a NIC which should be easily recognised by Debian.
1. Start conversion. It should go through 100%.
### Post-conversion configuration
1. After conversion if one tries to start the machine, there's error ***Error loading operating system***
1. Download Debian ISO from https://cdimage.debian.org/mirror/cdimage/archive In this tutorial ***debian-9.13.0-amd64-netinst.iso*** was used.
1. Mount the Debian ISO to the new VM.
1. In the VM settings set OS to Debian 9 64bit, Edit settings -> VM Options -> General Options Guest OS Version
1. Also in the VM settings set delay for boot, Edit settings -> VM Options -> Boot Options -> Boot Delay 5000 milliseconds
1. Take a snapshot of the VM.
1. Power on the VM and press ESC to open a Boot Menu.
1. Select CD from the Boot Menu.
1. Debian installer should load.
    1. Select Advanced options -> Graphical rescue mode
    1. For the settins of languages/keyboard layouts, defaults were chosen
    1. Device to use as root file system ***/dev/sda1***
    1. Rescue operations -> Execute a shell in /dev/sda1
    1. There might be error if disk UUIDs were changed during conversion, for example resizing disk could change the UUID:
        ~~~
        # This error was seen during a startup and the startup didn't continue.

        error: no such device 2e78f2bc-0a0b-487f-932d-125db59ca3bd
        ~~~
        * Check that disk UUIDs match
        ~~~
        cat /etc/fstab
        UUID=2e78... / rw,discard...

        blkid | grep UUID
        /dev/sda1: UUID"=3bf67...
        ~~~

        * If the disk UUIDs differ like above, the UUIds need to be changed.  In the above VM there's only one disk, so it's clear something is wrong. If there are multiple disks, different disks should have different UUIDs.
        * Use commands below to change the current UUID of a disk.
            ~~~
            # Check with another program the current UUID
            tune2fs -l /dev/sda1
            # Set UUID to match the one in fstab.
            tune2fs -U 2e78f2bc-0a0b-487f-932d-125db59ca3bd /dev/sda1
            # Check that UUID was updated.
            blkid | grep UUID
            ~~~
    1. Click Go back button to get back to Rescue operations menu.
    1. Rescue operations -> Reinstall GRUB boot loader
    1. Device for boot loader installation: /dev/sda
    1. In this tutorial the VM hangs for a while in with messges below, but boots in the end. It's recommend to check that the output of boot text is not redirected t o another console, so it's easy to see what's happening.
        ~~~
        ... piix4_smbus 0000:00:007.3: Host SMBus controller not enabled!
        ... [sda] Assuming drive cache: write through
        ~~~
        1. Select again: Execute a shell in /dev/sda1
        1. To enable boot text screen /etc/default/grub was modified
            * Original lines
              ~~~
              GRUB_CMDLINE_LINUX_DEFAULT=""
              GRUB_CMDLINE_LINUX="quiet elevator=noop console=tty console=ttyS0 net.ifnames=0"
              ~~~
            * Modified lines
              ~~~
              GRUB_CMDLINE_LINUX_DEFAULT=""
              GRUB_CMDLINE_LINUX="quiet elevator=noop net.ifnames=0"
              ~~~
            * Run `sudo update-grub` so that the new configuration takes effect.
      1. Click Go back button to get back to Rescue operations menu.
      1. Rescue operations -> Reboot the system
1. After the boot logs where on the screen it was realised that ***cloud-init*** was causing errors
    * Something like below
      ~~~
      cloud-init 169.254.169.254 Failed to establish a new connection: [[Errno 113] No route to host
      ~~~
    * This was fixed by disabling cloud-init
      ~~~
      touch /etc/cloud/cloud-init.disabled
      ~~~
1. Networking was lost also at somepoint and was fixed with commands below
      ~~~
      # Check network interfaces, in the tutorial it was noticed that ens160 didn't have IP and the link was down.
      ip link show
      1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
      inet6 ::1/128 scope host
         valid_lft forever preferred_lft forever
      2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state down group default qlen 1000

      # Add config similar to below into /etc/network/interfaces

      auto ens160
      iface ens160 inet dhcp
      allow-hotplug ens160
      ~~~
      * Might be that removing and re-adding a NIC is also required on the VMware side.
1. Lastly install VM Tools
      ~~~
      sudo apt-get install open-vm-tools
      ~~~
