# How to use XSIBackup for backup ESXi VMs


## XSIBackup installation 
* Download for ESXi 5.1 => 6.7 https://33hops.com/xsibackup-download-old-software-versions.html
* Notice that Windows 10 can do SCP / SSH natively in PowerShell.

  ~~~
  # SCP the downloaded file to ESXis tmp folder.
  scp xsibackup_ver_11_2_9.zip root@esxihost:/tmp/

  # SSH to ESXi and run these commands
  xsibackup="xsibackup_ver_11_2_9.zip" && \
  cd /tmp && \
  unzip "$xsibackup" && chmod 0700 install && ./install || cat "$xsibackup" && echo "" && \
  rm -rf "$xsibackup"
  ~~~
* Configurations during installation
  ~~~
  .
  .
  .

  Where do you want to install XSIBackup to? (/scratch/XSI): /vmfs/volumes/datastore1
  -----------------------------------------------------
  XSIBackup will be installed to the following directory:
  -----------------------------------------------------
  Install dir: /vmfs/volumes/datastore1/XSIBackup-Free
  -----------------------------------------------------
  Confirm that you want to install to the directory above (yes/no): yes
  -----------------------------------------------------
  Archive:  /vmfs/volumes/datastore1/XSIBackup-Free/XSIBACKUP-FREE.zip
     creating: src/
    inflating: src/api
    inflating: src/cron-init
    inflating: src/functions
    inflating: src/instcron
    inflating: src/mapblocks
    inflating: src/onediff
    inflating: src/sendmail
    inflating: src/version
    inflating: src/xsitools
    inflating: EULA
    inflating: EULA.txt
    inflating: xsibackup
     creating: bin/
    inflating: bin/dd
    inflating: bin/pv
    inflating: bin/xsibackup-rsync
    inflating: bin/xsidiff
     creating: conf/
    inflating: conf/dialogrc
    inflating: conf/smtpsrvs
    inflating: conf/xsiopts
  -----------------------------------------------------
  Applying permissions to files...
  -----------------------------------------------------
  The software has been installed and permissions were applied
  -----------------------------------------------------
  Do you want to execute (c)XSIBackup now (yes/no): yes
  
  .
  .
  .

  I ACCEPT THE LICENSE AGREEMENT (yes/no) yes
  --------------------------------------------------------------------------------------------------------------------
  You can start now using XSIBACKUP-FREE 11.2.9
  --------------------------------------------------------------------------------------------------------------------
  [root@esxihost:/tmp]
  ~~~


  * Instructions which come with the download link via email.
    ~~~
    cd /tmp && \
    esxcli network firewall unload && \
    wget http://a.33hops.com/downloads/?key=yourKeyASDF -O XSIBACKUP-FREE-download.zip && \
    unzip XSIBACKUP-FREE-download.zip && chmod 0700 install && ./install || cat xsibackup.zip && echo "" && \
    rm -rf XSIBACKUP-FREE-download.zip && \
    esxcli network firewall load 
    ~~~

### Test run with email alert
  * This syntax works with Gmail with user and password
    ~~~
    ./xsibackup --backup-point=/vmfs/volumes/backup \
      --backup-type=running \
      --mail-from=username@gmail.com \
      --mail-to=email.recipient@anotherdomain.com \
      --smtp-srv=smtp.gmail.com \
      --smtp-port=465 \
      --smtp-usr=username@gmail.com \
      --smtp-pwd=password \
      --test-mode=true
    ~~~
    * One should receive an email with error `ERROR (NOVM2BAK), details Error: no VMs to backup`
  * Use `--smtp-auth="none"` if you have STMP relay. You must still define `--smtp-usr=username@gmail.com` and for password use any `--smtp-pwd=any`.
    * This syntax works with smtp-relay server
      ~~~
      ./xsibackup --backup-point=/vmfs/volumes/backup \
        --backup-type=running \
        --mail-from=username@gmail.com \
        --mail-to=email.recipient@anotherdomain.com \
        --smtp-srv=smtp.gmail.com \
        --smtp-port=465 \
        --smtp-usr=username@gmail.com \
        --smtp-pwd=any \
        --smtp-auth="none" \
        --test-mode=true

## Install CRON for scheduled backups
  * Scheduling backups with cron
    ~~~
    ./xsibackup --install-cron
    ~~~
  * There's should be now a `root-crontab` in `conf` directory
    ~~~
    [root@esxihost:/vmfs/volumes/5ef5d9f2-878a326c-9937-0025901e0dc4/XSIBackup-Free] ls -la conf/
    total 256
    drwxrwxrwx    1 root     root         73728 Feb  1 16:18 .
    drwxr-xr-x    1 root     root         77824 Feb  1 16:18 ..
    -rw-r--r--    1 root     root          2871 Feb  1 15:07 dialogrc
    -rw-r--r--    1 root     root             0 Feb  1 16:18 root-crontab
    -rw-r--r--    1 root     root           613 Feb  1 15:07 smtpsrvs
    -rw-r--r--    1 root     root          2863 Feb  1 15:07 xsiopts
    ~~~

## Backup 2 (or more) certain VMs
  * Options for backup-type: `--backup-type[=custom|all|running]`.
    * `custom`: if this method is chosen a list of the VMs must be passed to the `--backup-vms` option.
    ~~~
    ./xsibackup --backup-point=/vmfs/volumes/backup \
      --backup-type=custom \
      --backup-vms="New Virtual Machine,Newer Virtual Machine" \
      --mail-from=username@gmail.com \
      --mail-to=email.recipient@anotherdomain.com \
      --smtp-srv=smtp.gmail.com \
      --smtp-port=465 \
      --smtp-usr=username@gmail.com \
      --smtp-pwd=password
    ~~~
