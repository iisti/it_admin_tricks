# How to use an Android device as a shared 2FA SMS server
* Creating this kind of 2FA server is a bit against 2FA security principles, but adding second layer of security via SMS and these instructions still enhances security compared to having only a password protection.

## Reading text messages from Android via Termux SSH

### Install Termux
1. Install Termux application from F Droid. Google Play doesn't support Termux anymore properly (5.2.2022).
    * Do not mix installations of Termux and Addons between Google Play and F-Droid!
    ~~~
    pkg update && pkg upgrade
    ~~~
1. Install openssh: for ssh connection. Another option is to install *dropbear* instead of *openssh* package
    * Open Termux and run command:
        ~~~
        pkg install openssh man vim rsync iproute2
        ~~~
        * man: for checking manuals
        * vim: text editor
        * rsync: for copying files into another server
        * iproute2: for checking current IP
1. Allow Termux to access storage, https://wiki.termux.com/wiki/Termux-setup-storage
    * Run in Termux:
    ~~~
    termux-setup-storage
    ~~~
    * Android 11
      ~~~
      You may get "Permission denied" error when trying to access shared storage, even though the permission has been granted.

      Workaround:

          Go to Android Settings --> Applications --> Termux --> Permissions
          Revoke Storage permission
          Grant Storage permission again

      This is a known issue, though this is not Termux bug.
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
      * SMS from * / SMS from Any Number
      * Any Content
   * Actions
      * Files -> Write to File /storage/emulated/0/Android/data/com.termux/files/sms
      * filename: [year][month_digit][dayofmonth]-[hour][minute][second]__[sms_number]
      * Enter text: [sms_message]
      * Append to file
   * Constraints - none
1. Now any 

## Publish SMS via Apache2

### Install Apache2
* Source https://medium.com/@huffypiet/how-i-set-up-apache2-web-server-with-termux-on-android-2d7e31aac63e
1. Install package and start
    ~~~
    pkg install apache2
    apachectl start
    ~~~
1. Go with browser http://IP:8080/ and you should see "It works!" or some other default page.
    * Default page is located in /data/data/com.termux/files/usr/share/apache2/default-site/htdocs
1. Create Debian like sites-available and sites-enabled structure if it doesn't exist.
    * This is just to make life a bit easier with test/prod confs.
    * Check if they exist already
        ~~~
        ls -la /data/data/com.termux/files/usr/etc/apache2/
        ~~~
    * If they don't exist create them
        ~~~
        mkdir /data/data/com.termux/files/usr/etc/apache2/sites-available
        mkdir /data/data/com.termux/files/usr/etc/apache2/sites-enabled
        ~~~
1. If the sites-* folders didn't exist, add configuration below to Apache main configuration file.
    * This enables that the configuration files in sites-enabled are loaded.
    * There's also some added security.
        ~~~
        cp /data/data/com.termux/files/usr/etc/apache2/httpd.conf /data/data/com.termux/files/usr/etc/apache2/httpd.conf.orig; \
        cat <<EOF >> /data/data/com.termux/files/usr/etc/apache2/httpd.conf

        # For Debian style sites-available and sites-enabled
        IncludeOptional /data/data/com.termux/files/usr/etc/apache2/sites-enabled/*.conf

        # Additional security
        # Source:
        # https://www.systemcodegeeks.com/web-servers/apache/apache-configuration-tutorial/
        ServerSignature Off
        ServerTokens Prod
        EOF
        ~~~

1. Configure httpd.conf
    * Replace pattern example https://stackoverflow.com/questions/11659970/finding-and-replacing-lines-that-begin-with-a-pattern
    ~~~
    sed -i 's/^#ServerName.*$/ServerName localhost/' /data/data/com.termux/files/usr/etc/apache2/httpd.conf
    ~~~
1. Create new webroot for the site and a test page
    ~~~
    # Create webroot
    mkdir /data/data/com.termux/files/home/storage/shared/Android/data/com.termux/files/sms
    # Create test index.html
    echo "test" >> /data/data/com.termux/files/home/storage/shared/Android/data/com.termux/files/sms/index.html
    ~~~
1. Create test page configuration for Apache
    * cat /data/data/com.termux/files/usr/etc/apache2/sites-available/sms.domain.com.conf
    ~~~
    <VirtualHost *:8080>
       ServerName sms.domain.com
       ServerAdmin email@domain.com
       DocumentRoot /data/data/com.termux/files/home/storage/shared/Android/data/com.termux/files/sms

       <Directory "/data/data/com.termux/files/home/storage/shared/Android/data/com.termux/files/sms" >
           Options Indexes FollowSymlinks
           AllowOverride None
           Require all granted
           
           # Ä and Ö
           IndexOptions +Charset=UTF-8
          
         # Show full file names
         <IfModule mod_autoindex.c>
            IndexOptions NameWidth=*
         </ifModule>
         
         # For creating a header for the page.
         HeaderName /header.html
         IndexIgnore header.html
       </Directory>

       <Location "/">
           # Restrict to certain IP or network
           Require ip 192.168.3.30
           Require ip 192.168.2.1/24
       </Location>

       # Default error log is in
       # /data/data/com.termux/files/usr/var/log/apache2/error_log
    </VirtualHost>
    
    # vim: filetype=apache expandtab ts=4 sw=4
    ~~~
1. Enable the site
    ~~~
    cd /data/data/com.termux/files/usr/etc/apache2/sites-enabled
    ln -s ../sites-available/mobile-sms.domain.com.conf .
    ~~~
1. Run configuration test 
    ~~~
    apachectl configtest
    ~~~
1. Restart Apache2 to load configuration
   * apachectl stop can cause error:
      ~~~
      $ apachectl stop
      (20014)Internal error (specific information not available): AH00058: Error retrieving pid file var/run/apache2/httpd.pid
      AH00059: Remove it before continuing if it is corrupted.
      ~~~

   * Solution is to kill httpd/apache2 process, remove httpd.pid and start httpd/apache2
      * Command in oneliner to restart/start Apache is:
      ~~~
      killall -9 httpd ; rm /data/data/com.termux/files/usr/var/run/apache2/httpd.pid ; apachectl -k start
      ~~~
1. In browser you shold see "test" at http://IP_of_phone:8080
1. Remove index.html and create header.html. All the new sms files should be listed below header content.
