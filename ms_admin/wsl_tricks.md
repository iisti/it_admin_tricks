# WSL Tricks
* Tricks when using Windows Subsystem Linux

## Install WSL
* PowerShell
    ~~~
    wsl --install
    # Reboot
    shutdown /r /t 0
    wsl --list
    # Ubuntu is installed by default.
    # If you don't need Ubuntu, Unregister the distribution and delete the root filesystem.
    # One needs to remove the Ubuntu app separately via Windows.
    wsl --unregister Ubuntu
    wsl --set-default-version 2
    wsl --install -d Debian
    ~~~

## New installation Debian/Ubuntu
* Upgrade, install, set vim config, disable bell
~~~
sudo apt update; \
sudo apt -y upgrade; \
sudo apt install -y ssh tmux wget vim rsync ca-certificates; \
cd && \
wget https://gist.githubusercontent.com/iisti/bf7769f0eaa8e863e7cb0dd324b6dcf5/raw/ed4169aa875a73013ada73f71b9f8f577c2cb981/.vimrc && \
sed -i 's/^set tabstop=2/set tabstop=4/' .vimrc && \
sed -i 's/^set shiftwidth=2/set shiftwidth=4/' .vimrc && \
sed -i 's/^set softtabstop=2/set softtabstop=4/' .vimrc; \
sudo cp .vimrc /root/; \
sudo sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc; \
printf "\n# Stop bell sounds\nexport LESS=\"$LESS -R -Q\"" >> ~/.profile; \
sudo chmod u+s /bin/ping; \
[ ! -z $(grep "ID=debian" /etc/os-release) ] && \
  printf "\nOne can set Bash prompt to show only current directory by editing .bashrc \nCheck link https://superuser.com/a/60563/532911\n"

~~~

## Set locales
~~~
sudo dpkg-reconfigure locales
# Set:
#   en_US.UTF-8 UTF-8
#   C.UTF-8
# Why to use C.UTF-8
# https://stackoverflow.com/questions/55673886/what-is-the-difference-between-c-utf-8-and-en-us-utf-8-locales/55693338
~~~

## Backup
* In PowerShell
    ~~~
    wsl --shutdown
    wsl --list
    wsl --export <Image Name> <Export location file name.tar>
    # For example
    wsl --export Ubuntu-18.04 C:\wsl_backup\wsl-export-ubuntu1804.tar
    ~~~

## ping: socket: Operation not permitted
* This is already added to the initial installation/configuration above.
* Error:
    ~~~
    $ ping google.com
    ping: socket: Operation not permitted
    ~~~
    * Fix:
        `sudo chmod u+s /bin/ping`

## vimrc
* https://gist.github.com/simonista/8703722

## Disable bell
* Source https://stackoverflow.com/questions/36724209/disable-beep-of-linux-bash-on-windows-10
    ~~~
    sudo sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc; \
    printf "\n# Stop bell sounds\nexport LESS=\"$LESS -R -Q\"" >> ~/.profile

    # This is in the vimrc above, so no need to do
    printf "\n\" Stop bell sounds\nset visualbell\n" >> ~/.vimrc
    ~~~

## Change \~/dir color in the user@doh:\~/dir$
* Source
  * https://superuser.com/questions/1365258/how-to-change-the-dark-blue-in-wsl-to-something-brighter
* Right click terminal -> properties -> Screen text

## Tmux tips
* Copying without hassle, press SHIFT and select with mouse.
 * Source: https://www.rushiagr.com/blog/2016/06/16/everything-you-need-to-know-about-tmux-copy-pasting-ubuntu/


## Start WSL and cron when Windows starts
* Create a file **wsl_start_cron.vbs** with content below.
* Put the script file to C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
* It's possible to hide the process with `, vbhide` in the end of the second line.
    ~~~
    set ws=wscript.createobject("wscript.shell")
    ws.run "wsl.exe -d Debian -u root service cron start; echo 'Do not close this window. Cronjob is running in Windows Subsystem Linux.'; cat"
    ~~~
* One should see the process with `ps aux`
    ~~~
    ps aux
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.0  0.0    892   576 ?        Sl   14:31   0:00 /init
    root         9  0.0  0.0    892    80 ?        Ss   14:31   0:00 /init
    root        10  0.0  0.0    892    80 ?        S    14:31   0:00 /init
    root        11  0.0  0.0   8496  3020 pts/0    Ss+  14:31   0:00 /bin/bash -c service cron start; echo 'Do not close
    root        36  0.0  0.0   5508  2072 ?        Ss   14:31   0:00 /usr/sbin/cron
    root        54  0.0  0.0   7148   748 pts/0    S+   14:31   0:00 cat
    root        55  0.0  0.0    892    80 ?        Ss   14:32   0:00 /init
    root        56  0.0  0.0    892    80 ?        S    14:32   0:00 /init
    iisti       57  0.0  0.0   8712  3780 pts/1    Ss   14:32   0:00 -bash
    iisti       63  0.0  0.0  12352  3036 pts/1    R+   14:38   0:00 ps aux
    ~~~

## Check WSL version
* PowerShell
    ~~~
    wsl -l -v
      NAME      STATE           VERSION
    * Debian    Running         1
    ~~~

## Mount NFS 4.1
~~~
mkdir /mnt/nfs-backups

### WSL1, mount the drive in Windows and then mount it in WSL
sudo mount -t drvfs Z: /mnt/nfs-backups

### WSL2
sudo apt install nfs-common
mount -t nfs4 'server.domain.com:/nfs-share' /mnt/nfs-backups
~~~

### Mount automatically with fstab
* There will be an error "The Windows Subsystem for Linux instance has terminated." if one mounts with fstab like normal Linux machine.
* Workaround, create a bash script for mounting the NFS share
    * /opt/scripts/mount_at_reboot_with_cron.bash
        ~~~
        #!/usr/bin/env bash

        # Workaround for mounting NFS share instead of /etc/fstab which causes WSL not to boot at all.

        # Mount backups
        mount -t nfs4 'server.domain.com:/nfs-share' /mnt/nfs-backups
        ~~~
    * crontab
        ~~~
        @reboot root sleep 30s && sudo bash /opt/scripts/mount_at_reboot_with_cron.bash
        #
        ~~~
    * Configure cron to start automatically when Windows starts with the instructions above.

* Mount automatically with crontab and fstab ATTENTION THIS CAN LEAD TO NON-FUNCTIONAL WSL
    * fstab doesn't exist in Debian WSL by default, so one needs to create it.
      * cat /etc/fstab
          ~~~
          # Mount qnap NFS share
          server.domain.com:/nfs-share /mnt/nfs-backups nfs4 defaults 0 0
          ~~~
    * cat /etc/crontab
      ~~~
      .
      .
      .
      52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
      # Add the line below
      @reboot root mount -a
      #
      ~~~

### Error "The Windows Subsystem for Linux instance has terminated."
* There's error below after configuring /etc/fstab with NFS shares (this is quite surely a bug). The WSL cannot be started at all.
    ~~~
    The Windows Subsystem for Linux instance has terminated.
    Press any key to continue...
    ~~~
* Fix by export and import of the WSL2 Debian image
    1. Export
        ~~~
        wsl --export Debian wsl-export-debian-20210628.tar
        ~~~
    1. Edit the tar's /etc/fstab
    1. Remove Debian from Windows apps
    1. Reboot
    1. Import the Debian WSL back
        ~~~
        wsl --import Debian "C:\Users\iisti\Documents\wsl_debian" "C:\Users\iisti\Documents\wsl_debian_20210628\wsl-export-debian-20210628.tar"
        ~~~
    1. Start WSL
        ~~~
        wsl -d Debian
        # or just (if Debian is default / only distro)
        wsl
        ~~~
    1. Now the root user is default logged in user. It can be changed by starting as certain user or creating /etc/wsl.conf file.
        ~~~
        # Start as user
        wsl --user username
        
        # my_username="iisti"
        echo -e "[user]\ndefault=$my_username" | sudo tee -a /etc/wsl.conf

        # cat /etc/wsl.conf
        [user]
        default=iisti
        
        # Shutdown distro to apply wsl.conf
        wsl --shutdown distroname
### Some NFS errors
* `mount.nfs4: requested NFS version or transport protocol is not supported`
  * Fix: Check that the client is actually authorized on the NFS server. 


## Prevent WSL 2 from using all the memory
* WSL2 has an issue that it uses all the available memory from Windows.
    * https://github.com/microsoft/WSL/issues/4166
* One can set a limit with via `%UserProfile%\.wslconfig` file
    ~~~
    [wsl2]
    memory=6GB
    ~~~
    * More config options https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig

## Compact WSL2 disk
* In PowerShell
    ~~~
    wsl --shutdown
    wsl --list --verbose
      NAME      STATE           VERSION
    * Debian    Stopped         2
    
    # Check where WSL2 disk is stored. Different Linux distributions have different path under %userprofile%\AppData\Local\Packages
    # %userprofile%\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx
    
    # Start diskpart
    diskpart
    DISKPART> select vdisk file="C:\Users\iisti\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx"
    DiskPart successfully selected the virtual disk file.
    DISKPART> compact vdisk
      100 percent completed
    DiskPart successfully compacted the virtual disk file.
    ~~~
    * Before compacting the disk was 45GB after it's 10GB. Of course one needs to remove excess files inside the WSL itself that the compacting makes sense.
