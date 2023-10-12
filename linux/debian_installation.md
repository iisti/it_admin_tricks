# Basic installation/configuration of Debian server/desktop

## Installation with VMware ESXi
1. Download ISO
    * https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
    * Check shasum
1. Mount the ISO image with VM.
1. Use option *Install*
1. Select whatever is needed for the disks.
1. From Software selection select:
    * SSH
    * standard system utilities

## Install sudo and add user to sudoers group
~~~
su -
apt-get install sudo
usermod -aG sudo username
exit
~~~
* Login/logout with the user username, so that current groups are updated.

## Run script to install some basic software
~~~
sudo apt-get update; \
sudo apt-get -y upgrade; \
sudo apt-get install -y ssh rsync tmux wget vim git unzip; \
cd && \
wget https://gist.githubusercontent.com/iisti/bf7769f0eaa8e863e7cb0dd324b6dcf5/raw/ed4169aa875a73013ada73f71b9f8f577c2cb981/.vimrc && \
sed -i 's/^set tabstop=2/set tabstop=4/' .vimrc && \
sed -i 's/^set shiftwidth=2/set shiftwidth=4/' .vimrc && \
sed -i 's/^set softtabstop=2/set softtabstop=4/' .vimrc && \
sudo cp ~/.vimrc /root/

# For ESXi
sudo apt-get install -y open-vm-tools
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

## Show current folder instead of full path in shell
* Source: https://superuser.com/a/60563/532911
* Change \w from lowercase to uppercase \W in ~/.bashrc file
    ~~~
    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W \$\[\033[00m\] '
                                                                                                ^ This one
    ~~~
    * Start new shell.
* Adding the same for root user
    ~~~
    sudo tee -a /root/.bashrc <<'EOF'

    ### Added into the default conf
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
    EOF
    ~~~
    
## Add additional user
* This user uses SSH key as authentication. Argument `--disabled-password` can be left out if password is required.
   ~~~
   newuser=user_name
   sudo adduser "$newuser" --disabled-password
   
   # Add .ssh folder, authorized_keys file and SSH key for authentication
   sudo su - "$newuser"
   mkdir .ssh
   chmod 700 .ssh
   touch .ssh/authorized_keys
   chmod 600 .ssh/authorized_keys
   sshkey_public="ssh-ed25519 xxxxyyyywwww user@email.com"
   echo "$sshkey_public" | tee -a ~/.ssh/authorized_keys
   exit
   
   # Create a own SSH key
   ssh-keygen -t ed25519 -C "your_email@example.com"

   # Add to sudoers group
   sudo usermod -a -G sudo $newuser
   ~~~

* One can add this to own machine for connecting into the Debian machine.
   ~~~
   ~/.ssh/config

   Host <machine_name>
       # Machine name, machine ID i-xxxxx
       Hostname <IP or DNS name>
       User <user_name>
       IdentityFile ~/.ssh/ssh_key.pem
   ~~~

## Add extra disk
* This has been tested in AWS with Debian 10.
    * Run as root or sudo
        ~~~
        lsblk
        fdisk /dev/nvme1n1
        # Choices: n, p, 1, default, default, w
        lsblk
        mkfs.xfs /dev/nvme1n1p1
        # If error "-bash: mkfs.xfs: command not found"
        apt-get install xfsprogs
        mkfs.xfs /dev/nvme1n1p1
        # Create mountpoint and mount
        mkdir -p /opt/storage/disk02
        mount /dev/nvme1n1p1 /opt/storage/disk02

        # Check disk UUID
        blkid
            /dev/nvme1n1p1: UUID="84f08de0-ba36-4e01-9c3b-d416d0547521" BLOCK_SIZE="512" TYPE="xfs" PARTUUID="e32b3c3a-01"
        
        # Add to /etc/fstab
        
        # Extra disk for backups, use UUID not device name! In some cases Linux can change the dev nams which messes up disk order.
        # nofail = allow booting even if this device fails
        # 0 = no dumping of filesystem
        # 2 = non-root device
        # /dev/nvme1n1p1
        UUID=84f08de0-ba36-4e01-9c3b-d416d0547521 /opt/storage/disk02  xfs defaults 0 2
        ~~~

## Install XRDP for Remote Desktop Connection
* Install and configure
   ~~~
   sudo apt-get install xrdp
   # This is for NLA (Network Level Authentication)
   # Otherwise there will be warning of "you're using older version..."
   sudo adduser xrdp ssl-cert
   sudo systemctl restart xrdp
   ~~~
* Firewall might need configuration
   ~~~
   # Allow access from certain IP
   ufw allow from server_ip_addr to any port 3389

   # Allow access from everywhere
   ufw allow 3389
   ~~~
* Might need restarting the whole machine
* Local user must be logged out, so that the RDP connection succeeds.

## Install Google Drive
* Tested on Debian 11 Desktop
   * OcalmFuse worked properly, Gnome Online Account didn't
      ~~~
      sudo apt-get install libfuse-dev libsqlite3-dev
      sudo apt-get install opam -y
      opam init
      opam update
      opam install depext
      opam install google-drive-ocamlfuse

      # Add configuration to ~/.bashrc
      PATH="$PATH:$HOME/.opam/default/bin"

      source ~/.bashrc

      # Check that everything was installed properly 
      opam install google-drive-ocamlfuse
      google-drive-ocamlfuse
      # Allow accesses, then there should come up a notification:
          Access token retrieved correctly.

      cd
      mkdir google_drive
      google-drive-ocamlfuse google_drive
      ~~~

## Install Docker
* Check [docker_install.md](../docker/docker_install.md)

## Install Node.js
   ~~~
   sudo apt-get install nodejs npm; \
   node -v
   ~~~
