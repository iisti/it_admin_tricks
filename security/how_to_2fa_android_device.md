# How to use Android device as share 2FA server

## Reading text messages from Android via Termux SSH

### Install Termux
1. Install Termux application from Google Play
    * Do not mix installations of Termux and Addons between Google Play and F-Droid!
    ~~~
    pkg update && pkg upgrade
    ~~~
1. Install openssh: for ssh connection. Another option is to install *dropbear* instead of *openssh* package
    * Open Termux and run command:
        ~~~
        pkg install openssh man vim
        ~~~
        * man: for checking manuals
        * vim: text editor
1. Allow Termux to access storage, https://wiki.termux.com/wiki/Termux-setup-storage
    * Run in Termux:
    ~~~
    termux-setup-storage
    ~~~
1. Set password
    ~~~
    passwd
    ~~~
1. Check username
    ~~~
    whoami
    ~~~
1. Start sshd
    ~~~
    sshd
    ~~~
1. Check IP
    ~~~
    ip a s
    ~~~
1. SSH to the phone from another device
    ~~~
    ssh -p 8022 u0_a131@IP_ADDRESS
    ~~~
* SSH config files are stored in
    ~~~
    /data/data/com.termux/files/usr/etc/ssh
    ~~~

### 
