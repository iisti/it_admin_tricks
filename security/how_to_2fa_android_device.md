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

### Copy SMS to Termux storage when the SMS arrives with MacroDroid app
* Termux doesn't have access to SMS' by default, so the messages need to be copied into Termux storage before they can be read.
* This tutorial uses MacroDroid for automating the copying.
   * https://play.google.com/store/apps/details?id=com.arlosoft.macrodroid&hl=en&gl=US
1. Install and open MacroDroid
1. Add Macro
   * Trigger
      * SMS from *
      * Any Content
   * Actions
      * Files -> Write to File /storage/emulated/0/Android/data/com.termux/files/sms
      * filename: [year][month_digit][dayofmonth]-[hour][minute][second]__[sms_number]
      * Enter text: [sms_message]
      * Append to file
   * Constraints - none
