# Export VM from GCP
* Instructions for exporting a VM from GCP with Google Cloud SDK and running the VM image locally.
* These instructions were created by using Debian WSL (Windows Subsystem Linux), but as long as google-cloud-sdk is installed, any other supported platform should work.

### Sources
* Create custom image: https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images
* Export custom image: https://cloud.google.com/compute/docs/images/export-image#exporting_an_image
* Convert raw disk: https://stackoverflow.com/questions/454899/how-to-convert-flat-raw-disk-image-to-vmdk-for-virtualbox-or-vmplayer
* VirtualBox installation: https://wiki.debian.org/VirtualBox


## Install google-cloud-sdk
* https://cloud.google.com/sdk/docs/install

## Remember to create a local admin user if the VM is exported out of GCP!

## Exporting a VM into Google Cloud Storage
* Basic commands
    * Create custom image
      * The --force flag is an optional flag that lets you create the image from a running instance.
        ~~~
        gcloud compute images create IMAGE_NAME \
            --source-disk=SOURCE_DISK \
            --source-disk-zone=ZONE \
            [--family=IMAGE_FAMILY] \
            [--storage-location=LOCATION]
            [--force]
        ~~~
    * Export custom image
        ~~~
        gcloud compute images export \
            --destination-uri DESTINATION_URI \
            --image IMAGE_NAME
        ~~~

* Create and export image to Google Storage
    * Variables
    ~~~
    ### Variables for automation
    # Storage Bucket name
    bkt_name="gcp-storage-2021"
    
    # Zone where the disk resides
    src_disk_zone="europe-west3-b"
    
    # Project ID in which the disk resides
    # This can be found from the dashboard of the project in console.cloud.google.com
    src_project="project-id-name"
    
    # Name of the image 
    image_name="vm01-export-20210616"
    
    # Name of disk which should be exported
    src_disk="vm01-disk"


    # Create custom image
    gcloud compute images create "$image_name" \
        --project="$src_project" \
        --source-disk="$src_disk" \
        --source-disk-zone="$src_disk_zone" |& \
        tee -a "$image_name"_custom_image_$(date +"%Y-%m-%d_%H-%M").log
    
    # Export the image into Google storage
    gcloud compute images export \
        --project "$src_project" \
        --zone "$src_disk_zone" \
        --destination-uri gs://"$bkt_name"/"$image_name"/"$image_name".tar.gz \
        --image "$image_name" |& \
        tee -a "$image_name"_export_to_bucket_$(date +"%Y-%m-%d_%H-%M").log
    ~~~

    * If there's error below, add the Cloud Build Service Account Role in the bucket permissions for 111111111111@cloudbuild.gserviceaccount.com 
       ~~~
       [image-export] 2021/09/15 08:57:37 step "image-export-export-disk" validation error: step "copy-image-object"
       validation error: error reading bucket "gcp-storage-2021": googleapi: Error 403:
       111111111111@cloudbuild.gserviceaccount.com does not have storage.buckets.get access to the Google Cloud Storage bucket., forbidden
       ~~~~

*  Copy the exported VM to current folder
    ~~~
    gsutil cp gs://"$bkt_name"/"$image_name"/"$image_name".tar.gz ./
    ~~~
* After checking that the export works in the local virtualization environment, one can archive the VM again.
  * This one-liner is nice as the VM files can be huge and by default there's no progress bar when creating tar.gz
     * Source of the one-liner: https://superuser.com/questions/168749/is-there-a-way-to-see-any-tar-progress-per-file
        ~~~
        vm="vm_folder"; date=$(date +"%Y%m%d_%H%M"); tar cf - $vm -P | pv -s $(du -sb $vm | awk '{print $1}') | gzip > "$vm"_"$date".tar.gz
        ~~~
        ~~~
        # Output
        201MiB 0:00:11 [15.9MiB/s] [=>               ]  2% ETA 0:06:49
        ~~~ 

## Export CentOS 8
* There are some tricks what one needs to do after exporting a CentOS 8 VM from GCP.
* These were required when migrating into Hyper-V.
* The raw.disk was converted into Hyper-V with Starwind V2V software.
#### When booting there was error `Probing EDD (edd=off to disable)... ok`. Fix with steps below.
  1. Attach CentOS installer CD/DVD
  1. Boot the VM and select from the installer: Troubleshooting -> Rescue -> 1) Continue
      ~~~
      chroot /mnt/sysimage
      cd /etc/default/
      cp grub grub.bak-date
      ~~~
  1. Edit with vi or preferred editor `/etc/default/grub`. Example of GRUB config which worked:
      ~~~
      cat /etc/default/grub
      GRUB_TIMEOUT=0
      GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
      GRUB_DEFAULT=saved
      GRUB_DISABLE_SUBMENU=true
      GRUB_TERMINAL_OUTPUT="console"
      GRUB_CMDLINE_LINUX="crashkernel=auto rhgb edd=off"
      GRUB_DISABLE_RECOVERY="true"
      GRUB_ENABLE_BLSCFG=true
      ~~~
  1. Make new GRUB config
      ~~~
      grub2-mkconfig –o /boot/grub2/grub.cfg
      ~~~
   1. Compile kernel with Hyper-V settings. When migrating from VMware to Hyper-V this can be done with the orignal VM running in VMware, but when migrating from GCP it didn't seem to help to run this before migration.
      ~~~
      # The $(uname -r) variables need to be replaced with actual kernel IDs if run in rescue mode. Check with "ls /boot/" which kernels are available in the original system.
      mkinitrd -f -v --with=hid-hyperv --with=hv_utils --with=hv_vmbus --with=hv_storvsc --with=hv_netvsc /boot/initramfs-$(uname -r).img $(uname -r)
      ~~~
  1. Add local super user and add password for the user. This could've been done when the original VM was running, but doesn't matter.
  1. Edit /etc/ssh/sshd_config
      ~~~
      #### Google OS Login control. Do not edit this section. ####
      #AuthorizedKeysCommand /usr/bin/google_authorized_keys
      #AuthorizedKeysCommandUser root

      .
      .
      .

      PasswordAuthentication yes
      ~~~
  1. Disable Google auth modules from PAM. SSH will not work otherwise properly if Google software is removed.
      ~~~
      cat /etc/pam.d/sshd
      #### Google OS Login control. Do not edit this section. ####
      auth       [default=ignore] pam_group.so
      #### End Google OS Login control section. ####
      #%PAM-1.0
      auth       substack     password-auth
      auth       include      postlogin
      account    required     pam_sepermit.so
      account    required     pam_nologin.so
      account    include      password-auth
      password   include      password-auth
      # pam_selinux.so close should be the first session rule
      session    required     pam_selinux.so close
      session    required     pam_loginuid.so
      # pam_selinux.so open should only be followed by sessions to be executed in the user context
      session    required     pam_selinux.so open env_params
      session    required     pam_namespace.so
      session    optional     pam_keyinit.so force revoke
      session    optional     pam_motd.so
      session    include      password-auth
      session    include      postlogin

      #### Google OS Login control. Do not edit this section. ####
      #account    [success=ok ignore=ignore default=die] pam_oslogin_login.so
      #account    [success=ok default=ignore] pam_oslogin_admin.so
      #session    [success=ok default=ignore] pam_mkhomedir.so
      #### End Google OS Login control section. ####
      ~~~
  1. Reboot system
  1. Connect with SSH
  1. Remove Google software
      ~~~
      sudo yum remove google-osconfig-agent.x86_64
      sudo yum remove google-guest-agent
      ~~~
      
## Export CentOS 7
~~~
sudo yum remove google-osconfig-agent google-guest-agent
~~~

## Export Ubuntu
### Ubuntu 18.04
* Exported Ubuntu 18.04 into Hyper-V. The below is some disk information from the source machine.
   ~~~
   sudo fdisk -l
      .
      .
      .

      Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 4096 bytes
      I/O size (minimum/optimal): 4096 bytes / 4096 bytes
      Disklabel type: gpt
      Disk identifier: 666FEDE1-CC6B-4915-BDC1-CBC61AF6D05D

      Device      Start      End  Sectors  Size Type
      /dev/sda1  227328 41943006 41715679 19.9G Linux filesystem
      /dev/sda14   2048    10239     8192    4M BIOS boot
      /dev/sda15  10240   227327   217088  106M EFI System

      Partition table entries are not in disk order.


   sudo parted /dev/sda print
      Model: Google PersistentDisk (scsi)
      Disk /dev/sda: 21.5GB
      Sector size (logical/physical): 512B/4096B
      Partition Table: gpt
      Disk Flags:

      Number  Start   End     Size    File system  Name  Flags
      14      1049kB  5243kB  4194kB                     bios_grub
      15      5243kB  116MB   111MB   fat32              boot, esp
       1      116MB   21.5GB  21.4GB  ext4
   ~~~
1. Convert the `raw.disk` with StarWind V2V converter into Hyper-V.
   * Note that you need to rename the `raw.disk` into `raw.disk.img`
   * Select Gen 2
   * Enable Secure Boot with Template: Microsoft UEFI Certificate Authority.
1. If you boot now and choose Rescue mode, there will be error similar to below.
   ~~~
   Kernel Panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
   ~~~
1. Attach Ubuntu 18.04 Live CD and boot the VM.
1. Fix kernel and grub by opening terminal.
   ~~~
   sudo mount /dev/sda1 /mnt
   sudo mount /dev/sda15 /mnt/boot/efi
   for i in /dev /dev/pts /proc /sys /run; do sudo mount -B $i /mnt$i; done
   sudo chroot /mnt
   apt install initramfs-tools
   update-initramfs -u -k 5.4.0-1056-gcp
   update-grub2
   ~~~
1. To get SSH working
   * /etc/ssh/sshd_config comment out the lines below.
      ~~~
      #### Google OS Login control. Do not edit this section. ####
      #AuthorizedKeysCommand /usr/bin/google_authorized_keys
      #AuthorizedKeysCommandUser root
      #### End Google OS Login control section. ####
      ~~~
   * Edit PAM configuration `/etc/pam.d/sshd` by commenting out the lines below.
      ~~~
      # Added by Google Compute Engine OS Login.
      #account    [success=ok ignore=ignore default=die] pam_oslogin_login.so
      #account    [success=ok default=ignore] pam_oslogin_admin.so
      ~~~
   * Remove Google software, SSHD deosn't start if these are installed.
      ~~~
      sudo apt remove gce-compute-image-packages google-compute-engine-oslogin
      ~~~
   * Restart SSH daemon
      ~~~
      sudo systemctl restart sshd
      ~~~
